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
  let (_, dispatchAccount) = React.useContext(AccountContext.context)
  let trackingSub = TrackingSub.use()

  let connectWalletKeplr = async chainID => {
    if Keplr.keplr->Belt.Option.isNone {
      setAccountBoxState(_ => "keplrNotfound")
    } else {
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

  let connectMnemonic = () => setAccountBoxState(_ => "connectMnemonic")

  {
    switch trackingSub {
    | Data({chainID}) =>
      <div className={Styles.container(theme, isDarkMode)}>
        <div className={Styles.modalTitle(theme)}>
          <Heading value="Select Wallet" size=Heading.H3 />
          <VSpacing size=Spacing.lg />
        </div>
        <WalletButton onClick={_ => connectWalletKeplr(chainID)->ignore} wallet="Keplr" />
        <VSpacing size=Spacing.md />
        <WalletButton onClick={_ => connectWalletKeplr(chainID)->ignore} wallet="Ledger" />
        <VSpacing size=Spacing.md />
        <WalletButton onClick={_ => connectMnemonic()} wallet="Mnemonic" />
        <VSpacing size=Spacing.md />
      </div>
    | Error(_) => React.null
    | _ => <LoadingCensorBar.CircleSpin height=200 />
    }
  }
}
