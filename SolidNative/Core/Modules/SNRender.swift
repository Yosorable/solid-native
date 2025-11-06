//
//  SNRender.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import JavaScriptCore
import SwiftUI

class SNRender {
    let viewManager: ViewManager

    required init(vm: ViewManager) {
        self.viewManager = vm

        print("[SNRender] init")
    }

    deinit {
        print("[SNRender] deinit")
    }

    func getJSValueRepresentation(jsContext: JSContext) -> JSValue {
        let builder = JSValueBuilder(jsContext: jsContext)

        builder.addSyncFunction("createNewView") { [weak self] in
            let nv = SNView()
            let id = self?.viewManager.addViewToRegistry(view: nv) ?? ""
            return id
        }

        builder.addSyncFunction("getRootView") { [weak self] in
            return self?.viewManager.rootID
        }

        builder.addSyncFunction("getFirstChild") { [weak self] (_ id: String) in
            let view = self?.viewManager.getViewById(id)
            return view?.firstChild?.id.uuidString
        }

        builder.addSyncFunction("getParent") { [weak self] (_ id: String) in
            let view = self?.viewManager.getViewById(id)
            return view?.parentElement?.id.uuidString
        }

        builder.addSyncFunction("setProp") { [weak self]
            (_ id: JSValue, name: JSValue, value: JSValue) in
            let view = self?.viewManager.getViewById(id.toString()!)
            if value.isNull || value.isUndefined {
                view?.setProp(name.toString()!, nil)
            } else {
                view?.setProp(name.toString()!, value)
            }
        }

        builder.addSyncFunction("isTextElement") { [weak self] (_ id: String) in
            let view = self?.viewManager.getViewById(id)
            return view?.isTextElement
        }

        builder.addSyncFunction("removeChild") { [weak self]
            (_ id: String, childId: String) in
            guard let view = self?.viewManager.getViewById(id), let viewChild = self?.viewManager.getViewById(childId) else {return}

            view.removeChild(viewChild)
            self?.viewManager.removeViewById(childId)
        }

        builder.addSyncFunction("insertBefore") { [weak self]
            (_ id: JSValue, elementId: JSValue, anchorId: JSValue) in
            guard let view = self?.viewManager.getViewById(id.toString()!),
                  let element = self?.viewManager.getViewById(elementId.toString()!) else { return }

            if anchorId.isString {
                let anchor = self!.viewManager.getViewById(anchorId.toString()!)
                return view.insertBefore(element, anchor)
            }

            return view.insertBefore(element, nil)
        }

        builder.addSyncFunction("next") { [weak self] (_ id: String) in
            let view = self?.viewManager.getViewById(id)
            return view?.next?.id.uuidString
        }

        builder.addSyncFunction("prev") { [weak self] (_ id: String) in
            let view = self?.viewManager.getViewById(id)
            return view?.prev?.id.uuidString
        }

        builder.addSyncFunction("createNodeByName") { [weak self] (_ name: String) in
            let viewId = self?.viewManager.createViewByName(name) ?? ""
            return viewId
        }

        builder.addSyncFunction("_withAnimation") { (_ fn: JSValue) in
            _ = withAnimation {
                fn.call(withArguments: [])
            }
        }

        builder.addSyncFunction("_webView_load") { [weak self]
            (_ id: String, _ urlString: String) in
            guard
                let node = self?.viewManager.getViewById(id)
                    as? SNWebView
            else { return }
            var url: URL
            if let u = URL(string: urlString), u.scheme != nil {
                url = u.standardized
            } else {
                let baseURL = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )[0]
                url = baseURL.appending(path: urlString).standardized
            }
            node.webViewController.webView.load(URLRequest(url: url))
        }

        builder.addSyncFunction("_webView_loadHTMLString") { [weak self]
            (_ id: JSValue, html: JSValue, baseURLString: JSValue) in
            guard let id = id.toString(), let html = html.toString() else {
                return
            }
            guard
                let node = self?.viewManager.getViewById(id)
                    as? SNWebView
            else { return }
            var url: URL? = nil
            if baseURLString.isString, let urlString = baseURLString.toString(),
                let u = URL(string: urlString), u.scheme != nil
            {
                url = u.standardized
            } else if baseURLString.isString,
                let urlString = baseURLString.toString()
            {
                let baseURL = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )[0]
                url = baseURL.appending(path: urlString).standardized
            }
            node.webViewController.webView.loadHTMLString(html, baseURL: url)
        }

        builder.addSyncFunction("_webView_evaluateJavaScript") { [weak self]
            (_ id: String, _ code: String, _ callback: JSValue) in
            guard
                let webView =
                    (self?.viewManager.getViewById(id) as? SNWebView)?
                    .webViewController.webView
            else { return }
            if callback.isUndefined || callback.isNull {
                webView.evaluateJavaScript(code, completionHandler: nil)
            } else {
                webView.evaluateJavaScript(
                    code,
                    completionHandler: { (res, err) in
                        if let res = res {
                            callback.call(withArguments: [res, NSNull() as Any])
                        } else if let err = err?.localizedDescription {
                            callback.call(withArguments: [
                                NSNull() as Any, err as Any,
                            ])
                        } else {
                            callback.call(withArguments: [NSNull() as Any])
                        }
                    }
                )
            }
        }

        return builder.value
    }
}
