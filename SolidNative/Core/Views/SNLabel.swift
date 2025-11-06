//
//  SNLabel.swift
//  SolidNative
//
//  Created by LZY on 2024/5/14.
//

import Foundation
import SwiftUI

class SNLabel: SolidNativeView {
    class override var name: String {
        "sn_label"
    }

    struct SNLabel: View {

        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?

        var body: some View {
            let title = props.getString(name: "title")
            let systemImage = props.getString(name: "systemImage")
            Label(title, systemImage: systemImage)
                .solidNativeViewModifiers(
                    mods: [props.values],
                    keys: props.keys,
                    owner: owner
                )
        }
    }

    override func render() -> AnyView {
        AnyView(SNLabel(props: self.props, owner: self))
    }
}
