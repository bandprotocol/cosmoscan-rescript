module Styles = {
  open CssJs

  let summaryContainer = style(. [padding2(~v=#px(24), ~h=#px(0))])
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
        code=true
      />
    </div>
    <div className={CssHelper.mb(~size=24, ())}>
      <ValidatorDetail heading="Reinvest to" validator />
    </div>
    <ValidatorDelegationDetail address={account.address} validator bondedTokenCountSub />
    <SummaryAmountBox heading="Reinvest Amount (BAND)" amount />
    <div
      className={Css.merge(list{
        CssHelper.flexBox(~justify=#spaceBetween, ()),
        CssHelper.mt(~size=24, ()),
      })}>
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
