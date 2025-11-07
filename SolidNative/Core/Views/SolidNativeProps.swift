//
//  SolidNativeProps.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import QuickJS
import SwiftUI

class SolidNativeProps: ObservableObject {
    @Published var values: [String: JSValue?] = [:]
    var keys: [String] = []

    // TODO: Type this!
    @Published var children: [SolidNativeView] = []

    func getProp<T>(name: String, `default`: T) -> T {
        if let prop = values[name] as? T {
            return prop
        }
        return `default`
    }

    func getString(name: String, `default`: String = "") -> String {
        if let prop = values[name]??.toString() {
            return prop
        }
        return `default`
    }

    func getStringOrNil(name: String) -> String? {
        values[name]??.toString()
    }

    func getNumber(name: String, `default`: Int = 0) -> Int {
        if let prop = values[name]??.toInt() {
            return prop
        }
        return `default`
    }

    func getNumberOrNil(name: String) -> Int? {
        values[name]??.toInt()
    }

    func getBoolean(name: String, `default`: Bool = false) -> Bool {
        if let prop = values[name]??.toBool() {
            return prop
        }
        return `default`
    }

    func getBooleanOrNil(name: String) -> Bool? {
        values[name]??.toBool()
    }

    func getChildren() -> [SolidNativeView] {
        children
    }

    func getPropAsJSValue(name: String) -> JSValue? {
        values[name] ?? nil
    }

    func callCallbackWithArgs(name: String, args: [Any]) {
        if let callback = getPropAsJSValue(name: name) {
            _ = callback.call(withArguments: args)
        }
    }

    func debugPrint() {
        #if DEBUG
            print("children:")
            for child in children {
                print("\tid: \(child.id.uuidString), name: \(child.getName())")
            }
            print("props:")
            for k in keys {
                print("\tkey: \(k), value: \(values[k]??.toString() ?? "nil")")
            }
        #endif
    }
}
