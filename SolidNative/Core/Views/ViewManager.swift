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
    let rootElement: SNView

    init(jsContext: JSContext) {
        self.jsContext = jsContext
        self.rootElement = SNView()
        self.addViewToRegistry(view: self.rootElement)
    }

    deinit {
        print("[ViewManager] deinit")
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

    func removeViewById(_ id: String) {
        let node = createdViewRegistry.removeValue(forKey: id)
        deactivateAllChildren(root: node)
    }

    private func deactivateAllChildren(root: SolidNativeView?) {
        guard let root = root else { return }

        if let r = createdViewRegistry.removeValue(forKey: root.id.uuidString) {
            let address = Unmanaged.passUnretained(r).toOpaque()
            print(
                "id: \(r.id.uuidString), name: \(r.getName()), address: \(address)"
            )
        }

        let v = root

        if let nv = v as? SNTabView {
            nv.tabIds.forEach {
                print("tab id: \($0)")
                // MARK: todo: cleanAllPages时多次清除了
                jsContext.evaluateScript(
                    "cleanPage(\"\($0)\")"
                )
                if let c = createdViewRegistry[$0] {
                    deactivateAllChildren(root: c)
                }
            }
        }

        // 递归遍历所有子节点
        for child in root.children {
            deactivateAllChildren(root: child)
        }

        // 非直接子节点（属性中的）
        for child in root.indirectChildren {
            deactivateAllChildren(root: child)
        }

        // 如果有 next 节点，继续设置
        if let nextNode = root.next {
            deactivateAllChildren(root: nextNode)
        }
    }

    func removePageById(_ id: String) {
        if let v = self.createdViewRegistry[id] {
            self.deactivateAllChildren(root: v)
        }
    }

    func removePageByRoot(_ root: SolidNativeView) {
        self.deactivateAllChildren(root: root)
    }

    func clearAll() {
        createdViewRegistry.forEach { key, val in
            val.next = nil
            val.prev = nil
            val.parentElement = nil
            val.firstChild = nil
            val.indirectChildren.removeAll()
            val.children.removeAll()
            val.props.children.removeAll()
            val.props.values.removeAll()
            val.vm = nil
        }
        createdViewRegistry = [:]
        
        let val = rootElement
        val.next = nil
        val.prev = nil
        val.parentElement = nil
        val.firstChild = nil
        val.indirectChildren.removeAll()
        val.children.removeAll()
        val.props.values.removeAll()
        val.props.children.removeAll()
        val.vm = nil
        
        print("---------- clean end")
    }

    func debugPrint() {
        #if DEBUG
            for (k, v) in createdViewRegistry {
                let address = Unmanaged.passUnretained(v).toOpaque()
                let retainCount = CFGetRetainCount(v as CFTypeRef)
                print(
                    "id: \(k), name: \(v.getName()), ref: \(retainCount), address: \(address)  \(k == rootElement.id.uuidString ? "[root]" : "")"
                )
            }
        #endif
    }
}
