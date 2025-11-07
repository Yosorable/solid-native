//
//  SNNavigationStack.swift
//  SolidNative
//
//  Created by LZY on 2025/11/3.
//

import QuickJS
import SwiftUI

struct NavigationRouteParam: Hashable {
    let name: String
    let id: String
}

class SNNavigationStack: SolidNativeView {
    class override var name: String {
        "sn_navigationstack"
    }

    struct SNNavigationStack: View {
        @ObservedObject var props: SolidNativeProps
        let owner: SolidNativeView
        @State var path: [NavigationRouteParam]

        init(props: SolidNativeProps, owner: SolidNativeView) {
            self.props = props
            if let newVal = props.getPropAsJSValue(name: "path"),
                newVal.isArray == true,
                let cnt = newVal.forProperty("length")?.toInt(),
                let destFunc = props.getPropAsJSValue(
                    name: "navigationDestination"
                )
            {
                var newPath = [NavigationRouteParam]()
                for i in 0..<cnt {
                    if let name = newVal.atIndex(i).toString(),
                        let node = destFunc.call(withArguments: [name]),
                        node.isObject,
                        let id = node.forProperty("id").toString()
                    {
                        newPath.append(NavigationRouteParam(name: name, id: id))
                    }
                }
                path = newPath
            } else {
                path = []
            }

            self.owner = owner
        }

        func onChangeByNative(
            oldVal: [NavigationRouteParam],
            newVal: [NavigationRouteParam]
        ) {
            if let callback = props.getPropAsJSValue(name: "onPathChange") {
                callback.call(withArguments: [newVal.map { $0.name }])
            }

            var toRelease = [String: Bool]()

            oldVal.forEach { toRelease[$0.id] = true }
            newVal.forEach { toRelease[$0.id] = false }

            let toDelIds = toRelease.filter { $0.value }.map { $0.key }

            toDelIds.forEach { id in
                owner.vm.jsContext.evaluateScript(
                    "cleanPage(\"\(id)\")"
                )
                owner.vm.removePageByRoot(id)
            }
        }

        func onChangeByJS(oldVal: JSValue?, newVal: JSValue?) {
            guard newVal?.isArray == true,
                let val = newVal,
                let cnt = val.forProperty("length")?.toInt(),
                let destFunc = props.getPropAsJSValue(
                    name: "navigationDestination"
                )
            else { return }
            var breakIdx = 0
            let mx = min(self.path.count, cnt)

            for i in 0..<mx {
                if val.atIndex(i).toString() != self.path[i].name {
                    break
                }
                breakIdx += 1
            }
            var newPath = Array(self.path[0..<breakIdx])
            for i in breakIdx..<cnt {

                if let name = val.atIndex(i).toString(),
                    let node = destFunc.call(withArguments: [name]),
                    node.isObject,
                    let id = node.forProperty("id").toString()
                {
                    newPath.append(
                        NavigationRouteParam(name: name, id: id)
                    )
                }
            }
            self.path = newPath
        }

        var body: some View {
            return NavigationStack(path: $path) {
                ForEach(props.getChildren(), id: \.id) { child in
                    child.render()
                }
                .onChange(of: path) { onChangeByNative(oldVal: $0, newVal: $1) }
                .onChange(of: props.getPropAsJSValue(name: "path")) {
                    onChangeByJS(oldVal: $0, newVal: $1)
                }
                .navigationDestination(for: NavigationRouteParam.self) { item in
                    if item.id != "" {
                        let node = owner.vm.getViewById(item.id)

                        if node.children.count == 1 {
                            node.firstChild?.render()
                        } else {
                            node.render()
                        }
                    } else {
                        Text("Page not found").navigationTitle(Text("404"))
                            .toolbarTitleDisplayMode(.inline)
                    }
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
        AnyView(SNNavigationStack(props: self.props, owner: self))
    }
}
