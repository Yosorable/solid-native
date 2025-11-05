//
//  SNNavigationLink.swift
//  SolidNative
//
//  Created by LZY on 2025/11/4.
//

import SwiftUI

class SNNavigationLink: SolidNativeView {
    class override var name: String {
        "sn_navigationlink"
    }
    
    struct SNNavigationLink: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?

        var body: some View {
            if let dest = props.getPropAsJSValue(name: "destination"), let callRes = dest.call(withArguments: nil), callRes.isObject, callRes.hasProperty("id"), let id = callRes.forProperty("id").toString() {
                NavigationLink(destination: {
                    // LazyView(vm.getViewById(id).render())
                    LazyView(SolidNativeCore.shared.renderer.viewManager.getViewById(id).render())
                }, label: {
                    ForEach(props.children, id: \.id) {
                        $0.render()
                    }
                })
            } else {
                NavigationLink(destination: {
                    Text("Page not found").navigationTitle(Text("404")).toolbarTitleDisplayMode(.inline)
                }, label: {
                    ForEach(props.children, id: \.id) {
                        $0.render()
                    }
                })
            }
        }
    }
    
    override func render() -> AnyView {
        AnyView(SNNavigationLink(props: self.props, owner: self))
    }
}
