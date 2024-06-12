module Styles = {
  open CssJs

  let container = (theme: Theme.t, isDarkMode) =>
    style(. [
      display(#flex),
      flexDirection(#column),
      justifyContent(#center),
      alignItems(#center),
      position(#relative),
      width(#px(400)),
      padding2(~v=#px(24), ~h=#px(24)),
      background(isDarkMode ? theme.neutral_100 : theme.neutral_000),
    ])

  let innerContainer = style(. [display(#flex), flexDirection(#column), width(#percent(100.))])

  let loginSelectionContainer = style(. [padding2(~v=#zero, ~h=#px(24)), height(#percent(100.))])

  let modalTitle = (theme: Theme.t) =>
    style(. [display(#flex), justifyContent(#center), flexDirection(#column), alignItems(#center)])

  let rowContainer = style(. [padding2(~v=#zero, ~h=#px(12)), height(#percent(100.))])

  let header = (theme: Theme.t, active) =>
    style(. [
      display(#flex),
      flexDirection(#row),
      alignSelf(#center),
      alignItems(#center),
      padding2(~v=#zero, ~h=#px(20)),
      fontSize(#px(14)),
      fontWeight(active ? #bold : #normal),
      color(active ? theme.neutral_900 : theme.neutral_600),
    ])

  let loginList = (theme: Theme.t, active) =>
    style(. [
      display(#flex),
      width(#percent(100.)),
      height(#px(50)),
      borderRadius(#px(8)),
      border(#px(2), #solid, active ? theme.primary_600 : #transparent),
      cursor(#pointer),
      overflow(#hidden),
    ])

  let loginSelectionBackground = (theme: Theme.t, isDarkMode) =>
    style(. [background(isDarkMode ? theme.neutral_000 : theme.neutral_100)])

  let ledgerIcon = style(. [height(#px(28)), width(#px(28)), transform(translateY(#px(3)))])
  let ledgerImageContainer = active => style(. [opacity(active ? 1.0 : 0.5), marginRight(#px(15))])
}

type login_method_t =
  | Mnemonic
  | LedgerWithCosmos

let toLoginMethodString = method => {
  switch method {
  | Mnemonic => "Mnemonic Phrase"
  | LedgerWithCosmos => "Ledger - Cosmos"
  }
}

module LoginMethod = {
  @react.component
  let make = (~name, ~active, ~onClick) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.loginList(theme, active)} onClick>
      <div className={Styles.header(theme, active)}>
        {switch name {
        | LedgerWithCosmos =>
          <div className={Styles.ledgerImageContainer(active)}>
            <img
              alt="Cosmos Ledger Icon"
              src={isDarkMode ? Images.ledgerCosmosDarkIcon : Images.ledgerCosmosLightIcon}
              className=Styles.ledgerIcon
            />
          </div>
        | _ => <div />
        }}
        {name->toLoginMethodString->React.string}
      </div>
    </div>
  }
}

@react.component
let make = (~chainID) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let client = React.useContext(ClientContext.context)
  let (address, setAddress) = React.useState(_ => "")

  let connectWalletKeplr = async () => {
    let chainID = await client->BandChainJS.Client.getChainId
    await Keplr.enable(chainID)
    let account = await Keplr.getKey(chainID)
    setAddress(_ => account.bech32Address)
  }

  <div className={Styles.container(theme, isDarkMode)}>
    <div className={Styles.modalTitle(theme)}>
      <Heading value="Select Wallet" size=Heading.H3 />
      <VSpacing size=Spacing.lg />
    </div>
    <WalletButton onClick={_ => connectWalletKeplr()->ignore} wallet="Cosmostation" />
    <VSpacing size=Spacing.md />
    <WalletButton onClick={_ => connectWalletKeplr()->ignore} wallet="Keplr" />
    <VSpacing size=Spacing.md />
    <WalletButton onClick={_ => connectWalletKeplr()->ignore} wallet="Ledger" />
    <VSpacing size=Spacing.md />
    <WalletButton onClick={_ => connectWalletKeplr()->ignore} wallet="Mnemonic" />
    <VSpacing size=Spacing.md />
  </div>
}
