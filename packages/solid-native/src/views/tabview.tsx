import { renderNewPage } from "..";
import { BaseProps } from "./props/base_props";

interface TabViewProps extends BaseProps {
  tabs: {
    tabItem: JSX.Element;
    content: () => JSX.Element;
  }[];
}

export function TabView(props: TabViewProps) {
  const newTbs = [];
  for (const tab of props.tabs) {
    newTbs.push({
      tabItem: tab.tabItem,
      content: () => renderNewPage(() => tab.content()),
    });
  }
  return <sn_tabview {...props} tabs={newTbs} />;
}
