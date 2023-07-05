module Styles = {
  open CssJs

  let container = (theme: Theme.t, isDarkMode, mt, mb, color) =>
    style(. [
      width(#percent(100.)),
      marginTop(#px(mt)),
      marginBottom(#px(mb)),
      height(#px(1)),
      backgroundColor(color->Belt.Option.getWithDefault(theme.neutral_300)),
      Media.mobile([marginTop(#px(15))]),
    ])
}

@react.component
let make = (~mt=15, ~mb=15, ~color=?) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <div className={Styles.container(theme, isDarkMode, mt, mb, color)} />
}
