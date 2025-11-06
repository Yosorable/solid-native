//
//  SNRectangle.swift
//  SolidNative
//
//  Created by LZY on 2024/5/4.
//

import Foundation
import SwiftUI

class SNRectangle: SolidNativeView {
    class override var name: String {
        "sn_rectangle"
    }

    struct SNRectangle: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?

        var body: some View {
            let fill = getColor(props.getString(name: "fill", default: ""))
            Rectangle()
                .fill(fill)
                .solidNativeViewModifiers(
                    mods: [props.values],
                    keys: props.keys,
                    owner: owner
                )
        }
    }

    override func render() -> AnyView {
        return AnyView(SNRectangle(props: self.props, owner: self))
    }
}
