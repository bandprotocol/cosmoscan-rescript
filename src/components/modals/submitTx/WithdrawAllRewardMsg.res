module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(24))])

  let validator = style(. [
    display(#flex),
    flexDirection(#column),
    alignItems(#flexEnd),
    width(#px(330)),
  ])
}

@react.component
let make = (~address, ~setMsgsOpt, ~delegations: array<DelegationSub.Stake.t>) => {
  // let validatorInfoSub = ValidatorSub.get(validator)
  let delegationsSub = DelegationSub.getStakeList(address, ~pageSize=9999, ~page=1, ())

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  React.useEffect0(_ => {
    let msgsOpt = {
      Some(
        delegations->Belt.Array.map(d => Msg.Input.WithdrawRewardMsg({
          delegatorAddress: address,
          validatorAddress: d.operatorAddress,
          amount: (),
          moniker: (),
          identity: (),
        })),
      )
    }
    setMsgsOpt(_ => msgsOpt)

    None
  })

  <>
    <div className=Styles.container>
      <Heading
        value="Withdraw Delegation Rewards"
        size=Heading.H5
        marginBottom=8
        align=Heading.Left
        weight=Heading.Regular
        color={theme.neutral_600}
      />
      <VSpacing size=Spacing.sm />
    </div>
  </>
}
