import type { JSX as solidJSX } from "solid-js";
/**
 * In actually, this is a string. BUT to make this more
 * Typescript/TSX compiler friendly it's aliased as a
 * `JSX.Element`
 */
export type SolidNativeElement = JSX.Element;

declare global {
  namespace JSX {
    interface IntrinsicElements {
      [name: string]: Record<string, unknown>;
    }
    type Element = solidJSX.Element;

    interface ElementChildrenAttribute {
      children?: unknown; // specify children name to use
    }
  }

  interface SolidNativeRenderer {
    _withAnimation: (fn: () => void) => void;
    createNewView: () => string;

    getRootView: () => string;
    getFirstChild: (node: string) => string | undefined;
    getParent: (node: string) => string | undefined;
    setProp: (node: string, key: string, value: unknown) => void;
    isTextElement: (node: string) => boolean;
    removeChild: (node: string, child: string) => void;
    insertBefore: (node: string, child: string, anchor?: string) => void;
    next: (node: string) => string | undefined;
    prev: (node: string) => string | undefined;

    createNodeByName: (name: string) => string;

    _webView_load: (id: string, url: string) => void;
    _webView_loadHTMLString: (id: string, html: string, url?: string) => void;
    _webView_evaluateJavaScript: (
      id: string,
      code: String,
      callback?: (res?: string, err?: string) => void
    ) => void;
  }

  const SolidNativeRenderer: SolidNativeRenderer;
}
