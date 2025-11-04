//
//  SNAsyncImage.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNAsyncImage: SolidNativeView {
    
    class override var name: String {
        "sn_async_image"
    }
    
    struct SNAsyncImage: View {
                @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView
        
        var body: some View {
            let src = props.getString(name: "src")
            let placeholder = props.getPropAsJSValue(name: "placeholder")
            // image
            let resizable = props.getBoolean(name: "resizable", default: false)
            let aspectRatio = props.getString(name: "aspectRatio", default: "")
            let fade = props.getNumberOrNil(name: "fade")
            
            var res: AnyView
            if placeholder?.isObject == true, let id = placeholder?.forProperty("id").toString() {
                res = AnyView(
                    AsyncImage(
                        url: URL(string: src),
                        content: { image in
                            var res:AnyView
                            if resizable {
                              let _ = (res = AnyView(image.resizable()))
                            } else {
                                let _ = (res = AnyView(image))
                            }
                            if aspectRatio == "fit" || aspectRatio == "fill" {
                                let _ = ( res = AnyView(res.aspectRatio(contentMode: aspectRatio == "fit" ? .fit : .fill)))
                            }
                            
                            if fade != nil && fade as! Double > 0.0 {
                                AnyView(res.transition(.opacity.animation(.easeIn(duration: fade as! Double))))
                            } else {
                                res
                            }
                            
                        },
                        placeholder: {
                            vm.getViewById(id).render()
                        }
                    )
                )
            } else {
                res = AnyView(
                    AsyncImage(
                        url: URL(string: src),
                        content: { image in                            
                            var res:AnyView
                            if resizable {
                                let _ = (res = AnyView(image.image?.resizable()))
                            } else {
                                let _ = (res = AnyView(image.image))
                            }
                            if aspectRatio == "fit" || aspectRatio == "fill" {
                                let _ = ( res = AnyView(res.aspectRatio(contentMode: aspectRatio == "fit" ? .fit : .fill)))
                            }
                            
                            if fade != nil && fade as! Double > 0.0 {
                                AnyView(res.transition(.opacity.animation(.easeIn(duration: fade as! Double))))
                            } else {
                                res
                            }
                            
                        }
                    )
                )
            }
            return res
                .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
        }
    }
    
    
    override func render() -> AnyView {
        AnyView(SNAsyncImage(props: self.props, owner: self))
    }
    
}

