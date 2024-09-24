module Styles = {
  open CssJs
  let container = style(. [
    width(#px(516)),
    padding3(~top=#px(32), ~h=#px(24), ~bottom=#px(24)),
    borderRadius(#px(4)),
  ])

  let tabGroup = (theme: Theme.t) =>
    style(. [display(#flex), width(#percent(100.)), borderBottom(#px(1), solid, theme.neutral_300)])

  let tabContainer = (theme: Theme.t, active) =>
    style(. [
      display(inlineFlex),
      justifyContent(center),
      alignItems(center),
      cursor(pointer),
      width(#percent(50.)),
      padding4(~top=#zero, ~right=#zero, ~bottom=#px(4), ~left=#zero),
      borderBottom(#px(4), solid, active ? theme.primary_600 : transparent),
      Media.mobile([whiteSpace(nowrap)]),
    ])

  let summaryContainer = style(. [padding2(~v=#px(24), ~h=#px(0))])
  let borderBottomLine = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_300)])
  let currentDelegateHeader = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_200), margin2(~v=#px(4), ~h=#px(0))])

  let delegateAmountContainer = (theme: Theme.t) =>
    style(. [borderRadius(#px(8)), background(theme.neutral_100), padding2(~v=#px(12), ~h=#px(16))])

  let info = style(. [
    display(#flex),
    justifyContent(#spaceBetween),
    alignItems(#center),
    marginBottom(#px(24)),
  ])
  let divider = (theme: Theme.t) =>
    style(. [
      height(#px(1)),
      background(theme.neutral_300),
      width(#percent(100.)),
      marginTop(#px(24)),
      marginBottom(#px(24)),
    ])

  let buttonContainer = style(. [
    display(#flex),
    justifyContent(#spaceBetween),
    alignItems(center),
    columnGap(#px(16)),
  ])
  let confirmButton = style(. [flex(#num(1.))])
  let jsonDisplay = (theme: Theme.t) =>
    style(. [
      resize(#none),
      fontSize(#px(12)),
      color(theme.neutral_900),
      backgroundColor(theme.neutral_000),
      border(#px(1), #solid, theme.neutral_200),
      borderRadius(#px(4)),
      width(#percent(100.)),
      height(#px(450)),
      overflowY(#scroll),
      margin2(~v=#px(16), ~h=#px(0)),
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
  let resultContainer = style(. [minHeight(#px(400)), width(#percent(100.))])
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
let make = (~rawTx, ~onBack, ~account: AccountContext.t, ~msgsOpt, ~msg, ~txFee) => {
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let trackingSub = TrackingSub.use()
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let client = React.useContext(ClientContext.context)
  let (state, setState) = React.useState(_ => Preview(rawTx))

  let tab = (~name, ~active, ~setTab) => {
    <div key=name className={Styles.tabContainer(theme, active)} onClick={_ => setTab()}>
      <Text
        value=name
        weight={active ? Text.Semibold : Text.Regular}
        color={active ? theme.neutral_900 : theme.neutral_600}
        size=Text.Body1
      />
    </div>
  }

  let startBroadcast = async () => {
    dispatchModal(DisableExit)
    setState(_ => Signing)
    let signTxResult = await TxCreator.signTx(account, rawTx)
    switch signTxResult {
    | Ok(signedTx) =>
      setState(_ => Broadcasting)
      let txResult = await client->TxCreator.broadcastTx(signedTx)
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

  <div className={Styles.container}>
    {switch state {
    | Preview(rawTx) =>
      <>
        <div className={Styles.tabGroup(theme)}>
          {["summary", "json message"]
          ->Belt.Array.mapWithIndex((index, name) =>
            tab(~name, ~active=index == tabIndex, ~setTab=() => setTabIndex(_ => index))
          )
          ->React.array}
        </div>
        {switch tabIndex {
        | 0 =>
          switch msgsOpt->Belt.Option.getWithDefault(_, [])->Belt.Array.get(0) {
          | Some(msg') =>
            switch msg' {
            | Msg.Input.DelegateMsg({delegatorAddress, validatorAddress, amount}) =>
              switch msg {
              | SubmitMsg.Delegate(_) =>
                <DelegateSummary account validator={validatorAddress} amount />
              | SubmitMsg.Reinvest(_) =>
                <ReinvestSummary account validator={validatorAddress} amount />
              | SubmitMsg.ReinvestAll(_) => <ReinvestAllSummary address={delegatorAddress} />

              | _ => <Text value={"unknown messages"} />
              }

            | SendMsg({fromAddress, toAddress, amount}) =>
              <SendSummary
                fromAddress
                toAddress
                amount={amount
                ->Belt.List.get(0)
                ->Belt.Option.getWithDefault(Coin.newCoin("uband", 0.))}
              />
            | UndelegateMsg({validatorAddress, delegatorAddress, amount}) =>
              switch msg {
              | SubmitMsg.UndelegateAll(_) => <UndelegateAllSummary address={delegatorAddress} />
              | SubmitMsg.Undelegate(validator) =>
                // TODO: withdraw reward summary
                <UndelegateSummary address={delegatorAddress} validator={validatorAddress} amount />
              | _ => <Text value={"unknown messages"} />
              }

            | RedelegateMsg({
                validatorSourceAddress,
                validatorDestinationAddress,
                delegatorAddress,
                amount,
              }) =>
              <RedelegateSummary
                address={delegatorAddress} validatorSourceAddress validatorDestinationAddress amount
              />
            | WithdrawRewardMsg({validatorAddress, delegatorAddress}) =>
              switch msg {
              | SubmitMsg.WithdrawAllReward(_) =>
                <WithdrawAllRewardSummary address={delegatorAddress} />
              | SubmitMsg.WithdrawReward(validator) =>
                <WithdrawRewardSummary address={delegatorAddress} validator />
              | _ => <Text value={"unknown messages"} />
              }

            // TODO: handle properly
            | _ => <Text value={"fallback"} />
            }
          // TODO: handle properly
          | None => <Text value={"no message"} />
          }
        | 1 =>
          <textarea
            className={Styles.jsonDisplay(theme)}
            disabled=true
            defaultValue={rawTx
            ->BandChainJS.Transaction.getSignMessage
            ->JsBuffer.toUTF8
            ->Js.Json.parseExn
            ->TxCreator.stringifyWithSpaces}
          />
        | _ => <Text value="tab index not valid" />
        }}
        <div className={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ())})}>
          <Text size={Body1} value="Chain" />
          {switch trackingSub {
          | Data({chainID}) => <Text size={Body1} color={theme.neutral_900} value={chainID} />
          | _ => <LoadingCensorBar width=100 height=20 />
          }}
        </div>
        <div className={Styles.divider(theme)} />
        <div className=Styles.info>
          <Text value="Transaction Fee" size=Text.Body2 weight=Text.Medium nowrap=true block=true />
          <Text value={`${(txFee /. 1e6)->Belt.Float.toString} BAND`} />
        </div>
        <div className={Styles.buttonContainer}>
          <Button variant=Button.Outline style={Styles.confirmButton} onClick={_ => onBack()}>
            {"Back"->React.string}
          </Button>
          <Button
            style={Styles.confirmButton}
            onClick={_ => {
              let _ = startBroadcast()
            }}>
            {"Confirm"->React.string}
          </Button>
        </div>
      </>
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
