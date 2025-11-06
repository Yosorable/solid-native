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

            if let url = props.getStringOrNil(name: "url"), let u = URL(string: url) {
                self.webViewController.load(URLRequest(url: u))
            } else if let file = props.getStringOrNil(name: "file"), let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let target = base.appending(path: file)
                self.webViewController.load(URLRequest(url: target))
            } else if let html = props.getStringOrNil(name: "html") {
                self.webViewController.loadHTMLString(html, baseURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(component: "index.html"))
            }
        }
        
        @State var isLoading = false

        var body: some View {
            MWebView(webViewController: webViewController)
                .ignoresSafeArea(.all)
                .onChange(of: webViewController.isLoading) { _, val in
                    guard let fn = props.getPropAsJSValue(name: "onLoadingChange"), fn.isObject else { return }
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
