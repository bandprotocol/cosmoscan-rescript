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
    ~color_: Theme.color_t,
    ~activeColor_: Theme.color_t,
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
        backgroundColor(isActive ? activeColor_ : color_),
        color(theme.white),
        border(#px(1), #solid, isActive ? activeColor_ : color_),
        hover([backgroundColor(isActive ? activeColor_ : color_)]),
        active([backgroundColor(isActive ? activeColor_ : color_)]),
        disabled([
          backgroundColor(isDarkMode ? theme.primary_600 : theme.neutral_200),
          color(Theme.white),
          borderColor(isDarkMode ? theme.primary_600 : theme.neutral_200),
          opacity(0.5),
        ]),
      ])
    | Outline =>
      style(. [
        backgroundColor(isActive ? activeColor_ : #transparent),
        color(isActive ? Theme.white : theme.neutral_900),
        border(#px(1), #solid, color_),
        selector("i", [color(theme.neutral_900)]),
        hover([
          backgroundColor(activeColor_),
          color(isDarkMode ? Theme.black : Theme.white),
          selector("i", [color(isDarkMode ? Theme.black : Theme.white)]),
        ]),
        active([backgroundColor(activeColor_)]),
        disabled([
          borderColor(theme.neutral_600),
          color(theme.neutral_600),
          hover([backgroundColor(#transparent)]),
          opacity(0.5),
        ]),
        selector(
          "&.selected",
          [
            backgroundColor(activeColor_),
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
  ~color=?,
  ~activeColor=?,
) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <button
    className={CssJs.merge(. [
      Styles.btn(
        ~variant,
        ~px,
        ~py,
        ~pxSm,
        ~pySm,
        ~fsize,
        theme,
        isDarkMode,
        ~isActive,
        ~color_=color->Belt.Option.getWithDefault(theme.primary_600),
        ~activeColor_=activeColor->Belt.Option.getWithDefault(theme.primary_600),
        (),
      ),
      CssHelper.flexBox(~align=#center, ~justify=#center, ()),
      style,
      className,
    ])}
    onClick
    disabled>
    children
  </button>
}
