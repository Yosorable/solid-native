import { Alignment, BaseProps } from "./props/base_props";

export type StackAlignment = "leading" | "trailing" | "center";

export type VerticalAlignment =
  | "top"
  | "bottom"
  | "center"
  | "firstTextBaseline"
  | "lastTextBaseline";

export type HorizontalAlignment =
  | "leading"
  | "center"
  | "trailing"
  | "listRowSeparatorLeading"
  | "listRowSeparatorTrailing";

interface StackProps extends BaseProps {
  children?: JSX.Element;
  spacing?: number;
}

export interface VerticalStackProps extends StackProps {
  alignment?: VerticalAlignment;
}

export interface HorizontalStackProps extends StackProps {
  alignment?: HorizontalAlignment;
}

export interface ZStackProps extends StackProps {
  alignment?: Alignment;
}

export function VStack(props: HorizontalStackProps) {
  return <sn_vstack {...props} />;
}

export function HStack(props: VerticalStackProps) {
  return <sn_hstack {...props} />;
}

export function ZStack(props: ZStackProps) {
  return <sn_zstack {...props} />;
}

export function LazyVStack(props: HorizontalStackProps) {
  return <sn_lazy_vstack {...props} />;
}

export function LazyHStack(props: VerticalStackProps) {
  return <sn_lazy_hstack {...props} />;
}
