//
//  SNToggle.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNToggle: SolidNativeView {
    
    class override var name: String {
        "sn_toggle"
    }
    
    struct SNToggle: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?
        @State var tmpVal = false


        var body: some View {
            let label = props.getString(name: "label")
            return Toggle(label, isOn: Binding<Bool>(
                get: {
                    props.getBooleanOrNil(name: "value") ?? tmpVal
                },
                set: { val in
                    props.callCallbackWithArgs(name: "onChange", args: [val])
                    tmpVal = val
                }
            ))
            .toggleStyle(.switch)
            .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
        }
    }
    
    
    override func render() -> AnyView {
        AnyView(SNToggle(props: self.props, owner: self))
    }
    
}

