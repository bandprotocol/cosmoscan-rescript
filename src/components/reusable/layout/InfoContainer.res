module Styles = {
  open CssJs

  let infoContainer = (theme: Theme.t, isDarkMode, px, py) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      borderRadius(#px(16)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.2)))),
      padding2(~v=#px(py), ~h=#px(px)),
      position(#relative),
      Media.mobile([padding(#px(16))]),
    ])
}

@react.component
let make = (~children, ~px=32, ~py=32, ~pxSm=16, ~pySm=16, ~style="") => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <div className={Css.merge(list{Styles.infoContainer(theme, isDarkMode, px, py), style})}>
    children
  </div>
}
