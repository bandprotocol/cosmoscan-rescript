module Styles = {
  open CssJs

  let containerBase = (height_, theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      selector("> div", [height(#px(height_))]),
    ])
}

@react.component
let make = (~children, ~height=40) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className={Styles.containerBase(height, theme, isDarkMode)}> children </div>
}
