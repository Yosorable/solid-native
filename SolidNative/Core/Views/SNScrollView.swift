//
//  SNScrollView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI
//import SwiftUIIntrospect

class SNScrollView: SolidNativeView {
    
    class override var name: String {
        "sn_scrollview"
    }
    
    struct _SNVScrollView: View {
                @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView
        
        var body: some View {
            let children = props.getChildren()
            ScrollView {
                ForEach(children, id: \.id) { child in
                    child.render()
                }
            }
            .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
        }
    }
    
    override func render() -> AnyView {
        return AnyView(_SNVScrollView(props: self.props, owner: self))
    }
    
}
