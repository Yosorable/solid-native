import {
  webViewEvaluateJavaScript,
  webViewLoad,
  webViewLoadHTMLString,
} from "..";
import { BaseProps } from "./props/base_props";

export class WebViewController {
  private id: string;
  constructor(id: string) {
    this.id = id;
  }
  load(url: string) {
    webViewLoad(this.id, url);
  }
  loadHTMLString(html: string, baseURL?: string) {
    webViewLoadHTMLString(this.id, html, baseURL);
  }
  evaluateJavaScript(
    code: String,
    callback?: (res?: string, err?: string) => void
  ) {
    webViewEvaluateJavaScript(this.id, code, callback);
  }
}

interface WebViewProps extends BaseProps {
  controller?: (c: WebViewController) => void;
  onLoadingChanged?: (isLoading: boolean) => void;
  onAlert?: (message: string) => void;
  onPrompt?: (
    prompt: string,
    defaultText?: string
  ) => string | undefined | null | void;
}

export function WebView(props: WebViewProps) {
  let rf = undefined;
  if (props.controller != null) {
    rf = (node: { id: string }) => {
      props.controller!(new WebViewController(node.id));
    };
  }
  return <sn_webview {...{ ...props, controller: undefined }} ref={rf} />;
}
