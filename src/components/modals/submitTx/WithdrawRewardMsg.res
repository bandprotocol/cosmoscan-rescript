module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(24)), width(#px(500))])
  let heading = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_300),
      paddingBottom(#px(4)),
      marginBottom(#px(4)),
    ])

  let validator = style(. [
    display(#flex),
    flexDirection(#column),
    alignItems(#flexEnd),
    width(#px(330)),
  ])
}

@react.component
let make = (~address, ~validator, ~setMsgsOpt) => {
  let validatorInfoSub = ValidatorSub.get(validator)
  let delegationSub = DelegationSub.getStakeByValidator(address, validator)
  let infoSub = React.useContext(GlobalContext.context)

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  React.useEffect1(_ => {
    let msgsOpt = {
      Some([
        Msg.Input.WithdrawRewardMsg({
          delegatorAddress: address,
          validatorAddress: validator,
          amount: (),
          moniker: (),
          identity: (),
        }),
      ])
    }
    setMsgsOpt(_ => msgsOpt)
    None
  }, [validator])

  <>
    <div className=Styles.container>
      {switch validatorInfoSub {
      | Data(validator) =>
        <div className={CssHelper.mb(~size=24, ())}>
          <div className={Styles.heading(theme)}>
            <Text value="Withdraw Delegation Reward From" size={Body2} />
          </div>
          <Text
            value={validator.moniker} size={Body1} color={theme.neutral_900} weight={Semibold}
          />
          <Text
            value={validator.operatorAddress->Address.toOperatorBech32} size={Body2} ellipsis=true
          />
        </div>
      | _ => <LoadingCensorBar width=50 height=20 />
      }}
      {switch delegationSub {
      | Data(delegation) =>
        <div className={CssHelper.mt(~size=24, ())}>
          <Heading
            value="Claim Reward (BAND)"
            size=Heading.H5
            align=Heading.Left
            weight=Heading.Regular
            marginBottom=4
            color={theme.neutral_600}
          />
          <div>
            <NumberCountUp
              value={delegation.reward->Coin.getBandAmountFromCoin}
              size={Text.Xl}
              color={theme.neutral_900}
              weight={Text.Bold}
              decimals=6
            />
            <VSpacing size={#px(4)} />
            {switch infoSub {
            | Data({financial}) =>
              <Text
                size={Body2}
                code=true
                value={`$${(delegation.reward->Coin.getBandAmountFromCoin *. financial.usdPrice)
                    ->Format.fPretty(~digits=2)} USD`}
              />
            | _ => <LoadingCensorBar width=50 height=20 />
            }}
          </div>
        </div>
      | _ => <LoadingCensorBar.CircleSpin height=180 />
      }}
    </div>
  </>
}
