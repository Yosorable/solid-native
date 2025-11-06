//
//  ViewManager.swift
//  SolidNative
//
//  Created by LZY on 2025/11/6.
//

import Foundation
import JavaScriptCore

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
    //    let rootElement: SNView
    let rootID: String

    init(jsContext: JSContext) {
        self.jsContext = jsContext
        //        self.rootElement = SNView()
        //        self.addViewToRegistry(view: self.rootElement)
        let root = SNView()
        rootID = root.id.uuidString
        self.addViewToRegistry(view: root)
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
            for (k, v) in createdViewRegistry {
                let address = Unmanaged.passUnretained(v).toOpaque()
                let retainCount = CFGetRetainCount(v as CFTypeRef)
                print(
                    "id: \(k), name: \(v.getName()), ref: \(retainCount), address: \(address)  \(k == rootID ? "[root]" : "")"
                )
            }
        #endif
    }
}
