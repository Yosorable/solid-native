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
    @Namespace private var namespace
    
    init() {
        // MARK: todo: 每次使用不同的viewManager, 这样延迟清除view也不会出现问题
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
                    let btn1 = Button {
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
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 23)).frame(width: 41, height: 41)
                    }
                    let btn2 = Button {
                        dismiss()
                        SolidNativeCore.shared.jsContext.evaluateScript("cleanAllPages()")
                        
                        // 还会触发渲染, 延迟回收节点
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            SolidNativeCore.shared.renderer.viewManager.clearAll()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 23)).frame(width: 41, height: 41)
                    }

                    HStack(spacing: 5) {
                        btn1
                        Divider().frame(height: 41)
                        btn2
                    }.background(Color.primary.opacity(0.5).blur(radius: 50).clipShape(RoundedRectangle(cornerRadius: 20)))
                }
                .padding(.trailing)
                Spacer()
            }
        }
    }
}
