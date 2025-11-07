//
//  SolidNativeCore.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import QuickJS

class SolidNativeCore {
    static var shared: SolidNativeCore!
    
    let jsRuntime: JSRuntime
    let jsContext: JSContext

    let renderer: SNRender
    
    init() {
        let jsRuntime = JSRuntime()!
        self.jsRuntime = jsRuntime
        self.jsContext = jsRuntime.createContext()!
        self.renderer = SNRender(vm: ViewManager(jsContext: jsContext))
        
    }

    deinit {
        print("[SolidNativeCore] deinit")
    }

    var done = false
    private func injectModuleIntoContext() {
        guard !done else { return }
        done = true
        renderer.setupFoQuickJS(context: jsContext)
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

            jsContext.evaluateScript(
                bundle,
                withSourceURL: SolidNativeCore.bundlePath,
            )
            jsContext.evaluateScript(
                "console.log(SolidNativeRenderer.createNodeByName('sn_view'))",
                withSourceURL: SolidNativeCore.bundlePath,
            )
        } catch {
            print("Url was bad!")
        }
    }

}
