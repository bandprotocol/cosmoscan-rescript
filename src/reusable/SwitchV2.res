%%raw("require('./SwitchV2.css')")

module Styles = {
  open CssJs

  let formSwitch = (theme: Theme.t) =>
    style(. [
      selector("& i", [backgroundColor(theme.neutral_400)]),
      selector("& i::after", [backgroundColor(theme.white)]),
      selector("& input:checked + i", [backgroundColor(theme.primary_600)]),
    ])
}

@react.component
let make = (~checked, ~onClick) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <label className={Styles.formSwitch(theme) ++ " form-switch"}>
    <input checked onClick type_="checkbox" />
    <i />
  </label>
}
