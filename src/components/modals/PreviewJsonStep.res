module Styles = {
  open CssJs
  let container = style(. [
    width(#px(468)),
    minHeight(#px(500)),
    padding3(~top=#px(32), ~h=#px(24), ~bottom=#px(24)),
    borderRadius(#px(4)),
  ])

  let resultContainer = style(. [minHeight(#px(400)), width(#percent(100.))])

  let btn = style(. [width(#percent(100.))])

  let jsonDisplay = (theme: Theme.t) =>
    style(. [
      resize(#none),
      fontSize(#px(12)),
      color(theme.neutral_900),
      backgroundColor(theme.neutral_000),
      border(#px(1), #solid, theme.neutral_200),
      borderRadius(#px(4)),
      width(#percent(100.)),
      height(#px(300)),
      overflowY(#scroll),
      marginBottom(#px(16)),
      fontFamilies([
        #custom("IBM Plex Mono"),
        #custom("cousine"),
        #custom("sfmono-regular"),
        #custom("Consolas"),
        #custom("Menlo"),
        #custom("liberation mono"),
        #custom("ubuntu mono"),
        #custom("Courier"),
        #monospace,
      ]),
    ])

  let resultIcon = style(. [width(#px(48)), marginBottom(#px(16))])

  let txhashContainer = style(. [cursor(#pointer)])
}

type state_t =
  | Preview(BandChainJS.Transaction.transaction_t)
  | Signing
  | Broadcasting
  | Success(Hash.t)
  | Error(string)

@react.component
let make = (~rawTx, ~onBack, ~account: AccountContext.t) => {
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let (state, setState) = React.useState(_ => Preview(rawTx))

  let client = React.useContext(ClientContext.context)
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let startBroadcast = async () => {
    dispatchModal(DisableExit)
    setState(_ => Signing)
    let signTxResult = await TxCreator3.signTx(account, rawTx)
    switch signTxResult {
    | Ok(signedTx) =>
      setState(_ => Broadcasting)
      let txResult = await client->TxCreator3.broadcastTx(signedTx)
      switch txResult {
      | Ok(tx) =>
        tx.success
          ? {
              setState(_ => Success(tx.txHash))
            }
          : {
              Js.Console.error(tx)
              setState(_ => Error(tx.code->TxResError.parse))
            }

      | Error(err) => setState(_ => Error(err))
      }
    | Error(err) => setState(_ => Error(err))
    }

    dispatchModal(EnableExit)
  }

  <div className=Styles.container>
    <Heading value="Confirm Transactions" size=Heading.H4 marginBottom=24 />
    {switch state {
    | Preview(rawTx) =>
      <div>
        <div className={CssHelper.mb(~size=16, ())}>
          <Text
            value="Please verify the transaction details below before proceeding" size=Text.Body1
          />
        </div>
        <textarea
          className={Styles.jsonDisplay(theme)}
          disabled=true
          defaultValue={rawTx
          ->BandChainJS.Transaction.getSignMessage
          ->JsBuffer.toUTF8
          ->Js.Json.parseExn
          ->TxCreator3.stringifyWithSpaces}
        />
        <div id="broadcastButtonContainer">
          <Button
            py=10
            style={Css.merge(list{Styles.btn, CssHelper.mb(~size=16, ())})}
            onClick={_ => {
              let _ = startBroadcast()
            }}>
            {"Broadcast"->React.string}
          </Button>
        </div>
        <Button py=10 style=Styles.btn onClick=onBack> {"Back"->React.string} </Button>
      </div>
    | Success(txHash) =>
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~direction=#column, ~justify=#center, ()),
          Styles.resultContainer,
        })}>
        <img alt="Success Icon" src=Images.success className=Styles.resultIcon />
        <div id="successMsgContainer" className={CssHelper.mb(~size=16, ())}>
          <Text
            value="Broadcast transaction success"
            size=Text.Body1
            block=true
            align=Text.Center
            color={theme.neutral_900}
          />
        </div>
        <Link className=Styles.txhashContainer route={Route.TxIndexPage(txHash)}>
          <Button py=8 px=13 variant=Button.Outline onClick={_ => {dispatchModal(CloseModal)}}>
            {"View Details"->React.string}
          </Button>
        </Link>
      </div>
    | Signing =>
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~direction=#column, ~justify=#center, ()),
          Styles.resultContainer,
        })}>
        <div className={CssHelper.mb(~size=16, ())}>
          <Icon name="fad fa-spinner-third fa-spin" size=48 />
        </div>
        <Text
          value="Waiting for signing transaction"
          size=Text.Body1
          block=true
          align=Text.Center
          color={theme.neutral_900}
        />
      </div>
    | Broadcasting =>
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~direction=#column, ~justify=#center, ()),
          Styles.resultContainer,
        })}>
        <div className={CssHelper.mb(~size=16, ())}>
          <Icon name="fad fa-spinner-third fa-spin" size=48 />
        </div>
        <Text
          value="Waiting for broadcasting transaction"
          size=Text.Body1
          block=true
          align=Text.Center
          color={theme.neutral_900}
        />
      </div>
    | Error(err) =>
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~direction=#column, ~justify=#center, ()),
          Styles.resultContainer,
        })}>
        <img alt="Fail Icon" src=Images.fail className=Styles.resultIcon />
        <div className={CssHelper.mb()}>
          <Text
            value="Broadcast transaction fail"
            size=Text.Body1
            block=true
            align=Text.Center
            color={theme.neutral_900}
          />
        </div>
        <Text value=err color={theme.error_600} align=Text.Center breakAll=true />
      </div>
    }}
  </div>
}
