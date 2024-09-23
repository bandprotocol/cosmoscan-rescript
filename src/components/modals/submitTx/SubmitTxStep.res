module Styles = {
  open CssJs
  let container = style(. [
    flexDirection(#column),
    minHeight(#px(300)),
    height(#auto),
    padding(#px(24)),
    borderRadius(#px(5)),
    justifyContent(#flexStart),
  ])

  let disable = isActive => style(. [display(isActive ? #flex : #none)])

  let info = style(. [display(#flex), justifyContent(#spaceBetween), alignItems(#center)])
  let advancedOptions = (show, theme: Theme.t) =>
    style(. [
      marginTop(#px(10)),
      transition(~duration=200, "all"),
      maxHeight(show ? #px(170) : #zero),
      opacity(show ? 1. : 0.),
      overflow(#hidden),
    ])

  let listContainer = style(. [width(#percent(100.)), marginBottom(#px(7))])
  let confirmButton = style(. [flex(#num(1.))])
  let buttonContainer = style(. [
    display(#flex),
    justifyContent(#spaceBetween),
    alignItems(center),
    columnGap(#px(16)),
    marginTop(#px(24)),
  ])
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

@react.component
let make = (~account: AccountContext.t, ~setRawTx, ~isActive, ~msg, ~msgsOpt, ~setMsgsOpt) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let client = React.useContext(ClientContext.context)
  let (show, setShow) = React.useState(_ => false)

  let (memo, setMemo) = React.useState(_ => {
    open EnhanceTxInput
    {text: "", value: Some("")}
  })
  let (gasInput, setGasInput) = React.useState(_ => msg->SubmitMsg.defaultGasLimit)
  let (fee, setFee) = React.useState(_ => msg->SubmitMsg.defaultFee)

  React.useEffect1(_ => {
    switch msgsOpt {
    | Some(msgs) =>
      setGasInput(_ =>
        msg->SubmitMsg.baseGasLimit +
          msgsOpt->Belt.Option.getWithDefault(_, [])->Belt.Array.length *
            msg->SubmitMsg.defaultGasLimit
      )
    | None => ()
    }

    None
  }, [msgsOpt])

  <div className={Css.merge(list{Styles.container, Styles.disable(isActive)})}>
    <Heading value={SubmitMsg.toString(msg)} size=Heading.H4 marginBottom=24 />
    {switch msg {
    | SubmitMsg.Send(receiver, targetChain) =>
      <SendMsg address={account.address} receiver setMsgsOpt targetChain />
    | Delegate(validator) =>
      <DelegateMsg address={account.address} preselectValidator={validator} setMsgsOpt />
    | Undelegate(validator) => <UndelegateMsg address={account.address} validator setMsgsOpt />
    | UndelegateAll(validator) => {
        let delegationsQuery = DelegationQuery.getStakeList(account.address)

        {
          switch delegationsQuery {
          | Data(delegations) =>
            <UndelegateAllMsg address={account.address} delegations setMsgsOpt />
          | _ => React.null
          }
        }
      }

    | Redelegate(validator) => <RedelegateMsg address={account.address} validator setMsgsOpt />
    | WithdrawReward(validator) =>
      <WithdrawRewardMsg validator setMsgsOpt address={account.address} />
    | WithdrawAllReward(validator) => {
        let delegationsQuery = DelegationQuery.getStakeList(account.address)

        {
          switch delegationsQuery {
          | Data(delegations) =>
            <WithdrawAllRewardMsg address={account.address} delegations setMsgsOpt />
          | _ => React.null
          }
        }
      }

    | Reinvest(validator) => <ReinvestMsg address={account.address} validator setMsgsOpt />
    | Vote(proposalID, proposalName) =>
      <VoteMsg address={account.address} proposalID proposalName setMsgsOpt />
    }}
    <div className={CssHelper.flexBox()}>
      <SwitchV2 checked=show onClick={_ => setShow(prev => !prev)} />
      <Text block=true value="Advanced" weight=Text.Semibold color={theme.neutral_900} />
    </div>
    <div className={Styles.advancedOptions(show, theme)}>
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
      <ValueInput
        value={gasInput->Belt.Int.toString}
        setValue=setGasInput
        title="Gas Limit"
        inputType="number"
      />
    </div>
    <SeperatedLine />
    <div className=Styles.info>
      <Text value="Transaction Fee" size=Text.Body2 weight=Text.Medium nowrap=true block=true />
      <Text value="0.005 BAND" />
    </div>
    <div className={Styles.buttonContainer} id="nextButtonContainer">
      <Button
        variant=Button.Outline
        style={Styles.confirmButton}
        onClick={_ => ModalContext.CloseModal->dispatchModal}>
        {"Cancel"->React.string}
      </Button>
      <Button
        style=Styles.confirmButton
        disabled={gasInput <= 0}
        onClick={_ => {
          let _ = TxCreator.createRawTx(
            client,
            account.address,
            msgsOpt->Belt.Option.getWithDefault(_, []),
            account.chainID,
            gasInput > msg->SubmitMsg.defaultGasLimit
              ? (gasInput->Belt.Int.toFloat *. 0.003)->Js.Math.round->Belt.Float.toInt
              : msg->SubmitMsg.defaultFee,
            gasInput,
            memo.value->Belt.Option.getWithDefault(""),
          )->Promise.then(rawTx => {
            setRawTx(_ => Some(rawTx))
            Promise.resolve()
          })
        }}>
        {"Next"->React.string}
      </Button>
    </div>
  </div>
}
