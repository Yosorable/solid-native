import { createSignal } from "solid-js";
import { Slider, Toggle, View, VStack, WebImage, WebView } from "solid-native";
import { withAnimation } from "solid-native";

export default function ImageDetail({
  url,
  idx,
  sliderVal,
}: {
  url: string;
  idx: number;
  sliderVal: number;
}) {
  const [ld, setLd] = createSignal(false);
  return (
    <WebView
      navigationTitle={(idx + 1).toString()}
      opacity={ld() ? 1 : 0}
      onLoadingChanged={(v) => {
        withAnimation(() => {
          if (!ld() && v) setLd(true);
        });
      }}
      controller={(c) => {
        c.loadHTMLString(`<!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
          body, html {
              margin: 0;
              padding: 0;
              height: 100%;
              display: flex;
              justify-content: center;
              align-items: center;
              background-color: #f0f0f0;
          }
          img {
              max-width: 100%;
              max-height: 100%;
              object-fit: contain;
          }
      </style>
  </head>
  <body>
      <img src="${url}" alt="">
  </body>
  </html>
  `);

        c.evaluateJavaScript("alert('Hello, world!')", (res, err) => {
          console.log((res ?? "nil") + (err ?? "nil"));
        });
      }}
      onAlert={(m) => console.log("alert " + m)}
    />
  );
  return (
    <VStack navigationTitle={(idx + 1).toString()}>
      <View frame={{ height: 100, width: 100 }} overlay="mint" />
      <Slider
        padding={{
          horizontal: 80,
        }}
      />
      <WebImage
        resizable
        aspectRatio="fit"
        fade={0.3}
        blur={sliderVal / 10}
        src={url}
        overlay={<Toggle />}
      />
    </VStack>
  );
}
