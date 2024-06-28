module Styles = {
  open CssJs

  let container = style(. [
    display(#flex),
    flexDirection(#column),
    width(#percent(100.)),
    padding2(~v=#px(0), ~h=#px(18)),
  ])

  let instructionCard = style(. [
    display(#flex),
    flexDirection(#row),
    alignItems(#center),
    height(#px(50)),
    width(#percent(100.)),
    justifyContent(#spaceBetween),
  ])

  let resultContainer = style(. [
    display(#flex),
    flexDirection(#row),
    alignItems(#center),
    justifyContent(#spaceBetween),
    height(#px(35)),
  ])

  let ledgerGuide = style(. [width(#px(248)), height(#px(38))])

  let connectBtn = (~isLoading, ()) =>
    style(. [
      marginTop(#px(10)),
      width(#percent(100.)),
      borderRadius(#px(4)),
      cursor(isLoading ? #default : #pointer),
      pointerEvents(isLoading ? #none : #auto),
      alignSelf(#flexEnd),
    ])

  let selectWrapper = (theme: Theme.t, isDarkMode) =>
    style(. [
      display(#flex),
      padding2(~v=#px(3), ~h=#px(8)),
      justifyContent(#center),
      alignItems(#center),
      width(#percent(100.)),
      height(#px(37)),
      left(#zero),
      top(#px(32)),
      background(isDarkMode ? theme.neutral_300 : theme.neutral_000),
      border(#px(1), #solid, isDarkMode ? theme.neutral_400 : theme.neutral_200),
      borderRadius(#px(6)),
    ])

  let selectContent = (theme: Theme.t) =>
    style(. [
      backgroundColor(#transparent),
      borderColor(#transparent),
      color(theme.neutral_900),
      width(#px(100)),
      lineHeight(#em(1.41)),
      outlineStyle(#none),
    ])

  let connectingBtnContainer = style(. [
    width(#px(104)),
    display(#flex),
    justifyContent(#spaceBetween),
  ])

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

  let derivationPath = (theme: Theme.t) =>
    style(. [
      display(#flex),
      flexDirection(#column),
      justifyContent(#center),
      padding(#px(16)),
      marginTop(#px(16)),
      backgroundColor(theme.neutral_100),
      borderRadius(#px(8)),
    ])

  let derivationInput = style(. [
    display(#flex),
    marginTop(#px(8)),
    marginBottom(#px(4)),
    alignItems(#baseline),
  ])
}

type result_t =
  | Nothing
  | Loading
  | Error(string)

@react.component
let make = (~chainID) => {
  let (_, dispatchAccount) = React.useContext(AccountContext.context)
  let (result, setResult) = React.useState(_ => Nothing)
  let (accountIndex, setAccountIndex) = React.useState(_ => "0")
  let (errMsg, setErrMsg) = React.useState(_ => "")
  let (showAdvance, setShowAdvance) = React.useState(_ => false)
  let (_, setAccountBoxState, _, _) = React.useContext(WalletPopupContext.context)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let createLedger = async (accountIndex: int): unit => {
    setResult(_ => Loading)
    try {
      let wallet = await Wallet.createFromLedger(Ledger.Cosmos, accountIndex)
      let (address, pubKey) = await Wallet.getAddressAndPubKey(wallet)
      dispatchAccount(Connect(wallet, address, pubKey, chainID))
      setAccountBoxState(_ => "noShow")
    } catch {
    | Js.Exn.Error(e) =>
      Js.Console.log(e)
      setResult(_ => Error("An error occured"))
    }
  }

  <div className=Styles.container>
    <Heading value="Open Cosmos app on your ledger" size=Heading.H5 />
    <VSpacing size=Spacing.md />
    <img alt="Ledger Device" src=Images.ledgerStep2Cosmos className=Styles.ledgerGuide />
    <VSpacing size=Spacing.md />
    <div className={CssHelper.flexBox()}>
      <SwitchV2 checked=showAdvance onClick={_ => setShowAdvance(_ => !showAdvance)} />
      <Text value="Advanced settings" size=Text.Body1 color=theme.neutral_900 />
    </div>
    {showAdvance
      ? <div className={Styles.derivationPath(theme)}>
          <Text value="HD Derivation Path" weight=Text.Semibold color=theme.neutral_900 />
          <VSpacing size=Spacing.sm />
          <div className=Styles.derivationInput>
            <Text value="44/118/0/0/" code=true color=theme.neutral_900 />
            <HSpacing size=Spacing.sm />
            <input
              autoFocus=true
              type_="number"
              value=accountIndex
              className={Styles.inputBar(theme, isDarkMode)}
              onChange={event => setAccountIndex(ReactEvent.Form.target(event)["value"])}
              onKeyDown={event =>
                switch ReactEvent.Keyboard.key(event) {
                | "Enter" =>
                  ReactEvent.Keyboard.preventDefault(event)
                  createLedger(accountIndex->Belt.Int.fromString->Belt.Option.getExn)->ignore
                | _ => ()
                }}
            />
          </div>
        </div>
      : React.null}
    <VSpacing size=Spacing.lg />
    <div id="mnemonicConnectButton" className={CssHelper.flexBox(~justify=#flexEnd, ())}>
      <Button
        px=20
        py=8
        onClick={_ => createLedger(accountIndex->Belt.Int.fromString->Belt.Option.getExn)->ignore}
        style=Styles.connectBtn>
        {"Connect to Ledger"->React.string}
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
