type SpacerProps = {
  minLength?: number;
};

export function Spacer(props: SpacerProps) {
  return <sn_spacer {...props} />;
}
