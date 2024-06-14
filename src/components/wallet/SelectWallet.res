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

  let modalTitle = (theme: Theme.t) =>
    style(. [display(#flex), justifyContent(#center), flexDirection(#column), alignItems(#center)])

  let rowContainer = style(. [padding2(~v=#zero, ~h=#px(12)), height(#percent(100.))])
}

@react.component
let make = (~setAccountBoxState) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let client = React.useContext(ClientContext.context)
  let (_, dispatchAccount) = React.useContext(AccountContext.context)

  let connectWalletKeplr = async () => {
    if Keplr.keplr->Belt.Option.isNone {
      setAccountBoxState(_ => "keplrNotfound")
    } else {
      let chainID = await client->BandChainJS.Client.getChainId

      try {
        let wallet = await Wallet.createFromKeplr(chainID)
        let (address, pubKey) = await Wallet.getAddressAndPubKey(wallet)
        dispatchAccount(Connect(wallet, address, pubKey, chainID))

        setAccountBoxState(_ => "noShow")
      } catch {
      | Js.Exn.Error(e) =>
        Js.Console.log(e)
        setAccountBoxState(_ => "keplrBandNotfound")
      }
    }
  }

  <div className={Styles.container(theme, isDarkMode)}>
    <div className={Styles.modalTitle(theme)}>
      <Heading value="Select Wallet" size=Heading.H3 />
      <VSpacing size=Spacing.lg />
    </div>
    <WalletButton onClick={_ => connectWalletKeplr()->ignore} wallet="Keplr" />
    <VSpacing size=Spacing.md />
    <WalletButton onClick={_ => connectWalletKeplr()->ignore} wallet="Ledger" />
    <VSpacing size=Spacing.md />
    <WalletButton onClick={_ => connectWalletKeplr()->ignore} wallet="Mnemonic" />
    <VSpacing size=Spacing.md />
  </div>
}
