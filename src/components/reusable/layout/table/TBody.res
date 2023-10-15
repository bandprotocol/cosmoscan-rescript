module Styles = {
  open CssJs

  let containerBase = (pv, ph, theme: Theme.t, isDarkMode, _overflow) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      borderTop(#px(1), #solid, isDarkMode ? theme.neutral_300 : theme.neutral_100),
      padding2(~v=pv, ~h=ph),
      overflow(_overflow),
      selector("&:last-child", [paddingBottom(#zero)]),
    ])
}

@react.component
let make = (~children, ~paddingV=#px(20), ~paddingH=#zero, ~overflow=#hidden) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = ThemeContext.use()
  <div
    className={CssJs.merge(. [
      Styles.containerBase(paddingV, paddingH, theme, isDarkMode, overflow),
    ])}>
    children
  </div>
}
