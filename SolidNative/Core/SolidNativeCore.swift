//
//  SolidNativeCore.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import ECMASwift
import Foundation
import JavaScriptCore

/**

 */
class SolidNativeCore {
    static var shared: SolidNativeCore!

    let jsRuntime: JSRuntime
    var jsContext: JSContext {
        return jsRuntime.context
    }

    let renderer: SNRender
    
    init() {
        let jsRuntime = JSRuntime()
        self.jsRuntime = jsRuntime
        self.renderer = SNRender(vm: ViewManager(jsContext: jsRuntime.context))
    }

    deinit {
        print("[SolidNativeCore] deinit")
    }

    var done = false
    private func injectModuleIntoContext() {
        guard !done else { return }
        done = true
        let r = renderer.getJSValueRepresentation(jsContext: jsContext)
        jsContext.setObject(
            r,
            forKeyedSubscript: "SolidNativeRenderer" as NSString
        )
    }
    
    func getRootView() -> SolidNativeView {
        return renderer.viewManager.getRoot()
    }

    static let bundlePath = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent("index.js")
    static let sourcePath = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].appendingPathComponent("index.js.map")

    static func download(baseUrl: String, sourceUrl: String) {
        if let url = URL(string: baseUrl),
            let sourceUrl = URL(string: sourceUrl)
        {
            do {
                let bundle = try String(contentsOf: url, encoding: .utf8)
                let source = try String(contentsOf: sourceUrl, encoding: .utf8)

                try bundle.write(
                    to: bundlePath,
                    atomically: true,
                    encoding: .utf8
                )
                try source.write(
                    to: sourcePath,
                    atomically: true,
                    encoding: .utf8
                )
            } catch (let err) {
                print(err.localizedDescription)
            }
        } else {
            print("ERROR: Url was bad!")
        }
    }

    func runApp() {
        do {
            injectModuleIntoContext()
            let bundle = try String(
                contentsOf: SolidNativeCore.bundlePath,
                encoding: .utf8
            )

            jsContext.exceptionHandler = { (_, value) in
                print("JS Error: " + value!.toString()!)
                print(
                    "stack: \(value?.objectForKeyedSubscript("stack").toString() ?? "")"
                )
            }

            jsContext.evaluateScript(
                bundle,
                withSourceURL: SolidNativeCore.sourcePath
            )
        } catch {
            print("Url was bad!")
        }
    }

}
