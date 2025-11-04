//
//  SNSecureField.swift
//  SolidNative
//
//  Created by LZY on 2024/5/4.
//

import Foundation
import SwiftUI

class SNSecureField: SolidNativeView {
    
    class override var name: String {
        "sn_securefield"
    }
    
    struct SNSecureField: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView
        

        var body: some View {
            let placeholder = props.getString(name: "placeholder")
            
            SecureField(placeholder, text: Binding<String>(
                get: {
                    props.getString(name: "text")
                },
                set: { val in
                    props.callCallbackWithArgs(name: "onChange", args: [val])
                }
            ))
            .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
            
        }
    }
    
    override func render() -> AnyView {
        return AnyView(SNSecureField(props: self.props, owner: self))
    }
}
