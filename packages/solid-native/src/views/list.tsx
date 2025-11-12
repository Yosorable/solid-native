import { BaseProps } from "./props/base_props";

export interface ListProps extends BaseProps {
  children?: JSX.Element;
  listStyle?: "grouped" | "inset" | "insetGrouped" | "plain" | "sidebar";
}

export function List(props: ListProps) {
  return <sn_list {...props} />;
}
