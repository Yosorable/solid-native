import { BaseProps } from "./props/base_props";

interface SliderProps extends BaseProps {
  value?: number;
  step?: number;
  minValue?: number;
  maxValue?: number;
  onEditingChanged?: (editing: boolean) => void;
  onChange?: (value: number) => void;
}

export function Slider(props: SliderProps) {
  return <sn_slider {...props} />;
}
