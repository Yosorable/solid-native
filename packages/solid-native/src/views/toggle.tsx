import { BaseProps } from "./props/base_props";

interface ToggleProps extends BaseProps {
  value?: boolean;
  onChange?: (val: boolean) => void;
  label?: string;
}

export function Toggle(props: ToggleProps) {
  return <sn_toggle {...props} />;
}
