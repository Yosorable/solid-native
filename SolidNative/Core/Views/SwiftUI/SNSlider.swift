//
//  Slider.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNSlider: SolidNativeView {
    class override var name: String {
        "sn_slider"
    }

    struct SNSlider: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView
        @State var tmpVal: Double = 0

        func onEditingChanged(editing: Bool) {
            props.callCallbackWithArgs(
                name: "onEditingChanged",
                args: [editing]
            )
        }

        var body: some View {
            let maxValue = props.getPropAsJSValue(name: "maxValue")?.toDouble() ?? 100
            let minValue = props.getPropAsJSValue(name: "minValue")?.toDouble() ?? 0
            let bd = Binding<Double>(
                get: {
                    props.getPropAsJSValue(name: "value")?.toDouble() ?? tmpVal
                },
                set: { val in
                    props.callCallbackWithArgs(name: "onChange", args: [val])
                    tmpVal = val
                }
            )

            if let step = props.getPropAsJSValue(name: "step")?.toDouble() {
                Slider(
                    value: bd,
                    in: minValue...maxValue,
                    step: step,
                    onEditingChanged: onEditingChanged
                ).solidNativeViewModifiers(
                    mods: [props.values],
                    keys: props.keys,
                    owner: owner
                )
            } else {
                Slider(
                    value: bd,
                    in: minValue...maxValue,
                    onEditingChanged: onEditingChanged
                ).solidNativeViewModifiers(
                    mods: [props.values],
                    keys: props.keys,
                    owner: owner
                )
            }
        }
    }

    override func render() -> AnyView {
        return AnyView(SNSlider(props: self.props, owner: self))
    }
}
