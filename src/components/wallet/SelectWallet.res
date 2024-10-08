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
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchAccount) = React.useContext(AccountContext.context)
  let (_, setAccountBoxState, _, setAccountError) = React.useContext(WalletPopupContext.context)
  let trackingSub = TrackingSub.use()

  let connectWalletLeap = async chainID => {
    if Leap.leap->Belt.Option.isNone {
      setAccountBoxState(_ => "leapNotfound")
    } else {
      try {
        let wallet = await Wallet.createFromLeap(chainID)
        let (address, pubKey) = await Wallet.getAddressAndPubKey(wallet)
        dispatchAccount(Connect(wallet, address, pubKey, chainID))

        setAccountBoxState(_ => "noShow")
      } catch {
      | Js.Exn.Error(e) =>
        Js.Console.log(e)
        setAccountError(_ => e->Js.Exn.message->Belt.Option.getWithDefault(""))
        setAccountBoxState(_ => "leapBandNotfound")
      }
    }
  }

  let connectWalletKeplr = async chainID => {
    if Keplr.keplr->Belt.Option.isNone {
      setAccountBoxState(_ => "keplrNotfound")
      // check if keplr really not found
    } else if Keplr.getChainInfosWithoutEndpoints->Belt.Option.isNone {
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
        setAccountError(_ => e->Js.Exn.message->Belt.Option.getWithDefault(""))
        setAccountBoxState(_ => "keplrBandNotfound")
      }
    }
  }

  let connectWalletCosmostation = async chainID => {
    if Cosmostation.cosmostation->Belt.Option.isNone {
      setAccountBoxState(_ => "cosmostationNotfound")
      // check if cosmostation really not found
    } else {
      try {
        let wallet = await Wallet.createFromCosmostation(chainID)
        let (address, pubKey) = await Wallet.getAddressAndPubKey(wallet)
        dispatchAccount(Connect(wallet, address, pubKey, chainID))

        setAccountBoxState(_ => "noShow")
      } catch {
      | Js.Exn.Error(e) =>
        Js.Console.log(e)
        setAccountError(_ => e->Js.Exn.message->Belt.Option.getWithDefault(""))
        setAccountBoxState(_ => "error")
      }
    }
  }

  let connectMnemonic = () => setAccountBoxState(_ => "connectMnemonic")
  let connectLedger = () => setAccountBoxState(_ => "connectLedger")

  {
    switch trackingSub {
    | Data({chainID}) =>
      <div className={Styles.container(theme, isDarkMode)}>
        <div className={Styles.modalTitle(theme)}>
          <Heading value="Select Wallet" size=Heading.H3 />
          <VSpacing size=Spacing.lg />
        </div>
        <WalletButton onClick={_ => connectWalletLeap(chainID)->ignore} wallet=Wallet.Leap />
        <VSpacing size=Spacing.md />
        <WalletButton onClick={_ => connectWalletKeplr(chainID)->ignore} wallet=Wallet.Keplr />
        <VSpacing size=Spacing.md />
        <WalletButton
          onClick={_ => connectWalletCosmostation(chainID)->ignore} wallet=Wallet.Cosmostation
        />
        <VSpacing size=Spacing.md />
        <WalletButton onClick={_ => connectLedger()} wallet=Wallet.Ledger />
        <VSpacing size=Spacing.md />
        {
          let currentChainID = chainID->ChainIDBadge.parseChainID
          currentChainID != LaoziMainnet
            ? <>
                <WalletButton onClick={_ => connectMnemonic()} wallet=Wallet.Mnemonic />
                <VSpacing size=Spacing.md />
              </>
            : React.null
        }
      </div>
    | Error(_) => React.null
    | _ => <LoadingCensorBar.CircleSpin height=200 />
    }
  }
}
