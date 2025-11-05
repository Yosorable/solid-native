//
//  PageView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/4.
//

import SwiftUI
import ECMASwift

struct RootPageView: View {
    @Environment(\.dismiss) var dismiss
    
    init() {
        if SolidNativeCore.shared == nil {
            SolidNativeCore.shared = SolidNativeCore()
            SolidNativeCore.shared.jsRuntime = JSRuntime()
            SolidNativeCore.shared.renderer = SNRender(core: SolidNativeCore.shared, vm: ViewManager())
        } else {
            let newRoot = SNView()
            SolidNativeCore.shared.rootElement = newRoot
            SolidNativeCore.shared.renderer.viewManager.createdViewRegistry[newRoot.id.uuidString] = newRoot
        }
        SolidNativeCore.shared.runApp()
    }
    
    var body: some View {
        ZStack {
            if SolidNativeCore.shared.rootElement.children.count == 1 {
                SolidNativeCore.shared.rootElement.children.first?.render()
            } else {
                SolidNativeCore.shared.rootElement.render()
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        let rootId = SolidNativeCore.shared.rootElement.id.uuidString
                        for (k, v) in SolidNativeCore.shared.renderer.viewManager.createdViewRegistry {
                            let address = Unmanaged.passUnretained(v).toOpaque()
                            let retainCount = CFGetRetainCount(v as CFTypeRef)
                            print("id: \(k), name: \(v.getName()), ref: \(retainCount), address: \(address)  \(k == rootId ? "[root]" : "")")
                        }
                        withUnsafePointer(to: &SolidNativeCore.shared.renderer.viewManager.createdViewRegistry) { pointer in
                            print("字典内存地址: \(pointer)")
                        }
                    } label: {
                        Text("debug")
                    }
                    Button {
                        dismiss()
                        let root = SolidNativeCore.shared.rootElement
                        SolidNativeCore.shared.jsContext.evaluateScript("cleanPage('\(root.id.uuidString)')")
                        SolidNativeCore.shared.renderer.viewManager.removePageByRoot(root)

                        // MARK: TODO
                        SolidNativeCore.shared.rootElement = SNView()
                        
                        for (k, v) in SolidNativeCore.shared.renderer.viewManager.createdViewRegistry {
                            
                            let address = Unmanaged.passUnretained(v).toOpaque()
                            print("id: \(k), name: \(v.getName()), parent: \(v.parentElement?.getName() ?? "no"), address: \(address)")
                            
                            for (a, b) in v.props.values {
                                print("\t\(a): \(b?.toString() ?? "nil")")
                            }
                        }
                        
                    } label: {
                        Text("close")
                    }
                }.padding(.trailing)
                Spacer()
            }
        }
    }
}
