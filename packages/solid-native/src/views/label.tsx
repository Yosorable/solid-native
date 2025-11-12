import { BaseProps } from "./props/base_props";

interface LabelProps extends BaseProps {
  title: string;
  systemImage: string;
}

export function Label(props: LabelProps) {
  return <sn_label {...props} />;
}
