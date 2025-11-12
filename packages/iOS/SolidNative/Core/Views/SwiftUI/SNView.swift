//
//  SNView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNView: SolidNativeView {
    class override var name: String {
        "sn_view"
    }

    struct _SNView: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView

        var body: some View {
            let children = props.getChildren()
            VStack {
                ForEach(children, id: \.id) { child in
                    child.render()
                }
            }
            .solidNativeViewModifiers(
                mods: [props.values],
                keys: props.keys,
                owner: owner
            )
        }
    }

    override func render() -> AnyView {
        return AnyView(_SNView(props: self.props, owner: self))
    }

}
