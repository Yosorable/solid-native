export * from "./renderer";

const withAnimation = SolidNativeRenderer._withAnimation as (
  fn: () => void
) => void;
const webViewLoad = SolidNativeRenderer._webView_load;
const webViewLoadHTMLString = SolidNativeRenderer._webView_loadHTMLString;
const webViewEvaluateJavaScript =
  SolidNativeRenderer._webView_evaluateJavaScript;
export {
  withAnimation,
  webViewLoad,
  webViewLoadHTMLString,
  webViewEvaluateJavaScript,
};
export * from "./views";
