import { BaseProps } from "./props/base_props";

interface ButtonProps extends BaseProps {
  title?: string;
  onPress?: () => void;
  children?: JSX.Element;
  role?: "cancel" | "destructive";
}

export function Button(props: ButtonProps) {
  return <sn_button {...props} />;
}
