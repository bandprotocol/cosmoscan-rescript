module Styles = {
  open CssJs

  let container = style(. [display(#flex), alignItems(#center)])
  let baseSwitch = (theme: Theme.t, isChecked) =>
    style(. [
      backgroundColor(isChecked ? theme.primary_600 : theme.neutral_400),
      borderRadius(#px(100)),
      width(#px(36)),
      height(#px(20)),
      cursor(pointer),
    ])

  let switchCircle = (theme: Theme.t, isChecked) =>
    style(. [
      backgroundColor(theme.neutral_000),
      borderRadius(#px(100)),
      width(#px(16)),
      height(#px(16)),
      margin(#px(2)),
      display(#block),
      transition(~duration=200, "all"),
      transform(
        if isChecked {
          translateX(#px(16))
        } else {
          translateX(#px(0))
        },
      ),
    ])
}

@react.component
let make = (~isChecked: bool, ()) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.container>
    <div className={Styles.baseSwitch(theme, isChecked)}>
      <span className={Styles.switchCircle(theme, isChecked)} />
    </div>
  </div>
}
