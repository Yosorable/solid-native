import { createSignal, For, onCleanup, onMount, Setter, Show } from "solid-js";
import {
  Button,
  HStack,
  LazyVGrid,
  LazyVStack,
  List,
  Rectangle,
  ScrollView,
  Spacer,
  TextView,
  View,
  VStack,
  ZStack,
  WebImage,
} from "solid-native";
import { ImagesOpt } from "../App";

export default function ListView({ setPath }: { setPath: Setter<string[]> }) {
  onMount(() => {
    console.log("ListView mounted");
  });

  return (
    <ZStack navigationTitle="List">
      <VStack zIndex={2}>
        <Spacer />
        <HStack>
          <Button
            onPress={() => {
              ImagesOpt.setImgs((c) => [...c, ...ImagesOpt.defaultImages]);
            }}
            padding
          >
            <Spacer />
            <TextView
              frame={{
                width: 80,
                height: 80,
              }}
              background="#E176A1"
              text="+"
              foregroundStyle="white"
              font="title"
              cornerRadius={80}
            />
          </Button>
        </HStack>
      </VStack>
      <List>
        <For each={ImagesOpt.imgs()}>
          {(item, idx) => (
            <HStack
              onTapGesture={() => {
                setPath((prev) => [
                  ...prev,
                  `ImageDetail/${JSON.stringify({
                    url: item,
                    idx: idx(),
                  })}`,
                ]);
              }}
              swipeActions={[
                {
                  edge: "trailing",
                  content: (() => {
                    onMount(() => {
                      console.log("delete button mounted");
                    });
                    onCleanup(() => {
                      console.log("delete button unmounted");
                    });

                    return (
                      <Button
                        role="destructive"
                        onPress={() => {
                          ImagesOpt.setImgs((prev) => {
                            const arr = [...prev];
                            arr.splice(idx(), 1);
                            return arr;
                          });
                          console.log("deleted");
                        }}
                      >
                        delete
                      </Button>
                    );
                  })(),
                },
                {
                  edge: "leading",
                  content: (
                    <Button
                      tint="orange"
                      onPress={() => console.log("favorite")}
                    >
                      favorite
                    </Button>
                  ),
                },
              ]}
            >
              <WebImage
                resizable
                aspectRatio="fill"
                fade={0.3}
                frame={{
                  width: 50,
                  height: 50,
                }}
                src={item}
                clipped
                cornerRadius={10}
              />
              <TextView text={item} lineLimit={1} truncationMode="middle" />
            </HStack>
          )}
        </For>
      </List>
    </ZStack>
  );
}
