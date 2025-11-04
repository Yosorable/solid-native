//
//  SolidNativeCore.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import JavaScriptCore
import ECMASwift

/**
 
 */
class SolidNativeCore {
    static var shared: SolidNativeCore!
    
    var jsRuntime = JSRuntime()
    var jsContext: JSContext {
        return jsRuntime.context
    }
    private let moduleManager = ModuleManager()
    
    init() {
        // jsContext.isInspectable = true
        moduleManager.registerModule(SNRender.self)
        injectCoreIntoContext()
        // Configure base module
        
        // Needs to inject function to grab other modules from registry and return their JSValues

//        print("[SolidNativeCore] init")
    }
    
    deinit {
        print("[SolidNativeCore] deinit")
    }
    
    private func injectCoreIntoContext() {
        let getNativeModule: @convention(block) (_ name: String) -> JSValue = { [weak self] str in
            guard let strongSelf = self else {
                return JSValue(undefinedIn: self?.jsRuntime.context)
            }
            return strongSelf.moduleManager.createModuleJsValueByName(str)!
        }
        jsContext.setObject(getNativeModule, forKeyedSubscript:
                                "_getNativeModule" as NSString)
    }
    
    // SNRender will pull it from the singleton
    var rootElement = SNView()
    var navigationStack: [SNView] = []
    
    
    func downloadAndRunJsBundleSync() {
        if let url = URL(string: "http://192.168.0.32:8080"),
           let sourceUrl = URL(string: "http://192.168.0.32:8080/source"){
            do {
                let bundle = try String(contentsOf: url)
                
                jsContext.exceptionHandler = { (_, value) in
                    print("JS Error: " + value!.toString()!)
                }
                
                let jsPrint: @convention(block) (_ contents: String) -> Void = { str in
                    print(str)
                }
                //jsContext.isInspectable = true
                jsContext.setObject(jsPrint, forKeyedSubscript: "_print" as NSString)
                // SharedJSConext.sharedContext.setObject(sharedSolidNativeCore, forKeyedSubscript: "_SolidNativeCore" as NSString)
                jsContext.evaluateScript(bundle, withSourceURL: sourceUrl)
            } catch (let err) {
                // contents could not be loaded
                print(err.localizedDescription)
            }
        } else {
            // the URL was bad!
            print("ERROR: Url was bad!")
        }
    }
    
    
    static let bundlePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("index.js")
    static let sourcePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("index.js.map")
    
    static func download(baseUrl: String, sourceUrl: String) {
        if let url = URL(string: baseUrl),
           let sourceUrl = URL(string: sourceUrl){
            do {
                let bundle = try String(contentsOf: url)
                let source = try String(contentsOf: sourceUrl)
                
                try bundle.write(to: bundlePath, atomically: true, encoding: .utf8)
                try source.write(to: sourcePath, atomically: true, encoding: .utf8)
            } catch (let err) {
                // contents could not be loaded
                print(err.localizedDescription)
            }
        } else {
            // the URL was bad!
            print("ERROR: Url was bad!")
        }
    }
    
    func runApp() {
        do {
            let bundle = try String(contentsOf: SolidNativeCore.bundlePath)
            
            jsContext.exceptionHandler = { (_, value) in
                print("JS Error: " + value!.toString()!)
                print("stack: \(value?.objectForKeyedSubscript("stack").toString() ?? "")")
            }
            
            let jsPrint: @convention(block) (_ contents: String) -> Void = { str in
                print(str)
            }
            
            //jsContext.isInspectable = true
            jsContext.setObject(jsPrint, forKeyedSubscript: "_print" as NSString)
            jsContext.setObject(SQLiteJS.self, forKeyedSubscript: "sqlite" as NSString)
            jsContext.evaluateScript(bundle, withSourceURL: SolidNativeCore.sourcePath)
        } catch {
            print("Url was bad!")
        }
    }
    
}





private class ModuleManager {
    // Registry is needed to look
    private var moduleRegistry: [String : SolidNativeModule.Type] = [SNRender.name : SNRender.self];
    private var moduleJSValueRegistry: [String : JSValue] = [:];
    
    func registerModule(_ moduleType: SolidNativeModule.Type) {
        moduleRegistry[moduleType.name] = moduleType.self
    }
    
    func createModuleJsValueByName(_ name: String) -> JSValue? {
        // Should return a JS Value
        if let moduleType = moduleRegistry[name] {
            let newModule = moduleType.init()
            
            if let jsValue = moduleJSValueRegistry[name] {
                return jsValue
            } else {
                let jsValue = newModule.getJSValueRepresentation()
                moduleJSValueRegistry[name] = jsValue
                return jsValue
            }
        
        }
        assertionFailure("\(name) is not in module registry!")
        return nil
    }
    
    deinit {
        print("[ModulManager] deinit")
    }
}
