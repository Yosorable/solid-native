import { BaseProps } from "./props/base_props";

interface WebImageProps extends BaseProps {
  src: string;
  placeholder?: JSX.Element;

  aspectRatio?: "fit" | "fill";
  fade?: number;
  resizable?: boolean;
}

export function WebImage(props: WebImageProps) {
  return <sn_webimage {...props} />;
}
