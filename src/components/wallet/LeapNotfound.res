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

  <div className={Styles.container(theme, isDarkMode)}>
    <img alt="leap icon" src={Images.leap} className=Styles.icon />
    <VSpacing size={#px(8)} />
    <Heading size={H2} value="Leap is not installed" />
    <VSpacing size={#px(8)} />
    <Text
      size={Body2}
      align={Center}
      value="If you have Leap installed, refresh this page or follow your browser's instructions to connect your wallet."
    />
    <VSpacing size={#px(24)} />
    <LinkButton href="https://www.leapwallet.io/#download" fullWidth=true fsize=16>
      {"Install Leap"->React.string}
    </LinkButton>
  </div>
}
