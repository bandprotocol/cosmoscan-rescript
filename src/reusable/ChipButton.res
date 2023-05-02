type btn_style_t =
  | Primary
  | Outline

module Styles = {
  open CssJs

  let btn = (
    ~variant: btn_style_t=Primary,
    ~fsize=12,
    ~px=25,
    ~py=13,
    ~pxSm=px,
    ~pySm=py,
    theme: Theme.t,
    isDarkMode,
    ~isActive=false,
    (),
  ) => {
    let base = style(. [
      display(#block),
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
      Media.mobile([padding2(~v=#px(pySm), ~h=#px(pxSm))]),
    ])

    let custom = switch variant {
    | Primary =>
      style(. [
        backgroundColor(theme.primary_600),
        color(theme.white),
        border(#px(1), #solid, theme.primary_600),
        hover([backgroundColor(theme.primary_600)]),
        active([backgroundColor(theme.primary_600)]),
        disabled([
          backgroundColor(isDarkMode ? theme.primary_600 : theme.neutral_200),
          color(Theme.white),
          borderColor(isDarkMode ? theme.primary_600 : theme.neutral_200),
          opacity(0.5),
        ]),
      ])
    | Outline =>
      style(. [
        backgroundColor(isActive ? theme.primary_600 : #transparent),
        color(isActive ? Theme.white : theme.neutral_900),
        border(#px(1), #solid, theme.primary_600),
        selector("i", [color(theme.neutral_900)]),
        hover([
          backgroundColor(theme.primary_600),
          color(isDarkMode ? Theme.black : Theme.white),
          selector("i", [color(isDarkMode ? Theme.black : Theme.white)]),
        ]),
        active([backgroundColor(theme.primary_600)]),
        disabled([
          borderColor(theme.neutral_600),
          color(theme.neutral_600),
          hover([backgroundColor(#transparent)]),
          opacity(0.5),
        ]),
        selector(
          "&.selected",
          [
            backgroundColor(theme.primary_600),
            color(isDarkMode ? Theme.black : Theme.white),
            selector("i", [color(isDarkMode ? Theme.black : Theme.white)]),
          ],
        ),
      ])
    }
    merge(. [base, custom])
  }
}

@react.component
let make = (
  ~variant: btn_style_t=Primary,
  ~children,
  ~py=4,
  ~px=12,
  ~fsize=12,
  ~pySm=4,
  ~pxSm=12,
  ~onClick,
  ~style="",
  ~disabled=false,
  ~className="",
  ~isActive=false,
) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <button
    className={CssJs.merge(. [
      Styles.btn(~variant, ~px, ~py, ~pxSm, ~pySm, ~fsize, theme, isDarkMode, ~isActive, ()),
      CssHelper.flexBox(~align=#center, ~justify=#center, ()),
      style,
      className,
    ])}
    onClick
    disabled>
    children
  </button>
}
