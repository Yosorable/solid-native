//
//  SNWebImage.swift
//  SolidNative
//
//  Created by LZY on 2024/5/12.
//

import Foundation
import SDWebImageSwiftUI
import SwiftUI

class SNWebImage: SolidNativeView {
    class override var name: String {
        "sn_webimage"
    }

    struct SNWebImage: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?

        var body: some View {
            let src = props.getString(name: "src")
            let placeholder = props.getPropAsJSValue(name: "placeholder")
            // image
            let resizable = props.getBoolean(name: "resizable", default: false)
            let aspectRatio = props.getString(name: "aspectRatio", default: "")
            let fade = props.getNumberOrNil(name: "fade")

            var res: AnyView
            if placeholder?.isObject == true,
                let id = placeholder?.forProperty("id").toString()
            {
                res = AnyView(
                    WebImage(
                        url: URL(string: src),
                        content: { image in
                            var res: AnyView
                            if resizable {
                                let _ = (res = AnyView(image.resizable()))
                            } else {
                                let _ = (res = AnyView(image))
                            }
                            if aspectRatio == "fit" || aspectRatio == "fill" {
                                let _ =
                                    (res = AnyView(
                                        res.aspectRatio(
                                            contentMode: aspectRatio == "fit"
                                                ? .fit : .fill
                                        )
                                    ))
                            }

                            if fade != nil && fade as! Double > 0.0 {
                                AnyView(
                                    res.transition(
                                        .opacity.animation(
                                            .easeIn(duration: fade as! Double)
                                        )
                                    )
                                )
                            } else {
                                res
                            }

                        },
                        placeholder: {
                            if let node = owner?.vm.getViewById(id) {
                                let _ = owner?.indirectChildren.append(node)
                                node.render()
                            }
                        }
                    )
                )
            } else {
                res = AnyView(
                    WebImage(
                        url: URL(string: src),
                        content: { image in
                            var res: AnyView
                            if resizable {
                                let _ =
                                    (res = AnyView(image.image?.resizable()))
                            } else {
                                let _ = (res = AnyView(image.image))
                            }
                            if aspectRatio == "fit" || aspectRatio == "fill" {
                                let _ =
                                    (res = AnyView(
                                        res.aspectRatio(
                                            contentMode: aspectRatio == "fit"
                                                ? .fit : .fill
                                        )
                                    ))
                            }

                            if fade != nil && fade as! Double > 0.0 {
                                AnyView(
                                    res.transition(
                                        .opacity.animation(
                                            .easeIn(duration: fade as! Double)
                                        )
                                    )
                                )
                            } else {
                                res
                            }

                        }
                    )
                )
            }
            return
                res
                .solidNativeViewModifiers(
                    mods: [props.values],
                    keys: props.keys,
                    owner: owner
                )
        }
    }

    override func render() -> AnyView {
        AnyView(SNWebImage(props: self.props, owner: self))
    }
}
