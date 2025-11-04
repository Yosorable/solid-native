//
//  SNGrid.swift
//  SolidNative
//
//  Created by LZY on 2024/5/4.
//

import Foundation
import SwiftUI

class SNLazyVGrid: SolidNativeView {
    
    class override var name: String {
        "sn_lazy_vgrid"
    }
    
    struct SNLazyVGrid: View {
                @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView
        
        var body: some View {
            let children = props.getChildren()
            return LazyVGrid (
                columns: [GridItem(.adaptive(minimum: 100), spacing: 16)],
                spacing: 16) {
                    ForEach(children, id: \.id) { child in
                        child.render()
                    }
                }
                .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
            
        }
    }
    
    override func render() -> AnyView {
        return AnyView(SNLazyVGrid(props: self.props, owner: self))
    }
    
}

