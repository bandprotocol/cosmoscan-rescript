module Styles = {
  open CssJs
  let container = style(. [
    flexDirection(#column),
    width(#px(468)),
    minHeight(#px(300)),
    height(#auto),
    padding(#px(32)),
    borderRadius(#px(5)),
    justifyContent(#flexStart),
  ])

  let disable = isActive => style(. [display(isActive ? #flex : #none)])

  let nextBtn = style(. [width(#percent(100.)), marginTop(#px(24))])

  let info = style(. [display(#flex), justifyContent(#spaceBetween), alignItems(#center)])
  let toggle = style(. [cursor(#pointer), zIndex(100)])
  let advancedOptions = (show, theme: Theme.t) =>
    style(. [
      marginTop(#px(10)),
      transition(~duration=200, "all"),
      maxHeight(show ? #px(100) : #zero),
      opacity(show ? 1. : 0.),
      overflow(#hidden),
    ])

  let listContainer = style(. [width(#percent(100.)), marginBottom(#px(7))])
}

module ValueInput = {
  @react.component
  let make = (~value, ~setValue, ~title, ~info=?, ~inputType="text") => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div className=Styles.listContainer>
      <div className={CssHelper.flexBox()}>
        <Text value=title weight=Text.Semibold transform=Text.Capitalize />
        <HSpacing size=Spacing.xs />
        <Text value={info->Belt.Option.getWithDefault("")} weight=Text.Semibold />
      </div>
      <VSpacing size=Spacing.sm />
      <input
        className={EnhanceTxInput.Styles.input(theme)}
        type_=inputType
        onChange={event => {
          let newVal = ReactEvent.Form.target(event)["value"]
          setValue(_ => newVal)
        }}
        value
      />
    </div>
  }
}

module SubmitTxStep = {
  @react.component
  let make = (~account: AccountContext.t, ~setRawTx, ~isActive, ~msg) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let client = React.useContext(ClientContext.context)
    let (show, setShow) = React.useState(_ => false)
    let (msgsOpt, setMsgsOpt) = React.useState(_ => None)

    let gasLimit = SubmitMsg.gasLimit(msg)

    let fee = 5000.
    let (memo, setMemo) = React.useState(_ => {
      open EnhanceTxInput
      {text: "", value: Some("")}
    })
    let (gasInput, setGasInput) = React.useState(_ => gasLimit->Belt.Int.toString)

    <div className={Css.merge(list{Styles.container, Styles.disable(isActive)})}>
      <Heading value={SubmitMsg.toString(msg)} size=Heading.H4 marginBottom=24 />
      {switch msg {
      | SubmitMsg.Send(receiver, targetChain) =>
        <SendMsg address={account.address} receiver setMsgsOpt targetChain />
      | Delegate(validator) => <DelegateMsg address={account.address} validator setMsgsOpt />
      | Undelegate(validator) => <UndelegateMsg address={account.address} validator setMsgsOpt />
      | Redelegate(validator) => <RedelegateMsg address={account.address} validator setMsgsOpt />
      | WithdrawReward(validator) =>
        <WithdrawRewardMsg validator setMsgsOpt address={account.address} />
      | Reinvest(validator, amount) => <ReinvestMsg validator setMsgsOpt amount />
      // | Vote(proposalID, proposalName) => <VoteMsg proposalID proposalName setMsgsOpt />
      | _ => React.null
      }}
      <EnhanceTxInput
        width=300
        inputData=memo
        setInputData=setMemo
        parse={newVal => {
          newVal->Js.String.length <= 32 ? Result.Ok(newVal) : Err("Exceed limit length")
        }}
        msg="Memo (Optional)"
        placeholder="Memo"
        id="memoInput"
      />
      <div
        onClick={_ => setShow(prev => !prev)}
        className={Css.merge(list{CssHelper.flexBox(~justify=#center, ()), Styles.toggle})}>
        <Text
          block=true
          value={show ? "Hide Advanced Options" : "Show Advanced Options"}
          weight=Text.Semibold
          color={theme.neutral_900}
        />
        <HSpacing size=Spacing.xs />
        <Icon name={show ? "fas fa-caret-up" : "fas fa-caret-down"} color={theme.neutral_600} />
      </div>
      <div className={Styles.advancedOptions(show, theme)}>
        <ValueInput
          value=gasInput setValue=setGasInput title="Gas Limit" info="(optional)" inputType="number"
        />
        {switch Belt.Int.fromString(gasInput) {
        | Some(gasInputAmout) =>
          gasInputAmout < gasLimit
            ? {
                <div>
                  <Text
                    value="Gas limit must be at least 300,000"
                    size=Text.Caption
                    color=theme.error_600
                  />
                </div>
              }
            : {
                React.null
              }

        | _ => React.null
        }}
      </div>
      <SeperatedLine />
      <div className=Styles.info>
        <Text value="Transaction Fee" size=Text.Body2 weight=Text.Medium nowrap=true block=true />
        <Text value="0.005 BAND" />
      </div>
      <div id="nextButtonContainer">
        <Button
          style=Styles.nextBtn
          disabled={switch Belt.Int.fromString(gasInput) {
          | Some(gasOpt) => gasOpt < gasLimit || msgsOpt->Belt.Option.isNone
          | None => msgsOpt->Belt.Option.isNone
          }}
          onClick={_ => {
            let rawTxOpt = {
              let memo' = {
                switch memo.value {
                | Some(x) => x
                | None => ""
                }
              }

              let msgs = msgsOpt->Belt.Option.getWithDefault(_, [])

              Some(
                TxCreator2.createRawTx(
                  ~sender=account.address,
                  ~msgs,
                  ~chainID=account.chainID,
                  ~feeAmount=fee->Js.Float.toString,
                  ~gas={
                    switch Belt.Int.fromString(gasInput) {
                    | Some(gasOpt) => gasOpt
                    | None => gasLimit
                    }
                  },
                  ~memo=memo',
                  ~client,
                  (),
                ),
              )
            }
            let _ = async () =>
              switch rawTxOpt {
              | Some(rawTxPromise) =>
                let rawTx = await rawTxPromise
                setRawTx(_ => Some(rawTx))
              | None =>
                open Webapi.Dom
                window->Window.alert("invalid messages")
              }
          }}>
          {"Next"->React.string}
        </Button>
      </div>
    </div>
  }
}

module CreateTxFlow = {
  @react.component
  let make = (~account, ~msg) => {
    let (rawTx, setRawTx) = React.useState(_ => None)

    <>
      <SubmitTxStep account setRawTx isActive={rawTx->Belt.Option.isNone} msg />
      {switch rawTx {
      | None => React.null
      | Some(rawTx') => <PreviewJsonStep rawTx=rawTx' onBack={_ => setRawTx(_ => None)} account />
      }}
    </>
  }
}

@react.component
let make = (~msg) => {
  let (account, _) = React.useContext(AccountContext.context)

  switch account {
  | Some(account') => <CreateTxFlow account=account' msg />
  | None =>
    <div className=Styles.container>
      <Text value="Please sign in" size=Text.Body1 />
    </div>
  }
}
