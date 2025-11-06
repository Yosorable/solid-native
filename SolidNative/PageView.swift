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
    let core: SolidNativeCore
    let root: SolidNativeView

    init() {
        core = SolidNativeCore()
        core.runApp()
        if core.getRootView().children.count == 1 {
            root = core.getRootView().children[0]
        } else {
            root = core.getRootView()
        }
    }

    var body: some View {
        ZStack {
            root.render()
    
            VStack {
                HStack {
                    Spacer()
                    let btn1 = Button {
                        core.renderer.viewManager.debugPrint()
                    } label: {
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 23)).frame(
                                width: 41,
                                height: 41
                            )
                    }
                    let btn2 = Button {
                        dismiss()
                        core.jsContext.evaluateScript(
                            "cleanAllPages()"
                        )

                        // 还会触发渲染, 延迟回收节点
                        DispatchQueue.global(qos: .background).asyncAfter(
                            deadline: .now() + 1
                        ) {
                            self.core.renderer.viewManager.clearAll()
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
