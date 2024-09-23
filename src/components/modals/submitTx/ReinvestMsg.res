module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(24)), width(#px(500))])

  let info = style(. [display(#flex), justifyContent(#spaceBetween)])

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
let make = (~address, ~validator: Address.t, ~setMsgsOpt) => {
  let (amount, setAmount) = React.useState(_ => EnhanceTxInputV2.empty)
  let (validatorOpt, setValidatorOpt) = React.useState(_ => Some(validator))

  let validatorsSub = ValidatorSub.getList(~filter=Active, ())
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()
  let delegationSub = DelegationSub.getStakeByValidator(address, validator)

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  React.useEffect2(_ => {
    switch validatorOpt {
    | Some(val) =>
      let msgsOpt = {
        let amountValue = amount.value->Belt.Option.getWithDefault(0.)

        Some([
          Msg.Input.DelegateMsg({
            validatorAddress: val,
            delegatorAddress: address,
            amount: amountValue->Coin.newUBANDFromAmount,
            moniker: (),
            identity: (),
          }),
        ])
      }
      setMsgsOpt(_ => msgsOpt)
    | None => ()
    }

    None
  }, (amount, validatorOpt))

  <>
    <div className=Styles.container>
      <Heading
        value="Reinvest to"
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
            <ValidatorSelection validatorOpt filteredValidators setValidatorOpt />
          }
        </div>
      | Error(err) => <Text value={err.message} />
      | NoData => <Text value={"No Data"} />
      | _ => <LoadingCensorBar width=300 height=34 />
      }}
    </div>
    {switch validatorOpt {
    | Some(validator) => <ValidatorDelegationDetail address validator bondedTokenCountSub />
    | None => <ValidatorDelegationDetail.NoData />
    }}
    {switch delegationSub {
    | Data({reward}) =>
      let maxValInUband = reward->Coin.getUBandAmountFromCoin->Js.Math.floor_float

      <EnhanceTxInputV2
        id="reinvestAmountInput"
        width=300
        inputData=amount
        setInputData=setAmount
        parse={Parse.getBandAmount(maxValInUband)}
        maxValue={(maxValInUband /. 1e6)->Belt.Float.toString}
        msg="Reinvest Amount (BAND)"
        placeholder="0.000000"
        inputType="number"
        code=true
        autoFocus=true
        maxValueText="Current Reward"
      />
    | _ => <EnhanceTxInputV2.Loading msg="Amount" code=true useMax=true placeholder="0.000000" />
    }}
  </>
}
