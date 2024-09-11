module Styles = {
  open CssJs

  let summaryContainer = style(. [padding2(~v=#px(24), ~h=#px(0))])
  let borderBottomLine = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_300)])
  let currentDelegateHeader = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_200), margin2(~v=#px(4), ~h=#px(0))])

  let delegateAmountContainer = (theme: Theme.t) =>
    style(. [borderRadius(#px(8)), background(theme.neutral_100), padding2(~v=#px(12), ~h=#px(16))])

  let halfWidth = style(. [width(#percent(50.))])
  let fullWidth = style(. [width(#percent(100.)), margin2(~v=#px(24), ~h=#zero)])
}

@react.component
let make = (~account: AccountContext.t, ~validator: Address.t, ~amount) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let accountSub = AccountSub.get(account.address)
  let validatorsSub = ValidatorSub.get(validator)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()
  let aprSub = AprSub.use()
  let valBondSub = Sub.all2(validatorsSub, bondedTokenCountSub)
  let stakeSub = DelegationSub.getStakeByValidator(account.address, validator)
  let infoSub = React.useContext(GlobalContext.context)

  <div className={Styles.summaryContainer}>
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
        value={account.address->Address.toBech32}
        size={Body1}
        weight=Text.Regular
        color={theme.neutral_900}
      />
    </div>
    <div className={CssHelper.mb(~size=24, ())}>
      <Heading
        value="Delegate to"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        marginBottom=4
        color={theme.neutral_900}
        style={Styles.borderBottomLine(theme)}
      />
      {switch validatorsSub {
      | Data({moniker, operatorAddress}) =>
        <>
          <Text value={moniker} size={Body1} weight=Text.Semibold color={theme.neutral_900} />
          <Text
            value={operatorAddress->Address.toBech32}
            size={Body1}
            weight=Text.Regular
            color={theme.neutral_900}
          />
        </>
      | _ => <LoadingCensorBar width=150 height=18 />
      }}
    </div>
    <ValidatorDelegationDetail address={account.address} validator bondedTokenCountSub />
    <div className={CssHelper.mb(~size=24, ())}>
      <Heading
        value="Delegate Amount (BAND)"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        marginBottom=4
        color={theme.neutral_600}
      />
      <div className={Styles.delegateAmountContainer(theme)}>
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
    <div className={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ())})}>
      <Text size={Body1} value="Total Delegation (BAND)" />
      {switch stakeSub {
      | Data(stake) =>
        <Text
          size={Body1}
          color={theme.neutral_900}
          code=true
          value={(stake.amount->Coin.getBandAmountFromCoin +. amount->Coin.getBandAmountFromCoin)
            ->Format.fPretty(~digits=6)}
        />
      | _ => <LoadingCensorBar width=150 height=18 />
      }}
    </div>
  </div>
}
