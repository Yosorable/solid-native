import { BaseProps } from "./props/base_props";

export interface ScrollViewProps extends BaseProps {
  children?: JSX.Element;
}

export function ScrollView(props: ScrollViewProps) {
  return <sn_scrollview {...props} />;
}
