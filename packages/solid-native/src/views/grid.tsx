import { BaseProps } from "./props/base_props";

export interface GridProps extends BaseProps {
  children?: JSX.Element;
}

export function LazyVGrid(props: GridProps) {
  return <sn_lazy_vgrid {...props} />;
}
