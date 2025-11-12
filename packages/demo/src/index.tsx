/* @refresh reload */
import { render, withAnimation } from "solid-native";
import App from "./App";
import {
  Button,
  HStack,
  Label,
  Rectangle,
  ScrollView,
  TabView,
  TextView,
  View,
  VStack,
  WebView,
  WebViewController,
  NavigationStack,
} from "solid-native";
import { createSignal, For, Match, onCleanup, onMount, Switch } from "solid-js";
import ListView from "./pages/ListView";
import ImageDetail from "./pages/ImageDetail";
import WebPage from "./pages/WebPage";

// render(() => <App />);
function HomePage() {
  const [path, setPath] = createSignal<string[]>([]);
  const [tt, setTT] = createSignal(0);

  return (
    <NavigationStack
      path={path()}
      navigationDestination={(item) => {
        if (item === "ListView") {
          return <ListView setPath={setPath} />;
        } else if (item.startsWith("ImageDetail/")) {
          const obj = JSON.parse(item.replace("ImageDetail/", ""));
          return <ImageDetail {...obj} />;
        } else if (item === "WebView") {
          return <WebPage />;
        }

        return <App title="Unknown Page" setPath={setPath} />;

        return (
          <TabView
            navigationTitle="Home"
            navigationBarTitleDisplayMode="inline"
            tabs={[
              {
                tabItem: <Label title="Tab 1" systemImage="house" />,
                content: () => <App title="Tab 1" setPath={setPath} />,
              },
              {
                tabItem: <Label title="Tab 2" systemImage="house" />,
                content: () => <ListView setPath={setPath} />,
              },
            ]}
          />
        );
      }}
      onPathChange={(newPath) => {
        setPath(newPath);
      }}
    >
      <Button onPress={() => setTT((c) => c + 1)}>change tab</Button>
      <TabView
        navigationTitle="Home"
        navigationBarTitleDisplayMode="inline"
        tabs={[
          {
            tabItem: <Label title={`Tab ${tt()}`} systemImage="house" />,
            content: () => <App title="Tab 1" setPath={setPath} />,
          },
          {
            tabItem: <Label title="Tab 2" systemImage="house" />,
            content: () => <ListView setPath={setPath} />,
          },
        ]}
      />
    </NavigationStack>
  );
}

render(() => <HomePage />);
