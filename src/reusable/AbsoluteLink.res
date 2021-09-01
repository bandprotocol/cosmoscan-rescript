module Styles = {
  open CssJs

  let a = (theme: Theme.t) =>
    style(. [textDecoration(#none), color(theme.textPrimary), hover([color(theme.baseBlue)])])
}

@react.component
let make = (~href, ~className="", ~children) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <a href className={CssJs.merge(. [Styles.a(theme), className])} target="_blank" rel="noopener">
    children
  </a>
}
