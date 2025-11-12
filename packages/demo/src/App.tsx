import { For, Setter, Show, createSignal, onCleanup, onMount } from "solid-js";
import {
  Button,
  View,
  ScrollView,
  Toggle,
  HStack,
  Spacer,
  Slider,
  VStack,
  TextView,
  TextField,
  SecureField,
  LazyVGrid,
  Rectangle,
  Label,
  NavigationLink,
  WebView,
  WebViewController,
  WebImage,
} from "solid-native";
import { withAnimation } from "solid-native";
import icon from "./assets/icons.jpg";

const [count, setCount] = createSignal(0);
const [sliderVal, setSliderVal] = createSignal<number>(10);
const [sliderEditing, setSliderEditing] = createSignal<boolean>(false);

const defaultImages = [
  "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201710%2F07%2F20171007204419_RScfZ.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1717303152&t=1558223ea971aa2ec4cf07db3937ed8f",
  "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F06%2F20150806170226_MJR3a.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1717304290&t=6243a0ee07ed22951591df71b254ebdf",
  "https://img1.baidu.com/it/u=344041896,1429252941&fm=253&app=138&f=JPEG?w=608&h=855",
  "https://img0.baidu.com/it/u=3913164939,3214153973&fm=253&app=138&f=JPEG?w=706&h=998",
];

function BackgroundTest() {
  onMount(() => {
    console.log("mount back");
  });
  onCleanup(() => {
    console.log("clean back");
  });
  return (
    <View
      frame={{
        maxWidth: "infinity",
        minHeight: 55,
        alignment: "bottom",
      }}
      background={
        <Rectangle
          frame={{
            width: 10000,
          }}
          fill="pink"
        />
      }
      foregroundStyle="white"
    >
      ----------
      {count()}
    </View>
  );
}

const [imgs, setImgs] = createSignal<string[]>(defaultImages);

