//
//  SNButtonView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNButtonView: SolidNativeView {
    
    class override var name: String {
        "sn_button"
    }
    
    struct SNButton: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?

        func onPress() {
            if let callback = props.getPropAsJSValue(name: "onPress") {
                callback.call(withArguments: nil)
            }
        }
        
        var body: some View {
            let title = props.getString(name: "title")
            let _role = props.getString(name: "role")
            let role: ButtonRole? = _role == "cancel" ? .cancel : (_role == "destructive" ? .destructive : nil)
            let children = props.getChildren()
            var view: AnyView
            if children.count == 0 {
                view = AnyView(
                    Button(title, role: role) {
                        onPress()
                    }
                )
            } else {
                view = AnyView(
                    Button(role: role) {
                        onPress()
                    } label: {
                        ForEach(children, id: \.id) { child in
                            child.render()
                        }
                    }
                )
            }
            return view.solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
        }
    }
    
    
    override func render() -> AnyView {
        AnyView(SNButton(props: self.props, owner: self))
    }
    
}
