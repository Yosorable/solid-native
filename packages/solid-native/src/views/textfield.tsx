import { BaseProps } from "./props/base_props";

interface TextFieldProps extends BaseProps {
  text?: string;
  placeholder?: string;
  onChange?: (value: string) => void;
}

export function TextField(props: TextFieldProps) {
  return <sn_textfield {...props} />;
}
