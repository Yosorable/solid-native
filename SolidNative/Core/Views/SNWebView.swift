//
//  SNWebView.swift
//  SolidNative
//
//  Created by LZY on 2025/11/5.
//

import SwiftUI
import WebKit

@available(iOS 26.0, *)
class SNWebView: SolidNativeView {
    class override var name: String {
        "sn_webview"
    }
    
    struct SNWebView: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?
        @State private var page: WebPage
        
        init(props: SolidNativeProps, owner: SolidNativeView? = nil) {
            self.props = props
            self.owner = owner
            
            var config = WebPage.Configuration()
            config.upgradeKnownHostsToHTTPS = false

            self.page = WebPage(configuration: config)
            if let html = props.getStringOrNil(name: "html") {
                page.load(html: html)
            } else if let url = props.getStringOrNil(name: "url"), let u = URL(string: url) {
                page.load(u)
            } else if let file = props.getStringOrNil(name: "file"), let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let target = base.appending(path: file)
                page.load(target)
            }
        }

        var body: some View {
            WebView(page)
                .webViewBackForwardNavigationGestures(.disabled)
                .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
        }
    }
    
    override func render() -> AnyView {
        return AnyView(SNWebView(props: props, owner: self))
    }
}
