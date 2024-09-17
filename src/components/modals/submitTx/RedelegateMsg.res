module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(24))])

  let warning = (theme: Theme.t) =>
    style(. [
      display(#flex),
      flexDirection(#column),
      padding2(~v=#px(16), ~h=#px(24)),
      backgroundColor(theme.neutral_100),
      borderRadius(#px(4)),
      marginBottom(#px(24)),
    ])

  let heading = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_300),
      paddingBottom(#px(4)),
      marginBottom(#px(4)),
    ])

  let select = style(. [width(#px(1000)), height(#px(1))])
  let tooltips = (theme: Theme.t) =>
    style(. [
      display(#flex),
      columnGap(#px(8)),
      borderRadius(#px(4)),
      backgroundColor(theme.neutral_100),
      padding2(~v=#px(10), ~h=#px(16)),
      marginBottom(#px(24)),
    ])

  let halfWidth = style(. [width(#percent(50.))])
  let fullWidth = style(. [width(#percent(100.)), margin2(~v=#px(24), ~h=#zero)])
}

@react.component
let make = (~address, ~validator, ~setMsgsOpt) => {
  let validatorInfoSub = ValidatorSub.get(validator)
  let validatorsSub = ValidatorSub.getList(~filter=Active, ())
  let delegationSub = DelegationSub.getStakeByValidator(address, validator)
  let accountSub = AccountSub.get(address)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  let allSub = Sub.all2(accountSub, validatorsSub)

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
          value="Delegate your BAND to start earning staking rewards. Undelegated balances are locked for 21 days."
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
            <Text value={v.operatorAddress->Address.toOperatorBech32} size={Body2} ellipsis=true />
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
    {switch allSub {
    | Data(({balance}, _)) =>
      //  TODO: hard-coded tx fee
      let maxValInUband = balance->Coin.getUBandAmountFromCoins -. 5000.
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
        id="delegateAmountInput"
        maxWarningMsg=true
      />
    | _ => <EnhanceTxInputV2.Loading msg="Amount" code=true useMax=true placeholder="0.000000" />
    }}
  </>
}
