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
  let validatorSourceInfoSub = ValidatorSub.get(validatorSourceAddress)
  let validatorDestinationInfoSub = ValidatorSub.get(validatorDestinationAddress)
  let delegationSub = DelegationSub.getStakeByValidator(address, validatorSourceAddress)
  let accountSub = AccountSub.get(address)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()
  let infoSub = React.useContext(GlobalContext.context)

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
      {switch validatorSourceInfoSub {
      | Data(v) =>
        <>
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
            address
            validator={validatorSourceAddress}
            bondedTokenCountSub
            isShowCurrentDelegated=false
          />
        </>
      | _ => <LoadingCensorBar width=300 height=34 />
      }}
    </div>
    <div className={CssHelper.mb(~size=24, ())}>
      {switch validatorDestinationInfoSub {
      | Data(v) =>
        <>
          <div className={CssHelper.mb(~size=24, ())}>
            <div className={Styles.heading(theme)}>
              <Text value="Redelegate to" size={Body2} />
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
            address
            validator={validatorSourceAddress}
            bondedTokenCountSub
            isShowCurrentDelegated=false
          />
        </>
      | _ => <LoadingCensorBar width=300 height=34 />
      }}
    </div>
    <div>
      <Heading
        value="Redelegate Amount (BAND)"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        marginBottom=4
        color={theme.neutral_600}
      />
      <div className={Styles.summaryAmountContainer(theme)}>
        <Text
          size={Xl}
          weight={Bold}
          color={theme.neutral_900}
          code=true
          value={amount->Coin.getBandAmountFromCoin->Format.fPretty}
        />
        <VSpacing size={#px(4)} />
        {switch infoSub {
        | Data({financial}) =>
          <Text
            size={Body2}
            code=true
            value={`$${(amount->Coin.getBandAmountFromCoin *. financial.usdPrice)
                ->Format.fPretty(~digits=2)} USD`}
          />
        | _ => <LoadingCensorBar width=50 height=20 />
        }}
      </div>
    </div>
  </div>
}
