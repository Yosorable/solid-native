//
//  SNRender.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI
import QuickJS

class SNRender {
    let viewManager: ViewManager

    required init(vm: ViewManager) {
        self.viewManager = vm

        print("[SNRender] init")
    }

    deinit {
        print("[SNRender] deinit")
    }
    
    func setupFoQuickJS(context: JSContext) {
        func argAt(argc: Int, argv: JSCValuePointer?, at: Int) -> JSValue {
            guard let argv = argv else { return .undefined }
            return Int(argc) > at ? JSValue(context, value: argv[at]) : .undefined
        }
        
        context.module("solid_native_renderer") {
            JSModuleFunction("createNewView", argc: 0) { [weak self] ctx, this, argc, argv in
                let nv = SNView()
                let id = self?.viewManager.addViewToRegistry(view: nv) ?? ""
                return id
            }

            JSModuleFunction("getRootView", argc: 0) { [weak self] ctx, this, argc, argv in
                return self?.viewManager.rootID
            }

            JSModuleFunction("getFirstChild", argc: 1) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString() else { return nil }
                
                // (_ id: String)
                let view = self?.viewManager.getViewById(id)
                return view?.firstChild?.id.uuidString
            }

            JSModuleFunction("getParent", argc: 1) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString() else { return nil }
                // (_ id: String)
                let view = self?.viewManager.getViewById(id)
                return view?.parentElement?.id.uuidString
            }

            JSModuleFunction("setProp", argc: 3) { [weak self] ctx, this, argc, argv in
                let id = argAt(argc: argc, argv: argv, at: 0)
                let name = argAt(argc: argc, argv: argv, at: 1)
                let value = argAt(argc: argc, argv: argv, at: 2)
                
                // (_ id: JSValue, name: JSValue, value: JSValue)
                let view = self?.viewManager.getViewById(id.toString()!)
                if value.isNull || value.isUndefined {
                    view?.setProp(name.toString()!, nil)
                } else {
                    view?.setProp(name.toString()!, value)
                }
                return nil
            }

            JSModuleFunction("isTextElement", argc: 1) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString() else { return nil }
                
                // (_ id: String)
                let view = self?.viewManager.getViewById(id)
                return view?.isTextElement
            }

            JSModuleFunction("removeChild", argc: 2) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString(),
                      let childId = argAt(argc: argc, argv: argv, at: 1).toString() else { return nil }
                
                // (_ id: String, childId: String)
                guard let view = self?.viewManager.getViewById(id), let viewChild = self?.viewManager.getViewById(childId) else { return nil}

                view.removeChild(viewChild)
                self?.viewManager.removeViewById(childId)
                return nil
            }

            JSModuleFunction("insertBefore", argc: 3) { [weak self] tx, this, argc, argv in
                let id = argAt(argc: argc, argv: argv, at: 0)
                let elementId = argAt(argc: argc, argv: argv, at: 1)
                let anchorId = argAt(argc: argc, argv: argv, at: 2)
                
                // (_ id: JSValue, elementId: JSValue, anchorId: JSValue)
                guard let view = self?.viewManager.getViewById(id.toString()!),
                      let element = self?.viewManager.getViewById(elementId.toString()!) else { return nil }

                if anchorId.isString {
                    let anchor = self!.viewManager.getViewById(anchorId.toString()!)
                    view.insertBefore(element, anchor)
                    return nil
                }

                view.insertBefore(element, nil)
                return nil
            }

            JSModuleFunction("next", argc: 1) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString() else { return nil }
                
                //  (_ id: String)
                let view = self?.viewManager.getViewById(id)
                return view?.next?.id.uuidString
            }

            JSModuleFunction("prev", argc: 1) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString() else { return nil }
                
                // (_ id: String)
                let view = self?.viewManager.getViewById(id)
                return view?.prev?.id.uuidString
            }

            JSModuleFunction("createNodeByName", argc: 1) { [weak self] ctx, this, argc, argv in
                guard let name = argAt(argc: argc, argv: argv, at: 0).toString() else { return nil }
                
                // (_ name: String)
                let viewId = self?.viewManager.createViewByName(name)
                return viewId
            }

            JSModuleFunction("_withAnimation", argc: 1) { ctx, this, argc, argv in
                let fn = argAt(argc: argc, argv: argv, at: 0)
                
                // (_ fn: JSValue)
                _ = withAnimation {
                    fn.call(withArguments: [])
                }
                return nil
            }

            JSModuleFunction("_webView_load", argc: 2) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString(),
                      let urlString = argAt(argc: argc, argv: argv, at: 1).toString() else { return nil }
                
                // (_ id: String, _ urlString: String)
                guard
                    let node = self?.viewManager.getViewById(id)
                        as? SNWebView
                else { return nil }
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
                return nil
            }

            JSModuleFunction("_webView_loadHTMLString", argc: 3) { [weak self] ctx, this, argc, argv in
                let id = argAt(argc: argc, argv: argv, at: 0)
                let html = argAt(argc: argc, argv: argv, at: 1)
                let baseURLString = argAt(argc: argc, argv: argv, at: 2)
                
                // (_ id: JSValue, html: JSValue, baseURLString: JSValue)
                guard let id = id.toString(), let html = html.toString() else {
                    return nil
                }
                guard
                    let node = self?.viewManager.getViewById(id)
                        as? SNWebView
                else { return nil }
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
                return nil
            }

            JSModuleFunction("_webView_evaluateJavaScript", argc: 3) { [weak self] ctx, this, argc, argv in
                guard let id = argAt(argc: argc, argv: argv, at: 0).toString(),
                      let code = argAt(argc: argc, argv: argv, at: 1).toString() else { return nil }
                let callback = argAt(argc: argc, argv: argv, at: 2)
                
                // (_ id: String, _ code: String, _ callback: JSValue)
                guard
                    let webView =
                        (self?.viewManager.getViewById(id) as? SNWebView)?
                        .webViewController.webView
                else { return nil }
                if callback.isUndefined || callback.isNull {
                    webView.evaluateJavaScript(code, completionHandler: nil)
                } else {
                    webView.evaluateJavaScript(
                        code,
                        completionHandler: { (res, err) in
                            if let res = res {
                                _ = callback.call(withArguments: [res, NSNull() as Any])
                            } else if let err = err?.localizedDescription {
                                _ = callback.call(withArguments: [
                                    NSNull() as Any, err as Any,
                                ])
                            } else {
                                _ = callback.call(withArguments: [NSNull() as Any])
                            }
                        }
                    )
                }
                return nil
            }
        }
        
        let script = """
        "use strict";
        import * as __solid_native_renderer from 'solid_native_renderer'

        globalThis.SolidNativeRenderer = __solid_native_renderer
        console.log("injected done.")
        """
        
        let error = context.evaluateScript(script, type: .module)
        if let err = error.toError() {
            fatalError(err.localizedDescription)
        }
    }
}
