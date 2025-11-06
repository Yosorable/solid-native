//
//  SNStack.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import SwiftUI

class SNVStack: SolidNativeView {
    class override var name: String {
        "sn_vstack"
    }

    struct SNVStack: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView

        var body: some View {
            let children = props.getChildren()
            let spacing = props.getNumberOrNil(name: "spacing")
            var sp: CGFloat? = nil
            if let spacing = spacing {
                sp = spacing.doubleValue
            }

            let alignment =
                anyToHorizontalAlignment(
                    props.getString(name: "alignment", default: "")
                ) ?? .center

            return VStack(alignment: alignment, spacing: sp) {
                ForEach(children, id: \.id) { child in
                    child.render()
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
        return AnyView(SNVStack(props: self.props, owner: self))
    }
}

class SNHStack: SolidNativeView {
    class override var name: String {
        "sn_hstack"
    }

    struct SNHStack: View {
        @ObservedObject var props: SolidNativeProps
        //        let parentNodeID: String
        let owner: SolidNativeView

        var body: some View {
            let children = props.getChildren()
            let spacing = props.getNumberOrNil(name: "spacing")
            var sp: CGFloat? = nil
            if let spacing = spacing {
                sp = spacing.doubleValue
            }

            let alignment =
                anyToVerticalAlignment(
                    props.getString(name: "alignment", default: "")
                ) ?? .center
            return HStack(alignment: alignment, spacing: sp) {
                ForEach(children, id: \.id) { child in
                    child.render()
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
        return AnyView(SNHStack(props: self.props, owner: self))
    }
}

class SNZStack: SolidNativeView {
    class override var name: String {
        "sn_zstack"
    }

    struct SNZStack: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView

        var body: some View {
            let children = props.getChildren()

            let alignment =
                anyToAlignment(props.getString(name: "alignment", default: ""))
                ?? .center
            ZStack(alignment: alignment) {
                ForEach(children, id: \.id) { child in
                    child.render()
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
        return AnyView(SNZStack(props: self.props, owner: self))
    }
}

class SNLazyVStack: SolidNativeView {
    class override var name: String {
        "sn_lazy_vstack"
    }

    struct SNLazyVStack: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView

        var body: some View {
            let children = props.getChildren()
            let spacing = props.getNumberOrNil(name: "spacing")
            var sp: CGFloat? = nil
            if let spacing = spacing {
                sp = spacing.doubleValue
            }

            let alignment =
                anyToHorizontalAlignment(
                    props.getString(name: "alignment", default: "")
                ) ?? .center
            return LazyVStack(alignment: alignment, spacing: sp) {
                ForEach(children, id: \.id) { child in
                    child.render()
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
        return AnyView(SNLazyVStack(props: self.props, owner: self))
    }
}

class SNLazyHStack: SolidNativeView {
    class override var name: String {
        "sn_lazy_hstack"
    }

    struct SNLazyHStack: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView

        var body: some View {
            let children = props.getChildren()
            let spacing = props.getNumberOrNil(name: "spacing")
            var sp: CGFloat? = nil
            if let spacing = spacing {
                sp = spacing.doubleValue
            }

            let alignment =
                anyToVerticalAlignment(
                    props.getString(name: "alignment", default: "")
                ) ?? .center
            return LazyHStack(alignment: alignment, spacing: sp) {
                ForEach(children, id: \.id) { child in
                    child.render()
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
        return AnyView(SNLazyHStack(props: self.props, owner: self))
    }
}
