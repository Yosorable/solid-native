import { createSignal, onMount } from "solid-js";
import { WebView, WebViewController } from "solid-native";
import { withAnimation } from "solid-native";
import todo from "./todo.html?raw";

export default function WebPage() {
  let ctrl: WebViewController | undefined;
  const [firstLoaded, setFirstLoaded] = createSignal(false);
  const [ani, setAni] = createSignal(false);
  onMount(() => {
    ctrl?.loadHTMLString(todo);
  });
  return (
    <WebView
      controller={(c) => {
        ctrl = c;
      }}
      navigationTitle="WebView"
      onLoadingChanged={(v) => {
        if (!v && !firstLoaded()) {
          setFirstLoaded(true);
          setTimeout(() => {
            withAnimation(() => {
              setAni(true);
            });
          }, 100);
        }
      }}
      opacity={ani() ? 1 : 0}
    />
  );
}
