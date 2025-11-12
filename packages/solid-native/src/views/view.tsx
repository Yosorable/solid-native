import { BaseProps } from "./props/base_props";

export interface ViewProps extends BaseProps {
  children?: JSX.Element;
}

export function View(props: ViewProps) {
  return <sn_view {...props} />;
}
