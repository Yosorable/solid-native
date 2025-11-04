//
//  PageView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/4.
//

import SwiftUI


class Route: ObservableObject {
    @Published var routes: [String] = []
    static let shared = Route()
}

struct RootPageView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var route = Route.shared
    
    init() {
        SolidNativeCore.shared = SolidNativeCore()
        SolidNativeCore.shared.runApp()
    }
    
    var body: some View {
        return  ZStack {
            if SolidNativeCore.shared.rootElement.children.count == 1 {
                SolidNativeCore.shared.rootElement.children.first?.render()
            } else {
                SolidNativeCore.shared.rootElement.render()
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                        let root = SolidNativeCore.shared.rootElement
                        SolidNativeCore.shared.jsContext.evaluateScript("cleanPage('\(root.id.uuidString)')")
                        vm.removePageByRoot(root)

                        // MARK: TODO
                        SolidNativeCore.shared.rootElement = SNView()
                        
                        for (k, v) in vm.createdViewRegistry {
                            print("id: \(k), name: \(v.getName()), parent: \(v.parentElement?.getName() ?? "no")")
                            
                            for (a, b) in v.props.values {
                                print("\t\(a): \(b?.toString() ?? "nil")")
                            }
                        }
                        
                    } label: {
                        Text("close")
                    }
                }
                Spacer()
            }
        }
        
        
        NavigationStack(path: $route.routes) {
            SolidNativeCore.shared.rootElement.render()
                .toolbar {
                    Button {
                        dismiss()
                        let last = SolidNativeCore.shared.rootElement
                        SolidNativeCore.shared.jsContext.evaluateScript("cleanPage('\(last.id.uuidString)')")
                        vm.removePageById(last.id.uuidString)
                    } label: {
                        Text("close")
                    }
                }
                .navigationDestination(for: String.self) { id in
                    if SolidNativeCore.shared.navigationStack.last?.id.uuidString == id {
                        SolidNativeCore.shared.navigationStack.last!.render()
//                            .navigationTitle(Text("Page"))
//                            .navigationBarTitleDisplayMode(.inline)
                    } else {
                        let _ = print(id)
                        Text("page not found")
                            .navigationTitle(Text("Error"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .onChange(of: route.routes) { newVal in
                    let cnt = SolidNativeCore.shared.navigationStack.count
                    if newVal.count < cnt {
                        let removeCnt = cnt - newVal.count
                        print("now count: \(cnt), remove \(removeCnt)")
                        var toDel = [SNView]()
                        for _ in 0..<removeCnt {
                            let last = SolidNativeCore.shared.navigationStack.removeLast()
                            toDel.append(last)
                        }
                        for i in 0..<removeCnt {
                            let last = toDel[i]
                            SolidNativeCore.shared.jsContext.evaluateScript("cleanPage('\(last.id.uuidString)')")
                            vm.removePageById(last.id.uuidString)
                        }
                    } else {
                        print("push")
                    }
                }
        }
    }
}