export const ImagesOpt = { imgs, setImgs, defaultImages };
export default function App({
  title = "Home",
  setPath,
}: {
  title?: string;
  setPath: Setter<string[]>;
}) {
  const [list, setList] = createSignal<string[]>([]);

  const [html, setHtml] = createSignal("");
  const [text, setText] = createSignal("");
  const [pwd, setPwd] = createSignal("");
  const [isOn, setIsOn] = createSignal<boolean>(false);
  const [tt, setTt] = createSignal(title);

  const [hd, setHd] = createSignal(false);

  const [offset, setOffset] = createSignal([0, 0]);

  onMount(() => {
    console.log("App Mounted!");
  });

  onCleanup(() => {
    console.log("clean up");
  });

  function Overlay() {
    onCleanup(() => {
      console.log("clean overlay");
    });
    return (
      <View
        frame={{ width: 180, height: 20 }}
        background="mint"
        opacity={0.5}
        rotationEffect={{ degrees: sliderVal() * 2 }}
        offset={{
          x: sliderVal() * 2,
          y: 0,
        }}
      >
        {count()}
      </View>
    );
  }

  return (
    <ScrollView navigationTitle={tt()} navigationBarTitleDisplayMode="inline">
      <HStack>
        <Button
          onPress={() => {
            setPath((p) => {
              const newPath = [...p];
              newPath.pop();
              return newPath;
            });
          }}
        >
          back
        </Button>
        <Button
          onPress={() => {
            setPath((p) => {
              const newPath = [...p, "WebView"];
              return newPath;
            });
          }}
        >
          webview
        </Button>
        <NavigationLink
          destination={(() => {
            let controller: WebViewController;
            return (
              <WebView
                controller={(c) => (controller = c)}
                navigationTitle="code"
                onAppear={() => {
                  controller.load("index.js");
                }}
              />
            );
          })()}
        >
          code
        </NavigationLink>
        <NavigationLink
          destination={(() => {
            let controller: WebViewController;
            return (
              <WebView
                controller={(c) => (controller = c)}
                navigationTitle="bing"
                onAppear={() => {
                  controller.load("https://www.bing.com");
                }}
              />
            );
          })()}
        >
          bing
        </NavigationLink>
      </HStack>
      <Show when={tt() !== "Home"}>
        <Rectangle
          frame={{
            width: 200,
            height: 200,
          }}
          overlay={<TextView text="Drag" />}
          cornerRadius={20}
          fill="#E176A1"
          opacity={Math.max(
            0,
            1 -
              Math.sqrt(offset()[0] * offset()[0] + offset()[1] * offset()[1]) /
                600
          )}
          offset={{ x: offset()[0], y: offset()[1] }}
          dragGesture={{
            onChanged(val) {
              setOffset([val.translation.width, val.translation.height]);
            },
            onEnded() {
              withAnimation(() => {
                setOffset([0, 0]);
              });
            },
          }}
        />
      </Show>
      <View blur={sliderVal() / 10}>
        <HStack lineLimit={4} background={<BackgroundTest />}>
          Hello World!
          {text()}
          {pwd()}
          {html()}
        </HStack>
      </View>

      <Label title="Home" systemImage="house" />
      <HStack overlay={<Overlay />} spacing={0}>
        <TextView text="icon path:" />
        <TextView text={icon} />
      </HStack>
      <HStack>
        <Button onPress={() => setImgs([...defaultImages])}>
          reset images
        </Button>
        <Button onPress={() => setTt((Math.random() * 100).toFixed())}>
          change title
        </Button>
        <Button
          onPress={() => {
            setPath((prev) => [...prev, (Math.random() * 100).toFixed()]);
          }}
        >
          navigate
        </Button>
      </HStack>
      <Button
        onPress={() => {
          setPath((prev) => [...prev, "ListView"]);
        }}
      >
        ListView
      </Button>
      <View padding>
        <TextField
          text={text()}
          placeholder="please input"
          onChange={(val) => setText(val)}
          keyboardType="webSearch"
          tint="#C8915B"
          padding
          border={{ color: "gray", width: 1 }}
          font="title"
        />
        <SecureField
          text={pwd()}
          placeholder="please input password"
          onChange={(val) => setPwd(val)}
          padding
          border={{ color: "gray", width: 1 }}
          font="title"
        />
      </View>
      <HStack>
        <Button
          onPress={() => {
            fetch("https://www.baidu.com", {})
              .then((res) => res.text())
              .then((res) => setHtml(res))
              .catch((err) => setHtml(err.message));
          }}
          padding
        >
          fetch
        </Button>
        <Button
          padding
          onPress={() => {
            setHtml("");
            setText("");
            setPwd("");
          }}
        >
          clear
        </Button>
      </HStack>
      <VStack padding tint="yellow">
        <View>{sliderEditing() ? "editing" : "not edit"}</View>
        <View>{sliderVal()}</View>
        <Slider
          value={sliderVal()}
          onChange={(val) => setSliderVal(val)}
          onEditingChanged={(editing) => setSliderEditing(editing)}
        />
        <HStack>
          <Button
            title="-"
            onPress={() => {
              withAnimation(() =>
                setSliderVal((cur) => (cur - 10 < 0 ? 0 : cur - 10))
              );
            }}
            font="largeTitle"
            padding
          />
          <Button
            title="+"
            onPress={() =>
              withAnimation(function () {
                setSliderVal((cur) => (cur + 10 > 100 ? 100 : cur + 10));
              })
            }
            font="largeTitle"
            padding
          />
        </HStack>
      </VStack>
      <Button title="change" onPress={() => setHd((c) => !c)} />
      <Show when={!hd()}>
        <View bold font="title">{`Count: ${count()}`}</View>
        <HStack padding>
          <Button
            title="Plus!"
            onPress={() => {
              setCount((cur) => cur + 1);
            }}
          />
          <Spacer />
          <Button
            title="Reset count!"
            onPress={() => {
              setCount(0);
            }}
          />
        </HStack>
      </Show>
      <Toggle
        value={isOn()}
        label={isOn() ? "on" : "off"}
        onChange={(val) => {
          setIsOn(val);
        }}
        frame={{
          width: 200,
        }}
        tint="black"
      />
      <HStack>
        <For each={list()} children={(item) => item} />
      </HStack>
      <HStack>
        <Button
          title="Add some text!"
          onPress={() => {
            setList((prev) => [...prev, (Math.random() * 100).toFixed()]);
          }}
        />
        <Button
          title="Reset Text!"
          onPress={() => {
            setList([]);
          }}
        />
      </HStack>
      <LazyVGrid padding>
        <For each={imgs()}>
          {(item, idx) => (
            <Button
              buttonStyle="plain"
              onPress={() => {
                setPath((prev) => [
                  ...prev,
                  `ImageDetail/${JSON.stringify({
                    url: item,
                    idx: idx(),
                    sliderVal: isOn() ? sliderVal() : 0,
                  })}`,
                ]);
              }}
            >
              <WebImage
                resizable
                aspectRatio="fill"
                fade={0.3}
                frame={{
                  height: 100,
                  width: 100,
                }}
                clipped
                cornerRadius={20}
                placeholder={<Rectangle opacity={0.1} fill="gray" />}
                blur={isOn() ? sliderVal() / 10 : 0}
                src={item}
              />
            </Button>
          )}
        </For>
      </LazyVGrid>
    </ScrollView>
  );
}
