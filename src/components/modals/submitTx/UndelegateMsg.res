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

  React.useEffect1(_ => {
    let msgsOpt = {
      let amountValue = amount.value->Belt.Option.getWithDefault(0.)
      Some([
        Msg.Input.UndelegateMsg({
          validatorAddress: validator,
          delegatorAddress: address,
          amount: amountValue->Coin.newUBANDFromAmount,
          moniker: (),
          identity: (),
        }),
      ])
    }
    setMsgsOpt(_ => msgsOpt)
    None
  }, [amount])

  <>
    <div className=Styles.container>
      <div className={Styles.tooltips(theme)}>
        <div
          className={CssJs.merge(. [
            CssHelper.flexBox(~cGap=#px(8), ()),
            CssHelper.mb(~size=8, ()),
          ])}>
          <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
          <Text
            size={Body2}
            color={theme.neutral_900}
            weight={Semibold}
            value="Please read before proceeding:"
          />
        </div>
        <Text
          size={Body2}
          color={theme.neutral_900}
          value="1. Undelegated balance are locked for 21 days. After the unbonding period, the balance will automatically be added to your account"
        />
        <Text
          size={Body2}
          color={theme.neutral_900}
          value="2. You can have a maximum of 7 pending unbonding transactions at any one time."
        />
      </div>
      {switch validatorInfoSub {
      | Data(v) =>
        <div>
          <div className={Styles.heading(theme)}>
            <Text value="Undelegate from" size={Body2} />
          </div>
          <Text value={v.moniker} size={Body1} color={theme.neutral_900} weight={Semibold} />
          <Text
            value={v.operatorAddress->Address.toOperatorBech32} size={Body2} ellipsis=true code=true
          />
        </div>

      | _ => <LoadingCensorBar width=300 height=34 />
      }}
    </div>
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
        msg="Undelegate Amount (BAND)"
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
