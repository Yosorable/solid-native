//
//  SNTextView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNTextView: SolidNativeView {

    class override var name: String {
        "sn_text"
    }

    override var isTextElement: Bool {
        true
    }

    struct SNTextView: View {

                @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView

        var body: some View {
            let text = props.getString(name: "text")
            Text(text)
                .solidNativeViewModifiers(
                    mods: [props.values],
                    keys: props.keys,
                    owner: owner
                )
        }
    }

    override func render() -> AnyView {
        AnyView(SNTextView(props: self.props, owner: self))
    }

}
