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

  let modalTitle = (theme: Theme.t) =>
    style(. [display(#flex), justifyContent(#center), flexDirection(#column), alignItems(#center)])

  let rowContainer = style(. [padding2(~v=#zero, ~h=#px(12)), height(#percent(100.))])
}

@react.component
let make = (~chainID) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let client = React.useContext(ClientContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let (_, dispatchAccount) = React.useContext(AccountContext.context)

  let connectWalletKeplr = async () => {
    let chainID = await client->BandChainJS.Client.getChainId
    let wallet = await Wallet.createFromKeplr(chainID)
    let (address, pubKey) = await Wallet.getAddressAndPubKey(wallet)
    dispatchAccount(Connect(wallet, address, pubKey, chainID))
    ModalContext.CloseModal->dispatchModal
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
