type SingleColor =
  | "blue"
  | "red"
  | "green"
  | "yellow"
  | "orange"
  | "purple"
  | "pink"
  | "primary"
  | "secondary"
  | "accentColor"
  | "black"
  | "white"
  | "gray"
  | "clear"
  | "mint"
  | "brown"
  | "teal"
  | "cyan"
  | "indigo"
  | `#${string}`
  | `rgb${string}`
  | (string & {});

type Color = SingleColor;
// | {
//     light: SingleColor;
//     dark: SingleColor;
//   };

export type Alignment =
  | "center"
  | "leading"
  | "trailing"
  | "top"
  | "bottom"
  | "topLeading"
  | "topTrailing"
  | "bottomLeading"
  | "bottomTrailing"
  | "centerFirstTextBaseline"
  | "centerLastTextBaseline"
  | "leadingFirstTextBaseline"
  | "leadingLastTextBaseline"
  | "trailingFirstTextBaseline"
  | "trailingLastTextBaseline";

interface SwipeAction {
  edge?: "leading" | "trailing";
  allowsFullSwipe?: boolean;
  content: JSX.Element;
}

interface CGPoint {
  x: number;
  y: number;
}

export interface CGSize {
  width: number;
  height: number;
}

export interface EdgeInsets {
  top: number;
  leading: number;
  bottom: number;
  trailing: number;
}

interface DragGestureValue {
  time: Date;
  location: CGPoint;
  startLocation: CGPoint;
  translation: CGSize;
  velocity: CGSize;
  predictedEndLocation: CGPoint;
  predictedEndTranslation: CGSize;
}

export interface BaseProps {
  padding?:
    | number
    | boolean
    | {
        leading?: number;
        top?: number;
        bottom?: number;
        trailing?: number;
        horizontal?: number;
        vertical?: number;
        all?: number;
      };
  border?: {
    color?: Color;
    width?: number;
  };
  foregroundStyle?: Color | Color[];
  rotationEffect?: {
    degrees?: number;
    radians?: number;
  };
  scaleEffect?: number;
  shadow?: {
    color?: Color;
    x?: number;
    y?: number;
    radius: number;
    opacity?: number;
  };
  background?: Color | JSX.Element;
  overlay?: Color | JSX.Element;
  hidden?: boolean;
  frame?:
    | {
        width?: number | "infinity";
        height?: number | "infinity";
        alignment?: Alignment;
      }
    | {
        minWidth?: number | "infinity";
        idealWidth?: number | "infinity";
        maxWidth?: number | "infinity";
        minHeight?: number | "infinity";
        idealHeight?: number | "infinity";
        maxHeight?: number | "infinity";
        alignment?: Alignment;
      };
  zIndex?: number;
  opacity?: number;
  tint?: Color;
  cornerRadius?: number;
  position?: { x: number; y: number };
  offset?: { x: number; y: number };
  animation?: {
    type:
      | "spring"
      | "easeIn"
      | "easeOut"
      | "easeInOut"
      | "linear"
      | "interpolatingSpring"
      | "bouncy"
      | "smooth"
      | "default";
    value: any;
  };
  contentTransition?:
    | "numericText"
    | "opacity"
    | "identity"
    | "interpolate"
    | "symbolEffect";
  labelIsHidden?: boolean;
  // Filter
  blur?: number;
  saturation?: number;
  grayscale?: number;
  brightness?: number;
  contrast?: number;
  blendMode?:
    | "color"
    | "colorBurn"
    | "colorDodge"
    | "darken"
    | "difference"
    | "exclusion"
    | "hardLight"
    | "hue"
    | "lighten"
    | "luminosity"
    | "multiply"
    | "overlay"
    | "saturation"
    | "screen"
    | "softLight"
    | "sourceAtop"
    | "destinationOver"
    | "destinationOut"
    | "plusDarker"
    | "plusLighter"
    | "normal";
  mask?: string;
  clipShape?:
    | "circle"
    | "roundedRectangle"
    | "capsule"
    | "rectangle"
    | "ellipse"
    | {
        shape: "roundedRectangle";
        cornerRadius: number;
      };
  clipped?: boolean;
  fill?: Color;
  stroke?: {
    color: Color;
    lineWidth: number;
  };
  // Environment
  environment?: {
    colorScheme: "light" | "dark";
  };
  // TextField
  textContentType?:
    | "name"
    | "namePrefix"
    | "givenName"
    | "middleName"
    | "familyName"
    | "nameSuffix"
    | "nickname"
    | "jobTitle"
    | "organizationName"
    | "location"
    | "fullStreetAddress"
    | "streetAddressLine1"
    | "streetAddressLine2"
    | "addressCity"
    | "addressState"
    | "addressCityAndState"
    | "sublocality"
    | "countryName"
    | "postalCode"
    | "telephoneNumber"
    | "emailAddress"
    | "URL"
    | "creditCardNumber"
    | "username"
    | "password"
    | "newPassword"
    | "oneTimeCode"
    | "shipmentTrackingNumber"
    | "flightNumber"
    | "dateTime"
    | "birthdate"
    | "birthdateDay"
    | "birthdateMonth"
    | "birthdateYear"
    | "creditCardSecurityCode"
    | "creditCardName"
    | "creditCardGivenName"
    | "creditCardMiddleName"
    | "creditCardFamilyName"
    | "creditCardExpiration"
    | "creditCardExpirationMonth"
    | "creditCardExpirationYear"
    | "creditCardType";

