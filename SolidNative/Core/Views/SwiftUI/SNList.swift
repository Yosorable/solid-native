//
//  SNList.swift
//  SolidNative
//
//  Created by LZY on 2024/5/12.
//

import Foundation
import SwiftUI

class SNList: SolidNativeView {
    class override var name: String {
        "sn_list"
    }

    struct SNList: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView

        var body: some View {
            let children = props.getChildren()
            let _listStyle = props.getString(name: "listStyle", default: "")
            var listStyle: any ListStyle = DefaultListStyle.automatic
            if _listStyle == "grouped" {
                listStyle = GroupedListStyle.grouped
            } else if _listStyle == "inset" {
                listStyle = InsetListStyle.inset
            } else if _listStyle == "insetGrouped" {
                listStyle = InsetGroupedListStyle.insetGrouped
            } else if _listStyle == "plain" {
                listStyle = PlainListStyle.plain
            } else if _listStyle == "sidebar" {
                listStyle = SidebarListStyle.sidebar
            }

            return AnyView(
                List {
                    ForEach(children, id: \.id) { child in
                        child.render()
                    }
                }
                .listStyle(listStyle)
            )
            .solidNativeViewModifiers(
                mods: [props.values],
                keys: props.keys,
                owner: owner
            )

        }
    }

    override func render() -> AnyView {
        return AnyView(SNList(props: self.props, owner: self))
    }
}
