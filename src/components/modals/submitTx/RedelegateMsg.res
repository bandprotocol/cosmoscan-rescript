module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(24)), width(#px(500))])

  let heading = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_300),
      paddingBottom(#px(4)),
      marginBottom(#px(4)),
    ])

  let tooltips = (theme: Theme.t) =>
    style(. [
      display(#flex),
      columnGap(#px(8)),
      borderRadius(#px(4)),
      backgroundColor(theme.neutral_100),
      padding2(~v=#px(10), ~h=#px(16)),
      marginBottom(#px(24)),
    ])
}

@react.component
let make = (~address, ~validator, ~setMsgsOpt) => {
  let validatorInfoSub = ValidatorSub.get(validator)
  let validatorsSub = ValidatorSub.getList(~filter=Active, ())
  let delegationSub = DelegationSub.getStakeByValidator(address, validator)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  let (dstValidatorOpt, setDstValidatorOpt) = React.useState(_ => None)
  let (amount, setAmount) = React.useState(_ => EnhanceTxInputV2.empty)

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  React.useEffect2(_ => {
    let msgsOpt = {
      let dstValidator = dstValidatorOpt
      let amountValue = amount.value->Belt.Option.getWithDefault(0.)

      switch dstValidatorOpt {
      | Some(dstValidator) =>
        Some([
          Msg.Input.RedelegateMsg({
            validatorSourceAddress: validator,
            validatorDestinationAddress: dstValidator,
            delegatorAddress: address,
            amount: amountValue->Coin.newUBANDFromAmount,
            monikerSource: (),
            monikerDestination: (),
            identitySource: (),
            identityDestination: (),
          }),
        ])
      | None => None
      }
    }
    setMsgsOpt(_ => msgsOpt)
    None
  }, (dstValidatorOpt, amount))

  <>
    <div className=Styles.container>
      <div className={Styles.tooltips(theme)}>
        <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
        <Text
          size={Body2}
          value="You can only redelegate a maximum of 7 times to/from the same validator pairs during any 21 day period."
        />
      </div>
      {switch validatorInfoSub {
      | Data(v) =>
        <div className={CssHelper.mb(~size=24, ())}>
          <div className={CssHelper.mb(~size=24, ())}>
            <div className={Styles.heading(theme)}>
              <Text value="Redelegate from" size={Body2} />
            </div>
            <Text value={v.moniker} size={Body1} color={theme.neutral_900} weight={Semibold} />
            <Text
              value={v.operatorAddress->Address.toOperatorBech32}
              size={Body2}
              ellipsis=true
              code=true
            />
          </div>
          <ValidatorDelegationDetail
            address validator bondedTokenCountSub isShowCurrentDelegated=false
          />
        </div>
      | _ => <LoadingCensorBar width=300 height=34 />
      }}
      <Heading
        value="Redelegate to"
        size=Heading.H5
        marginBottom=8
        align=Heading.Left
        weight=Heading.Regular
        color={theme.neutral_900}
      />
      {switch validatorsSub {
      | Data(validators) =>
        <div>
          {
            let filteredValidators =
              validators->Belt_Array.keep(validator => validator.commission !== 100.)
            <ValidatorSelection
              validatorOpt={dstValidatorOpt} filteredValidators setValidatorOpt={setDstValidatorOpt}
            />
          }
        </div>
      | Error(err) => <Text value={err.message} />
      | NoData => <Text value={"No Data"} />
      | _ => <LoadingCensorBar width=300 height=34 />
      }}
    </div>
    {switch dstValidatorOpt {
    | Some(validator) => <ValidatorDelegationDetail address validator bondedTokenCountSub />
    | None => <ValidatorDelegationDetail.NoData />
    }}
    {switch delegationSub {
    | Data(delegation) =>
      //  TODO: hard-coded tx fee
      let maxValInUband = delegation.amount->Coin.getUBandAmountFromCoin
      <EnhanceTxInputV2
        width=300
        inputData=amount
        setInputData=setAmount
        parse={Parse.getBandAmount(maxValInUband)}
        maxValue={(maxValInUband /. 1e6)->Belt.Float.toString}
        msg="Delegate Amount (BAND)"
        placeholder="0.000000"
        inputType="number"
        code=true
        autoFocus=true
        id="redelegateAmountInput"
      />
    | _ => <EnhanceTxInputV2.Loading msg="Amount" code=true useMax=true placeholder="0.000000" />
    }}
  </>
}