  keyboardType?:
    | "numberPad"
    | "phonePad"
    | "namePhonePad"
    | "emailAddress"
    | "decimalPad"
    | "twitter"
    | "webSearch"
    | "asciiCapableNumberPad"
    | "numbersAndPunctuation"
    | "URL"
    | "asciiCapable"
    | "default";

  // not impl
  textInputAutocapitalization?: "never" | "words" | "sentences" | "characters";
  autocorrectionDisabled?: boolean;

  // Image
  resizable?: boolean;
  imageScale?: "small" | "medium" | "large";
  symbolRenderingMode?:
    | "palette"
    | "monochrome"
    | "hierarchical"
    | "multicolor";

  // Text
  fontSize?: number;
  fontWeight?:
    | "ultralight"
    | "thin"
    | "light"
    | "regular"
    | "medium"
    | "semibold"
    | "bold"
    | "heavy"
    | "black";
  font?:
    | "body"
    | "callout"
    | "caption"
    | "caption2"
    | "footnote"
    | "headline"
    | "largeTitle"
    | "subheadline"
    | "title"
    | "title2"
    | "title3";
  bold?: boolean;
  italic?: boolean;
  strikethrough?:
    | boolean
    | {
        isActive: boolean;
        color?: Color;
        pattern?: "dot" | "dash" | "solid" | "dashDotDot" | "dashDot";
      };
  underline?:
    | boolean
    | {
        isActive: boolean;
        color?: Color;
        pattern?: "dot" | "dash" | "solid" | "dashDotDot" | "dashDot";
      };
  lineLimit?: number;
  truncationMode?: "head" | "middle" | "tail";
  // Style Variants
  buttonStyle?: "bordered" | "borderless" | "plain" | "borderedProminent";
  pickerStyle?: "wheel" | "segmented" | "menu";
  textFieldStyle?: "plain" | "roundedBorder";
  listStyle?: "inset" | "grouped" | "plain" | "insetGrouped";

  // Haptics
  sensoryFeedback?: {
    feedback:
      | "warning"
      | "error"
      | "success"
      | "alignment"
      | "decrease"
      | "impact"
      | "increase"
      | "levelChange"
      | "selection"
      | "start"
      | "stop";
    trigger: any;
  };
  // List
  scrollDisabled?: boolean;
  // Lifecycle - todo
  onAppear?: () => void;
  onDisappear?: () => void;
  onTapGesture?: (() => void) | { count: number; perform: () => void };
  onLongPressGesture?:
    | (() => void)
    | {
        minimumDuration?: number;
        maximumDistance?: number;
        perform: () => void;
        onPressingChanged?: (changed: boolean) => void;
      };
  dragGesture?: {
    onChanged?: (value: DragGestureValue) => void;
    onEnded?: (value: DragGestureValue) => void;
  };
  // navigation bar
  navigationTitle?: string;
  navigationBarTitleDisplayMode?: "inline" | "large";

  swipeActions?: SwipeAction | SwipeAction[];

  // alert?: Alert;
  // Sheet
  // sheet?: {
  //   isPresented: boolean | BooleanBinding;
  //   content: ReactNode;
  //   onDismiss?: () => void;
  // };
  // presentationCornerRadius?: number;
  // presentationDetents?: (
  //   | 'medium'
  //   | 'large'
  //   | { fraction: number }
  //   | { height: number }
  // )[];
}
