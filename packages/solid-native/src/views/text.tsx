import { BaseProps } from "./props/base_props";

interface TextViewProps extends BaseProps {
  text: string;
}

export function TextView(props: TextViewProps) {
  return <sn_text {...props} />;
}
