//
//  PageView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/4.
//

import ECMASwift
import SwiftUI

struct RootPageView: View {
    @Environment(\.dismiss) var dismiss
    @Namespace private var namespace

    init() {
        SolidNativeCore.shared = SolidNativeCore()
        SolidNativeCore.shared.jsRuntime = JSRuntime()
        SolidNativeCore.shared.renderer = SNRender(
            core: SolidNativeCore.shared,
            vm: ViewManager()
        )

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
                        let rootId = SolidNativeCore.shared.rootElement.id
                            .uuidString
                        for (k, v) in SolidNativeCore.shared.renderer
                            .viewManager.createdViewRegistry
                        {
                            let address = Unmanaged.passUnretained(v).toOpaque()
                            let retainCount = CFGetRetainCount(v as CFTypeRef)
                            print(
                                "id: \(k), name: \(v.getName()), ref: \(retainCount), address: \(address)  \(k == rootId ? "[root]" : "")"
                            )
                        }
                        withUnsafePointer(
                            to: &SolidNativeCore.shared.renderer.viewManager
                                .createdViewRegistry
                        ) { pointer in
                            print("字典内存地址: \(pointer)")
                        }
                    } label: {
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 23)).frame(
                                width: 41,
                                height: 41
                            )
                    }
                    let btn2 = Button {
                        dismiss()
                        SolidNativeCore.shared.jsContext.evaluateScript(
                            "cleanAllPages()"
                        )

                        // 还会触发渲染, 延迟回收节点
                        let renderer = SolidNativeCore.shared.renderer!
                        DispatchQueue.global(qos: .background).asyncAfter(
                            deadline: .now() + 1
                        ) {
                            renderer.viewManager.clearAll()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 23)).frame(
                                width: 41,
                                height: 41
                            )
                    }

                    HStack(spacing: 5) {
                        btn1
                        Divider().frame(height: 41)
                        btn2
                    }.background(
                        Color.primary.opacity(0.5).blur(radius: 50).clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )
                    )
                }
                .padding(.trailing)
                Spacer()
            }
        }
    }
}
