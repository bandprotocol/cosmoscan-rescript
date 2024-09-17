module Styles = {
  open CssJs

  let container = style(. [padding2(~v=#px(24), ~h=#px(0))])

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
  let summaryAmountContainer = (theme: Theme.t) =>
    style(. [borderRadius(#px(8)), background(theme.neutral_100), padding2(~v=#px(12), ~h=#px(16))])
}

@react.component
let make = (~address, ~validatorSourceAddress, ~validatorDestinationAddress, ~amount) => {
  let delegationSub = DelegationSub.getStakeByValidator(address, validatorDestinationAddress)
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
      <ValidatorDetail heading="Redelegate from" validator={validatorSourceAddress} />
      <ValidatorDelegationDetail
        address validator={validatorSourceAddress} bondedTokenCountSub isShowCurrentDelegated=false
      />
    </div>
    <div className={CssHelper.mb(~size=24, ())}>
      <ValidatorDetail heading="Redelegate to" validator={validatorDestinationAddress} />
      <ValidatorDelegationDetail
        address
        validator={validatorDestinationAddress}
        bondedTokenCountSub
        isShowCurrentDelegated=false
      />
    </div>
    {switch delegationSub {
    | Data(delegation) =>
      <SummaryAmountBox heading="Redelegate Amount (BAND)" amount maxValue={delegation.amount} />
    | _ => <LoadingCensorBar width=300 height=60 />
    }}
  </div>
}
