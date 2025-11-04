//
//  SolidNativeProps.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI
import JavaScriptCore

class SolidNativeProps: ObservableObject {
    @Published var values: [String:JSValue?] = [:];
    var keys: [String] = []

    // TODO: Type this!
    @Published var children: [SolidNativeView] = [];
    
    func getProp<T>(name: String, `default`: T) -> T {
        if let prop = values[name] as? T {
            return prop
        }
        return `default`
    }
    
    func getString(name: String, `default`: String = "") -> String {
        if let prop = (values[name] ?? nil) {
            return prop.toString()
        }
        return `default`
    }
    
    func getStringOrNil(name: String) -> String? {
        if let prop = (values[name] ?? nil) {
            return prop.toString()
        }
        return nil
    }
    
    func getNumber(name: String, `default`: NSNumber = 0) -> NSNumber {
        if let prop = (values[name] ?? nil) {
            return prop.toNumber()
        }
        return `default`
    }
    
    func getNumberOrNil(name: String) -> NSNumber? {
        if let prop = (values[name] ?? nil) {
            return prop.toNumber()
        }
        return nil
    }
    
    func getBoolean(name: String, `default`: Bool = false) -> Bool {
        if let prop = (values[name] ?? nil) {
            return prop.toBool()
        }
        return `default`
    }
    
    func getBooleanOrNil(name: String) -> Bool? {
        if let prop = (values[name] ?? nil), prop.isBoolean {
            return prop.toBool()
        }
        return nil
    }
    
    
    func getChildren() -> [SolidNativeView] {
        children
    }
    
    func getPropAsJSValue(name: String) -> JSValue? {
        values[name] ?? nil
    }
    
    func callCallbackWithArgs(name: String, args: [Any]) {
        if let callback = getPropAsJSValue(name: name) {
            callback.call(withArguments: args)
        }
    }
}
