module Styles = {
  open CssJs

  let containerBase = (theme: Theme.t) =>
    style(. [
      overflow(#hidden),
      Media.mobile([padding2(~v=#zero, ~h=#px(15))]),
    ])
}

@react.component
let make = (~children) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{Styles.containerBase(theme)})}>
    children
  </div>
}
