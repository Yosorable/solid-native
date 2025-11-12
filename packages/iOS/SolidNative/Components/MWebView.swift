//
//  MWebView.swift
//  SolidNative
//
//  Created by LZY on 2025/11/5.
//

import Foundation
import SwiftUI
import WebKit

class WebViewController: ObservableObject {
    public var webView: WKWebView!
    @Published var isLoading: Bool = false
    weak var parent: SNWebView?

    init(webView: WKWebView? = nil, parent: SNWebView) {
        print("+++ WebViewController init")
        if let webView = webView {
            self.webView = webView
        } else {
            let config = WKWebViewConfiguration()

            config.preferences = WKPreferences()
            config.preferences.javaScriptCanOpenWindowsAutomatically = true
            config.userContentController = WKUserContentController()

            config.mediaTypesRequiringUserActionForPlayback = []
            config.preferences.setValue(
                true,
                forKey: "allowFileAccessFromFileURLs"
            )
            config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
            config.allowsInlineMediaPlayback = true
            config.allowsPictureInPictureMediaPlayback = true
            config.limitsNavigationsToAppBoundDomains = false
            config.defaultWebpagePreferences.allowsContentJavaScript = true
            config.upgradeKnownHostsToHTTPS = false
            config.preferences.javaScriptCanOpenWindowsAutomatically = true

            let webView = WKWebView(frame: .zero, configuration: config)

            //            webView.isOpaque = false
            webView.scrollView.contentInsetAdjustmentBehavior = .always
            webView.allowsBackForwardNavigationGestures = true
            self.webView = webView
        }

        self.parent = parent
    }

    deinit {
        print("--- WebViewController deinit")
    }

    func updateLoadingState(isLoading: Bool) {
        self.isLoading = isLoading
    }

    func getCurrentURL() -> URL? {
        return webView.url
    }
}

struct MWebView: UIViewRepresentable {
    var webViewController: WebViewController

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        webViewController.webView.navigationDelegate = context.coordinator
        webViewController.webView.uiDelegate = context.coordinator
        return webViewController.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // MARK: todo: 你可以在这里实现根据变化加载 URL 或 HTML 字符串
        print("change")
    }

    // Coordinator 处理 WebView 状态
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: MWebView

        init(_ parent: MWebView) {
            self.parent = parent
        }

        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            parent.webViewController.updateLoadingState(isLoading: true)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
        {
            parent.webViewController.updateLoadingState(isLoading: false)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.webViewController.updateLoadingState(isLoading: false)
            // Optionally handle errors here
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping @MainActor () -> Void
        ) {
            defer { completionHandler() }
            guard let holder = parent.webViewController.parent,
                let fn = holder.props.getPropAsJSValue(name: "onAlert")
            else {
                return
            }
            fn.call(withArguments: [message])
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptTextInputPanelWithPrompt prompt: String,
            defaultText: String?,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping @MainActor (String?) -> Void
        ) {
            var res: String? = nil
            defer { completionHandler(res) }
            guard let holder = parent.webViewController.parent,
                let fn = holder.props.getPropAsJSValue(name: "onPrompt")
            else {
                return
            }
            var args = [prompt]
            if let dt = defaultText {
                args.append(dt)
            }
            guard let val = fn.call(withArguments: args) else { return }
            if !val.isNull, !val.isUndefined {
                res = val.toString()
            }
        }
    }
}
