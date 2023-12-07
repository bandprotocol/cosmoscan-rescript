module Styles = {
  open CssJs

  let infoContainer = (~theme: Theme.t, ~isDarkMode, ~px, ~py, ~pxSm, ~pySm, ~radius, ()) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      borderRadius(#px(radius)),
      boxShadow(
        Shadow.box(
          ~x=#zero,
          ~y=#px(2),
          ~blur=#px(4),
          ~spread=#px(1),
          Css.rgba(16, 18, 20, #num(0.15)),
        ),
      ),
      padding2(~v=#px(py), ~h=#px(px)),
      position(#relative),
      Media.mobile([padding2(~v=#px(pySm), ~h=#px(pxSm))]),
    ])
}

@react.component
let make = (~children, ~px=32, ~py=32, ~pxSm=16, ~pySm=16, ~radius=16, ~style="") => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = ThemeContext.use()
  <div
    className={Css.merge(list{
      Styles.infoContainer(~theme, ~isDarkMode, ~px, ~py, ~pxSm, ~pySm, ~radius, ()),
      style,
    })}>
    children
  </div>
}
