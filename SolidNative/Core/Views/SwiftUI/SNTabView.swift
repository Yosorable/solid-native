//
//  SNTabView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/14.
//

import Foundation
import JavaScriptCore
import SwiftUI

struct SNTabChild: View {
    var content: JSValue?
    var id: String?
    var node: SolidNativeView?
    init(content: JSValue?, onAddTab: (String) -> Void, vm: ViewManager?) {
        self.content = content
        id = content?.call(withArguments: []).forProperty("id")!.toString()
        if let id = id, let vm = vm {
            onAddTab(id)
            node = vm.getViewById(id)
        }
    }
    var body: some View {
        if let node = node {
            node.render()
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
        let onAddTab: (String) -> Void
        weak var owner: SolidNativeView?

        var body: some View {
            let tabs = props.getPropAsJSValue(name: "tabs")
            let cnt = tabs?.toArray().count ?? 0
            TabView {
                ForEach(0..<cnt, id: \.self) { idx in
                    LazyView(
                        // fix 多次加载问题
                        ZStack {
                            SNTabChild(
                                content: tabs?.atIndex(idx).forProperty(
                                    "content"
                                ),
                                onAddTab: onAddTab,
                                vm: owner?.vm
                            )
                        }
                    ).tabItem {
                        if let id = tabs?.atIndex(idx).forProperty("tabItem")
                            .forProperty("id").toString(),
                            let v = owner?.vm.getViewById(id)
                        {

                            let _ = owner?.indirectChildren.append(v)
                            v.render()
                        }
                    }
                    .tag(idx)

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
        AnyView(
            SNTabView(props: self.props, onAddTab: self.onAddTab, owner: self)
        )
    }
}
