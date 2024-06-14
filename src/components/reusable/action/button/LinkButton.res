type btn_style_t =
  | Primary
  | Secondary
  | Outline
  | Text

module Styles = {
  open CssJs

  let btn = (
    ~variant=Primary,
    ~fsize=12,
    ~px=25,
    ~py=13,
    ~pxSm=px,
    ~pySm=py,
    ~fullWidth,
    theme: Theme.t,
    isDarkMode,
    (),
  ) => {
    let base = style(. [
      display(#block),
      width(fullWidth ? #percent(100.) : #auto),
      padding2(~v=#px(py), ~h=#px(px)),
      transition(~duration=200, "all"),
      borderRadius(#px(8)),
      fontSize(#px(fsize)),
      fontWeight(#num(600)),
      cursor(#pointer),
      outlineStyle(#none),
      borderStyle(#none),
      margin(#zero),
      disabled([cursor(#default)]),
      textDecoration(#none),
      Media.mobile([padding2(~v=#px(pySm), ~h=#px(pxSm))]),
    ])

    let custom = switch variant {
    | Primary =>
      style(. [
        backgroundColor(theme.primary_600),
        color(Theme.white),
        border(#px(1), #solid, theme.primary_600),
        hover([backgroundColor(theme.primary_500)]),
        active([backgroundColor(theme.primary_800)]),
        disabled([
          backgroundColor(isDarkMode ? theme.primary_500 : theme.primary_500),
          color(Theme.white),
          borderColor(isDarkMode ? theme.primary_500 : theme.primary_500),
          opacity(0.5),
        ]),
      ])
    | Secondary =>
      style(. [
        backgroundColor(theme.neutral_000),
        color(theme.neutral_900),
        border(#px(1), #solid, isDarkMode ? theme.neutral_600 : theme.neutral_400),
        selector("i", [color(theme.neutral_900)]),
        hover([
          backgroundColor(theme.neutral_900),
          border(#px(1), #solid, theme.neutral_900),
          color(isDarkMode ? Theme.black : Theme.white),
          selector("i", [color(isDarkMode ? Theme.black : Theme.white)]),
        ]),
        active([backgroundColor(theme.neutral_900)]),
        disabled([
          borderColor(theme.neutral_600),
          color(theme.neutral_600),
          hover([backgroundColor(#transparent)]),
          opacity(0.5),
        ]),
      ])
    | Outline =>
      style(. [
        backgroundColor(#transparent),
        color(theme.neutral_900),
        border(#px(1), #solid, theme.neutral_900),
        selector("i", [color(theme.neutral_900)]),
        hover([
          backgroundColor(theme.neutral_900),
          color(isDarkMode ? Theme.black : Theme.white),
          selector("i", [color(isDarkMode ? Theme.black : Theme.white)]),
        ]),
        active([backgroundColor(theme.neutral_900)]),
        disabled([
          borderColor(theme.neutral_600),
          color(theme.neutral_600),
          hover([backgroundColor(#transparent)]),
          opacity(0.5),
        ]),
      ])
    | Text =>
      style(. [
        padding(#zero),
        backgroundColor(#transparent),
        color(theme.neutral_900),
        border(#px(1), #solid, #transparent),
        selector("i", [color(theme.neutral_900)]),
        hover([
          backgroundColor(#transparent),
          color(theme.primary_600),
          selector("i", [color(theme.primary_600)]),
        ]),
        active([backgroundColor(#transparent)]),
        disabled([color(theme.neutral_600), hover([backgroundColor(#transparent)]), opacity(0.5)]),
        selector(":focus", [outlineStyle(#none), backgroundColor(#transparent)]),
        Media.mobile([padding(#zero)]),
      ])
    }
    merge(. [base, custom])
  }
}

@react.component
let make = (
  ~variant=Primary,
  ~children,
  ~py=8,
  ~px=16,
  ~fsize=12,
  ~pySm=8,
  ~pxSm=16,
  ~href,
  ~noNewTab=false,
  ~style="",
  ~disabled=false,
  ~fullWidth=false,
) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <a
    href
    target={noNewTab ? "_self" : "_blank"}
    rel="noopener"
    className={CssJs.merge(. [
      Styles.btn(~variant, ~px, ~py, ~pxSm, ~pySm, ~fsize, ~fullWidth, theme, isDarkMode, ()),
      CssHelper.flexBox(~align=#center, ~justify=#center, ()),
      style,
    ])}>
    children
  </a>
}
