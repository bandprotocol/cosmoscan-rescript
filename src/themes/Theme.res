open CssJs

type mode_t =
  | Day
  | Dark

type color_t = Types.Color.t;

type t = {
  white: color_t,
  black: color_t,
  
  // primary
  primary_100: color_t,
  primary_200: color_t,
  primary_600: color_t,
  primary_500: color_t,
  primary_800: color_t,

  success_100: color_t,
  success_200: color_t,
  success_600: color_t,
  success_800: color_t,
  error_100: color_t,
  error_200: color_t,
  error_600: color_t,
  error_700: color_t,
  warning_100: color_t,
  warning_200: color_t,
  warning_600: color_t,
  warning_700: color_t,

  pendingColor: color_t,
  activeColor: color_t,
  footer: color_t,

  // new theme
  neutral_000: color_t,
  neutral_100: color_t,
  neutral_200: color_t,
  neutral_300: color_t,
  neutral_400: color_t,
  neutral_500: color_t,
  neutral_600: color_t,
  neutral_700: color_t,
  neutral_800: color_t,
  neutral_900: color_t,

};

let toString = (col) => col -> Types.Color.toString

let black = hex("000000");
let white = hex("FFFFFF");

let pendingColor = hex("F4D23E");
let activeColor = hex("5FD3C8");

let get = mode =>
  switch mode {
  | Day => {
      white,
      black,

      primary_100: hex("F0EDFD"),
      primary_200: hex("DAD1FE"),
      primary_500: hex("6547EB"),
      primary_600: hex("4520E6"),
      primary_800: hex("210D77"),

      success_100: hex("E7F8EF"),
      success_200: hex("CFF2DF"),
      success_600: hex("3FCA7E"),
      success_800: hex("1E6C41"),
      error_100: hex("FDF2F1"),
      error_200: hex("FBE2DF"),
      error_600: hex("E22E1D"),
      error_700: hex("B52517"),
      warning_100: hex("FDF8E2"),
      warning_200: hex("FBEDB2"),
      warning_600: hex("F2CC21"),
      warning_700: hex("A98C0A"),

      activeColor,
      pendingColor,
      footer: hex("4520E6"),

      // new theme
      neutral_000: hex("FFFFFF"),
      neutral_100: hex("F3F4F6"),
      neutral_200: hex("E5E7EB"),
      neutral_300: hex("D1D5DB"),
      neutral_400: hex("B0B6BF"),
      neutral_500: hex("9096A2"),
      neutral_600: hex("6C7889"),
      neutral_700: hex("4A5568"),
      neutral_800: hex("323A43"),
      neutral_900: hex("202327"),
    }
  | Dark => {
      white,
      black,

      primary_100: hex("120A38"),
      primary_200: hex("1D0D63"),
      primary_500: hex("3214B8"),
      primary_600: hex("8871EF"),
      primary_800: hex("B2A3F5"),

      success_100: hex("0B2818"),
      success_200: hex("14482B"),
      success_600: hex("3FCA7E"),
      success_800: hex("83DDAB"),
      error_100: hex("320A06"),
      error_200: hex("480F09"),
      error_600: hex("E22E1D"),
      error_700: hex("EA685D"),
      warning_100: hex("272002"),
      warning_200: hex("3F3404"),
      warning_600: hex("F2CC21"),
      warning_700: hex("F7DF73"),

      activeColor,
      pendingColor,
      footer: hex("21262C"),

       // new theme
      neutral_000: hex("101214"),
      neutral_100: hex("1A1E23"),
      neutral_200: hex("21262C"),
      neutral_300: hex("293037"),
      neutral_400: hex("39424C"),
      neutral_500: hex("4E5A6E"),
      neutral_600: hex("7D8A9D"),
      neutral_700: hex("A0AEC0"),
      neutral_800: hex("CBD5E0"),
      neutral_900: hex("FFFFFF"),
    }
  }
