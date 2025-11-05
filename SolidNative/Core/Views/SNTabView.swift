//
//  SNTabView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/14.
//

import Foundation
import SwiftUI
import JavaScriptCore

struct SNTabChild: View {
    var content: JSValue?
    var id: String?
    init(content: JSValue?, onAddTab: (String)->Void) {
        self.content = content
        id = content?.call(withArguments: []).forProperty("id")!.toString()
        print("init page: \(id)")
        if let id = id {
            onAddTab(id)
        }
    }
    var body: some View {
        if let id = id {
//            SolidNativeCore.shared.renderer.viewManager.getViewById(id).render()
            SolidNativeCore.shared.renderer.viewManager.getViewById(id).render()
        }
    }
}

class SNTabView: SolidNativeView {
    class override var name: String {
        "sn_tabview"
    }
    
    var tabIds: [String] = []

    func onAddTab(id: String) {
        tabIds.append(id)
    }
    
    struct SNTabView: View {
        @ObservedObject var props: SolidNativeProps
        let onAddTab: (String)->Void
        weak var owner: SolidNativeView?
        
        
        var body: some View {
            let tabs = props.getPropAsJSValue(name: "tabs")
            let cnt = tabs?.toArray().count ?? 0
            TabView {
                ForEach(0..<cnt, id: \.self) { idx in
                    LazyView (
                        // fix 多次加载问题
                        ZStack {
                            SNTabChild(content: tabs?.atIndex(idx).forProperty("content"), onAddTab: onAddTab)
                        }
                    ).tabItem {
                        if let id = tabs?.atIndex(idx).forProperty("tabItem").forProperty("id").toString() {
                            let v = SolidNativeCore.shared.renderer.viewManager.getViewById(id)
                            let _ = owner?.indirectChildren.append(v)
                            v.render()
                        }
                    }
                    .tag(idx)
                    
                }
            }
            .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
        }
    }
    
    override func render() -> AnyView {
        AnyView(SNTabView(props: self.props, onAddTab: self.onAddTab, owner: self))
    }
    
}
