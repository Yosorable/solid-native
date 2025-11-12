import { renderNewPage } from "..";
import { BaseProps } from "./props/base_props";

export interface NavigationStackProps<T> extends BaseProps {
  children?: JSX.Element;
  path?: T[];
  onPathChange?: (newPath: T[]) => void;
  navigationDestination?: (item: T) => JSX.Element;
}

export function NavigationStack<T>(props: NavigationStackProps<T>) {
  let newNavigationDestination;
  if (props.navigationDestination) {
    newNavigationDestination = (item: T) => {
      return renderNewPage(() => props.navigationDestination!(item));
    };
  }
  return (
    <sn_navigationstack
      {...props}
      navigationDestination={newNavigationDestination}
    />
  );
}
