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
}

module InstructionCard = {
  @react.component
  let make = (~title, ~url) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div className=Styles.instructionCard>
      <Text value=title color={theme.neutral_900} weight=Text.Semibold />
      <img alt="Ledger Device" src=url className=Styles.ledgerGuide />
    </div>
  }
}

type result_t =
  | Nothing
  | Loading
  | Error(string)

@react.component
let make = (~chainID, ~ledgerApp) => {
  let (_, dispatchAccount) = React.useContext(AccountContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let (result, setResult) = React.useState(_ => Nothing)
  let (accountIndex, setAccountIndex) = React.useState(_ => 0)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let createLedger = async (accountIndex: int): unit => {
    dispatchModal(DisableExit)
    setResult(_ => Loading)
    try {
      let wallet = await Wallet.createFromLedger(ledgerApp, accountIndex)
      let (address, pubKey) = await Wallet.getAddressAndPubKey(wallet)
      dispatchAccount(Connect(wallet, address, pubKey, chainID))
      dispatchModal(CloseModal)
    } catch {
    | Js.Exn.Error(e) =>
      Js.Console.log(e)
      setResult(_ => Error("An error occured"))
      dispatchModal(EnableExit)
    }
  }

  <div className=Styles.container>
    <VSpacing size=Spacing.xxl />
    <Text value="1. Select HD Derivation Path" weight=Text.Semibold color={theme.neutral_900} />
    <VSpacing size=Spacing.md />
    <div className={Styles.selectWrapper(theme, isDarkMode)}>
      <div
        className={CssHelper.selectWrapper(
          ~pRight=8,
          ~mW=100,
          ~size=10,
          ~fontColor=theme.neutral_900,
          (),
        )}>
        <select
          className={Styles.selectContent(theme)}
          onChange={event => {
            let newAccountIndex =
              ReactEvent.Form.target(event)["value"]->Belt.Int.fromString->Belt.Option.getExn
            setAccountIndex(_ => newAccountIndex)
          }}>
          {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
          ->Belt.Array.map(index =>
            <option key={index->Belt.Int.toString} value={index->Belt.Int.toString}>
              {
                let prefixPath = switch ledgerApp {
                | Ledger.Cosmos => "44/118/0/0/"
                }
                (prefixPath ++ index->Belt.Int.toString)->React.string
              }
            </option>
          )
          ->React.array}
        </select>
      </div>
    </div>
    <VSpacing size=Spacing.xxl />
    <Text value="2. On Your Ledger" weight=Text.Semibold color={theme.neutral_900} />
    <VSpacing size=Spacing.xxl />
    <InstructionCard title="1. Enter Pin Code" url=Images.ledgerStep1 />
    <VSpacing size=Spacing.lg />
    {switch ledgerApp {
    | Ledger.Cosmos => <InstructionCard title="2. Open Cosmos" url=Images.ledgerStep2Cosmos />
    }}
    <div className=Styles.resultContainer>
      {switch result {
      | Loading => <Text value="Please accept with ledger" weight=Text.Medium />
      | Error(err) => <Text value=err color=theme.error_600 weight=Text.Medium size=Text.Body1 />
      | Nothing => React.null
      }}
    </div>
    {result == Loading
      ? <div className={Styles.connectBtn(~isLoading=true, ())}>
          <div className=Styles.connectingBtnContainer>
            <Icon name="fad fa-spinner-third fa-spin" size=16 />
            <Text value="Connecting..." weight=Text.Bold size=Text.Body2 />
          </div>
        </div>
      : <Button
          style={Styles.connectBtn(~isLoading=false, ())}
          onClick={_ => {
            switch (Os.isWindows(), Os.checkHID()) {
            | (true, false) =>
              open Webapi.Dom
              let isConfirm =
                window->Window.confirm(
                  "To use Ledger Nano on Windows 10, please enable \"Experimental Web Platform Features\" by copy-paste \"chrome://flags/#enable-experimental-web-platform-features\". Click OK to copy.",
                )
              isConfirm
                ? Copy.copy("chrome://flags/#enable-experimental-web-platform-features")
                : ()
            | (_, _) => {
                let _ = createLedger(accountIndex)
              }
            }
          }}>
          {"Connect to Ledger"->React.string}
        </Button>}
    <VSpacing size=Spacing.lg />
  </div>
}
