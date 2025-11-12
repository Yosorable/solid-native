import { BaseProps } from "./props/base_props";

interface SecureFieldProps extends BaseProps {
  text?: string;
  placeholder?: string;
  onChange?: (value: string) => void;
}

export function SecureField(props: SecureFieldProps) {
  return <sn_securefield {...props} />;
}
