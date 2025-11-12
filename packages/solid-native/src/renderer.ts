import { createRenderer } from "solid-js/universal";

type Node = {
  id: string;
};

/**
 * When the SolidJS renderer encounters a string or text, it makes a text component.
 * This is an issue if the renderer returns string based id's. Thus, wrap in an object
 * when created to avoid this issue. In the future, we can look into the views
 * exposing a JSValue Object that allows it to be directly manipulated using the same
 * JSValueBuilder Swift Class I made.
 * @param id
 * @returns
 */
const wrapNodeIdInNode = (id: string): Node => ({ id });

export const {
  render: solidRender,
  effect,
  memo,
  createComponent,
  createElement,
  createTextNode,
  insertNode,
  insert,
  spread,
  setProp,
  mergeProps,
  use,
} = createRenderer<Node>({
  createElement(nodeName) {
    const id = SolidNativeRenderer.createNodeByName(nodeName);
    return wrapNodeIdInNode(id);
  },
  createTextNode(value) {
    const node = SolidNativeRenderer.createNodeByName("sn_text");
    SolidNativeRenderer.setProp(node, "text", value);

    return wrapNodeIdInNode(node);
  },
  replaceText({ id }, value) {
    SolidNativeRenderer.setProp(id, "text", value);
  },
  setProperty({ id }, propertyName, value) {
    SolidNativeRenderer.setProp(id, propertyName, value);
  },
  insertNode({ id: parentId }, { id: nodeId }, anchor) {
    const anchorId = anchor?.id;
    SolidNativeRenderer.insertBefore(parentId, nodeId, anchorId);
  },
  isTextNode({ id }) {
    return SolidNativeRenderer.isTextElement(id);
  },
  removeNode({ id: parentId }, { id: nodeId }) {
    return SolidNativeRenderer.removeChild(parentId, nodeId);
  },
  getParentNode({ id }) {
    const parentId = SolidNativeRenderer.getParent(id);
    if (parentId) {
      return wrapNodeIdInNode(parentId);
    }
    return undefined;
  },
  getFirstChild({ id }) {
    const firstChildId = SolidNativeRenderer.getFirstChild(id);
    if (firstChildId) {
      return wrapNodeIdInNode(firstChildId);
    }
    return undefined;
  },
  getNextSibling({ id }) {
    const nextSiblingId = SolidNativeRenderer.next(id);
    if (nextSiblingId) {
      return wrapNodeIdInNode(nextSiblingId);
    }
    return undefined;
  },
});

declare global {
  interface GlobalThis {
    RootsMap: Record<string, () => void>;
    cleanPage: (root: string) => void;
    cleanAllPages: () => void;
  }
}
const glb = globalThis as any;
glb.RootsMap = {};

glb.cleanPage = function (root: string) {
  const func = glb.RootsMap[root];
  if (func == null) return;
  console.log("cleaning page " + root + " " + func);
  func();
  delete glb.RootsMap[root];
};

glb.cleanAllPages = function () {
  for (const id of Object.keys(glb.RootsMap)) {
    glb.cleanPage(id);
  }
};

export const render = (code: () => JSX.Element) => {
  const root = wrapNodeIdInNode(SolidNativeRenderer.getRootView());
  glb.RootsMap[root.id] = solidRender(code as any, root);
};

export const renderNewPage = (code: () => JSX.Element) => {
  const root = wrapNodeIdInNode(SolidNativeRenderer.createNewView());
  glb.RootsMap[root.id] = solidRender(code as any, root);
  return { id: root.id };
  // let id
  // globalThis.RootsMap[id] = createRoot((dis) => {
  //   const node = code()
  //   id = node.id
  //   return dis
  // })
};
