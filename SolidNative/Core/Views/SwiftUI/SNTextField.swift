//
//  SNTextField.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNTextField: SolidNativeView {
    class override var name: String {
        "sn_textfield"
    }

    struct SNTextField: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?

        var body: some View {
            let placeholder = props.getString(name: "placeholder")

            TextField(
                placeholder,
                text: Binding<String>(
                    get: {
                        props.getString(name: "text")
                    },
                    set: { val in
                        props.callCallbackWithArgs(
                            name: "onChange",
                            args: [val]
                        )
                    }
                )
            )
            .solidNativeViewModifiers(
                mods: [props.values],
                keys: props.keys,
                owner: owner
            )

        }
    }

    override func render() -> AnyView {
        return AnyView(SNTextField(props: self.props, owner: self))
    }
}
