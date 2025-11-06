//
//  SolidNativeModule.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import JavaScriptCore

class SolidNativeModule {
    let jsContext = SolidNativeCore.shared.jsContext
    let id = UUID()
    class var name: String {
        "SolidNativeModule"
    }

    required init() {
    }

    func getJSValueRepresentation() -> JSValue {
        return JSValue(undefinedIn: jsContext)
    }
}
