import { createSignal, onMount } from "solid-js";
import { print, View, Text } from "solid-native/core";

export function App() {
  // const [count, setCount] = createSignal(0);

  // const [itemNumber, setItemNumber] = createSignal(1);

  // const [list, setList] = createSignal<string[]>([]);

  // setInterval(() => setCount(count() + 1), 1000);

  const [isBold, setIsBold] = createSignal<"bold" | "normal">("bold");
  const [bool, setBool] = createSignal(false);

  setInterval(() => {
    // print("Update Bold!");
    setBool(!bool());
    if (isBold() === "bold") {
      setIsBold("normal");
    } else {
      setIsBold("bold");
    }
  }, 1000);

  onMount(() => {
    print("App Mounted!");
  });

  return (
    <View>
      <Text>
        Bruh
        <Text
          style={{
            fontWeight: isBold(),
          }}
        >
          Hello World:
        </Text>
      </Text>
      <Text
        style={{
          color: bool() ? "#4287f5" : "#8cb512",
          fontWeight: "bold",
          fontStyle: "italic",
        }}
      >
        HELLO!
      </Text>
    </View>
  );
}
