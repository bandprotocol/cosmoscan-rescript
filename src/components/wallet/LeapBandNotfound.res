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
let make = (~chainID) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className={Styles.container(theme, isDarkMode)}>
    <img alt="leap icon" src={Images.leap} className=Styles.icon />
    <VSpacing size={#px(8)} />
    <Heading size={H2} value={`${chainID} is not yet add to Leap`} />
    <VSpacing size={#px(8)} />
    <Text
      size={Body2} align={Center} value={`please add ${chainID} to your Leap wallet extension`}
    />
  </div>
}
