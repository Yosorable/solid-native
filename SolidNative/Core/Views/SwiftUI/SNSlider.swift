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
        weak var owner: SolidNativeView?
        @State var tmpVal: Double = 0

        func onEditingChanged(editing: Bool) {
            props.callCallbackWithArgs(
                name: "onEditingChanged",
                args: [editing]
            )
        }

        var body: some View {
            let maxValue = props.getNumber(name: "maxValue", default: 100)
                .doubleValue
            let minValue = props.getNumber(name: "minValue", default: 0)
                .doubleValue
            let bd = Binding<Double>(
                get: {
                    props.getNumberOrNil(name: "value")?.doubleValue ?? tmpVal
                },
                set: { val in
                    props.callCallbackWithArgs(name: "onChange", args: [val])
                    tmpVal = val
                }
            )

            if let step = props.getNumberOrNil(name: "step") {
                Slider(
                    value: bd,
                    in: minValue...maxValue,
                    step: step.doubleValue,
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
