module Styles = {
  open CssJs

  let infoContainer = (theme: Theme.t, isDarkMode, px, py, pxSm, pySm) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_300 : theme.neutral_100),
      borderRadius(#px(12)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.2)))),
      padding2(~v=#px(py), ~h=#px(px)),
      position(#relative),
      Media.mobile([padding2(~v=#px(pySm), ~h=#px(pxSm))]),
    ])
}

@react.component
let make = (~children, ~px=32, ~py=32, ~pxSm=16, ~pySm=16, ~style="") => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{
      Styles.infoContainer(theme, isDarkMode, px, py, pxSm, pySm),
      CommonStyles.card(theme, isDarkMode),
      style,
    })}>
    children
  </div>
}
