import { BaseProps } from "./props/base_props";

interface NavigationLinkProps extends BaseProps {
  children?: JSX.Element;
  destination: JSX.Element;
}

export function NavigationLink(props: NavigationLinkProps) {
  return <sn_navigationlink {...props} />;
}
