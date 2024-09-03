module Styles = {
  open CssJs

  let container = style(. [display(#flex), flexDirection(#column), width(#percent(100.))])

  let inputBar = (theme: Theme.t, isDarkMode) =>
    style(. [
      width(#percent(100.)),
      height(#px(37)),
      paddingLeft(#px(9)),
      borderRadius(#px(6)),
      border(#px(1), #solid, isDarkMode ? theme.neutral_400 : theme.neutral_200),
      backgroundColor(isDarkMode ? theme.neutral_300 : theme.neutral_000),
      outlineStyle(#none),
      color(theme.neutral_900),
    ])

  let connectBtn = style(. [width(#percent(100.)), height(#px(37))])
}

@react.component
let make = (~chainID) => {
  let (_, dispatchAccount) = React.useContext(AccountContext.context)
  let (mnemonic, setMnemonic) = React.useState(_ => "")
  let (errMsg, setErrMsg) = React.useState(_ => "")
  let (_, setAccountBoxState, _, _) = React.useContext(WalletPopupContext.context)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let createMnemonic = async () =>
    if mnemonic->Js.String.trim == "" {
      setErrMsg(_ => "Invalid mnemonic")
    } else {
      let wallet = Wallet.createFromMnemonic(mnemonic)

      wallet
      ->Wallet.getAddressAndPubKey
      ->Promise.then(((address, pubKey)) => {
        dispatchAccount(Connect(wallet, address, pubKey, chainID))
        setAccountBoxState(_ => "noShow")
        Promise.resolve()
      })
      ->Promise.catch(err => {
        Js.Console.log(err)
        setErrMsg(_ => "An error occurred.")
        Promise.resolve()
      })
      ->ignore
    }

  <div className=Styles.container>
    <Heading value="Enter Your Mnemonic" size=Heading.H5 />
    <VSpacing size=Spacing.md />
    <input
      id="mnemonicInput"
      autoFocus=true
      value=mnemonic
      className={Styles.inputBar(theme, isDarkMode)}
      onChange={event => setMnemonic(ReactEvent.Form.target(event)["value"])}
      onKeyDown={event =>
        switch ReactEvent.Keyboard.key(event) {
        | "Enter" =>
          ReactEvent.Keyboard.preventDefault(event)
          createMnemonic()->ignore
        | _ => ()
        }}
    />
    <VSpacing size=Spacing.lg />
    <div id="mnemonicConnectButton" className={CssHelper.flexBox(~justify=#flexEnd, ())}>
      <Button px=20 py=8 onClick={_ => createMnemonic()->ignore} style=Styles.connectBtn>
        {"Connect"->React.string}
      </Button>
    </div>
    {switch errMsg->Js.String2.length {
    | 0 => React.null
    | _ =>
      <>
        <VSpacing size=Spacing.lg />
        <Text value=errMsg color={theme.error_600} />
      </>
    }}
  </div>
}
