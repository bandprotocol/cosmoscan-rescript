module Styles = {
  open CssJs

  let container = (theme: Theme.t, isDarkMode) =>
    style(. [
      display(#flex),
      flexDirection(#column),
      justifyContent(#center),
      alignItems(#center),
      position(#relative),
    ])

  let icon = {
    style(. [width(#px(48)), height(#px(48))])
  }
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (_, _, accountError, _) = React.useContext(WalletPopupContext.context)

  <div className={Styles.container(theme, isDarkMode)}>
    <img alt="cosmostation icon" src={Images.fail} className=Styles.icon />
    <VSpacing size={#px(8)} />
    <Heading size={H2} value="Something Wrong" />
    <VSpacing size={#px(8)} />
    <Text size={Body2} align={Center} value=accountError />
  </div>
}
