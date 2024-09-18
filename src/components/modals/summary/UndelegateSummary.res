module Styles = {
  open CssJs

  let container = style(. [padding2(~v=#px(24), ~h=#px(0))])

  let heading = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_300),
      paddingBottom(#px(4)),
      marginBottom(#px(4)),
    ])
}

@react.component
let make = (~address, ~validator, ~amount) => {
  let delegationSub = DelegationSub.getStakeByValidator(address, validator)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.container>
    <div className={CssHelper.mb(~size=24, ())}>
      <Heading
        value="Band Address"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        marginBottom=4
        color={theme.neutral_900}
      />
      <Text
        value={address->Address.toBech32}
        size={Body1}
        weight=Text.Regular
        color={theme.neutral_900}
        code=true
      />
    </div>
    <div className={CssHelper.mb(~size=24, ())}>
      <ValidatorDetail heading="Undelegate from" validator={validator} />
    </div>
    {switch delegationSub {
    | Data(delegation) =>
      <SummaryAmountBox heading="Undelegate Amount (BAND)" amount maxValue={delegation.amount} />
    | _ => <LoadingCensorBar width=300 height=60 />
    }}
  </div>
}
