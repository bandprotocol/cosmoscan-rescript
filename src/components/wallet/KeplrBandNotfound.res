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
    <Heading size={H2} value="BandChain is not yet add to Keplr" />
    <VSpacing size={#px(8)} />
    <Text size={Body2} align={Center} value="please add BandChain to your Keplr wallet extension" />
    <VSpacing size={#px(24)} />
    <LinkButton href="https://chains.keplr.app/" fullWidth=true fsize=16>
      {"Add BandChain to Keplr"->React.string}
    </LinkButton>
  </div>
}
