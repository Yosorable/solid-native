//
//  ViewManager.swift
//  SolidNative
//
//  Created by LZY on 2025/11/6.
//

import Foundation
import JavaScriptCore
import UIKit

class ViewManager {
    private static let viewRegistry: [String: SolidNativeView.Type] = {
        var registry: [String: SolidNativeView.Type] = [:]
        func register(_ viewType: SolidNativeView.Type) {
            registry[viewType.name] = viewType
        }

        [
            SNTextView.self,
            SNView.self,
            SNButtonView.self,
            SNScrollView.self,
            SNToggle.self,
            SNVStack.self,
            SNHStack.self,
            SNZStack.self,
            SNLazyVStack.self,
            SNLazyHStack.self,
            SNSpacer.self,
            SNSlider.self,
            SNTextField.self,
            SNSecureField.self,
            SNLazyVGrid.self,
            SNRectangle.self,
            SNWebImage.self,
            SNList.self,
            SNLabel.self,
            SNTabView.self,
            SNNavigationStack.self,
            SNNavigationLink.self,
            SNWebView.self,
        ].forEach(register)

        return registry
    }()

    private var createdViewRegistry: [String: SolidNativeView] = [:]
    let jsContext: JSContext

    private var rid: String?
    var rootID: String {
        if let id = rid, createdViewRegistry[id] != nil {
            return id
        }
        let root = SNView()
        createdViewRegistry[root.id.uuidString] = root
        rid = root.id.uuidString
        return root.id.uuidString
    }

    init(jsContext: JSContext) {
        self.jsContext = jsContext
    }

    deinit {
        print("[ViewManager] deinit")
    }

    func getRoot() -> SolidNativeView {
        return self.getViewById(rootID)
    }

    @discardableResult
    func addViewToRegistry(view: SolidNativeView) -> String {
        let id = view.id.uuidString
        view.vm = self
        createdViewRegistry[id] = view
        return id
    }

    // Only thing it needs is the View type, the View Name, whether or not it a text view

    /**
     @returns view id
     */
    func createViewByName(_ name: String) -> String {
        if let viewType = ViewManager.viewRegistry[name] {
            let newView = viewType.init()
            return addViewToRegistry(view: newView)
        }
        assertionFailure("\(name) is not in element registry!")
        return ""
    }

    func getViewById(_ id: String) -> SolidNativeView {
        if let view = createdViewRegistry[id] {
            return view
        }
        assertionFailure("view with id \(id) is not in element registry!")
        return SolidNativeView()
    }

    private func deactivateAllChildren(_ node: SolidNativeView) {
        if let r = createdViewRegistry.removeValue(forKey: node.id.uuidString) {
            let address = Unmanaged.passUnretained(r).toOpaque()
            print(
                "id: \(r.id.uuidString), name: \(r.getName()), address: \(address)"
            )
        }

        if let nv = node as? SNTabView {
            nv.tabIds.forEach {
                print("tab id: \($0)")
                jsContext.evaluateScript(
                    "cleanPage(\"\($0)\")"
                )
                if let c = createdViewRegistry[$0] {
                    deactivateAllChildren(c)
                }
            }
        }

        for child in node.children {
            deactivateAllChildren(child)
        }

        for child in node.indirectChildren {
            deactivateAllChildren(child)
        }

        if let nextNode = node.next {
            deactivateAllChildren(nextNode)
        }
    }

    func removeViewById(_ id: String) {
        if let node = createdViewRegistry.removeValue(forKey: id) {
            deactivateAllChildren(node)
        }
    }

    func removePageByRoot(_ id: String) {
        if let root = createdViewRegistry[id] {
            self.deactivateAllChildren(root)
        }
    }

    func clearAll() {
        jsContext.evaluateScript(
            "cleanAllPages()"
        )
        createdViewRegistry.removeAll()
    }

    func debugPrint() {
        #if DEBUG
            var msg = "veiw count: \(createdViewRegistry.count)\n"

            var visited = [String: Bool]()
            func findParent(_ id: String) -> String {
                var tmp = id
                while let v = createdViewRegistry[tmp], let p = v.parentElement
                {
                    tmp = p.id.uuidString
                }
                return tmp
            }
            func rec(_ id: String, _ prefix: String = "") {
                guard let v = createdViewRegistry[id] else { return }
                let k = v.id.uuidString
                if visited[k] != true {
                    visited[k] = true

                    let address = Unmanaged.passUnretained(v).toOpaque()
                    let retainCount = CFGetRetainCount(v as CFTypeRef)
                    msg +=
                        "\(prefix)\(k == rootID ? "[root] " : "")\(v.getName().trimmingPrefix("sn_")): ref: \(retainCount), addr: \(address)\n"
                    print(
                        "\(prefix)id: \(k), name: \(v.getName()), ref: \(retainCount), address: \(address)  \(k == rootID ? "[root]" : "")"
                    )
                }

                for c in v.children {
                    rec(c.id.uuidString, prefix + "_")
                }

                for c in v.indirectChildren {
                    rec(c.id.uuidString, prefix + "_")
                }

                if let n = v.next {
                    rec(n.id.uuidString, prefix)
                }
            }

            rec(rootID)
            for (k, _) in createdViewRegistry {
                if visited[k] == true { continue }
                let id = findParent(k)
                rec(id)
            }

            let vc = UIViewController()
            vc.title = "debug"
            let textView = UITextView()
            textView.text = msg
            textView.isEditable = false
            textView.font = .systemFont(ofSize: 15)
            vc.view = textView
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: nil,
                action: nil
            )
            vc.navigationItem.rightBarButtonItem?.primaryAction = UIAction { [weak vc] _ in
                vc?.dismiss(animated: true)
            }

            GetTopViewController()?.present(
                UINavigationController(rootViewController: vc),
                animated: true
            )
        #endif
    }
}
