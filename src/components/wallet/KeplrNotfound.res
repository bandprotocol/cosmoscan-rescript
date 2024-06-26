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
    <img alt={`$wallet icon`} src={Images.keplr} className=Styles.icon />
    <VSpacing size={#px(8)} />
    <Heading size={H2} value="Keplr is not installed" />
    <VSpacing size={#px(8)} />
    <Text
      size={Body2}
      align={Center}
      value="If you have Keplr installed, refresh this page or follow your browser's instructions to connect your wallet."
    />
    <VSpacing size={#px(24)} />
    <LinkButton href="https://www.keplr.app/download" fullWidth=true fsize=16>
      {"Install Keplr"->React.string}
    </LinkButton>
  </div>
}
