//
//  SNSpacer.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNSpacer: SolidNativeView {
    
    class override var name: String {
        "sn_spacer"
    }
    
    struct SNSpacer: View {
                @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView
        
        var body: some View {
            let minLength = props.getNumber(name: "minLenght", default: -1)
            Spacer(minLength: minLength == -1 ? nil : minLength.doubleValue)
                .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
            
        }
    }
    
    override func render() -> AnyView {
        return AnyView(SNSpacer(props: self.props, owner: self))
    }
    
}

