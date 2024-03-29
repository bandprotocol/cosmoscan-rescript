module Styles = {
  open CssJs

  let container = (theme: Theme.t, ml, mr, h) => {
    style(. [
      height(#px(h)),
      width(#px(1)),
      marginLeft(#px(ml)),
      marginRight(#px(mr)),
      backgroundColor(theme.neutral_300),
      Media.mobile([marginTop(#px(15))]),
    ])
  }
}

@react.component
let make = (~ml=0, ~mr=0, ~h=32) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div className={Styles.container(theme, ml, mr, h)} />
}
