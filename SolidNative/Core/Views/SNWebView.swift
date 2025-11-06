//
//  SNWebView.swift
//  SolidNative
//
//  Created by LZY on 2025/11/5.
//

import SwiftUI
import WebKit

class SNWebView: SolidNativeView {
    class override var name: String {
        "sn_webview"
    }
    
    struct SNWebView: View {
        @ObservedObject var props: SolidNativeProps
        weak var owner: SolidNativeView?
        @ObservedObject var webViewController: WebViewController
        
        init(props: SolidNativeProps, owner: SolidNativeView? = nil, webViewController: WebViewController) {
            self.props = props
            self.owner = owner
            self.webViewController = webViewController
        }
        
        @State var isLoading = false

        var body: some View {
            MWebView(webViewController: webViewController)
                .ignoresSafeArea(.all)
                .onChange(of: webViewController.isLoading) { _, val in
                    guard let fn = props.getPropAsJSValue(name: "onLoadingChanged"), fn.isObject else { return }
                    fn.call(withArguments: [val])
                }
                .solidNativeViewModifiers(mods: [props.values], keys: props.keys, owner: owner)
        }
    }
    
    lazy var webViewController: WebViewController = {
        return WebViewController()
    }()
    
    override func render() -> AnyView {
        return AnyView(SNWebView(props: props, owner: self, webViewController: webViewController))
    }
}
