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
let make = (~address, ~validator, ~bondedTokenCountSub: Sub.variant<Coin.t>) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let validatorsSub = ValidatorSub.get(validator)
  let valBondSub = Sub.all2(validatorsSub, bondedTokenCountSub)
  let aprSub = AprSub.use()

  <div className={CssHelper.flexBox()}>
    {switch valBondSub {
    | Data(({votingPower, commission}, bondedTokenCount)) =>
      <>
        <div className={Styles.halfWidth}>
          <Heading
            value="Total BAND Bonded"
            size=Heading.H5
            align=Heading.Left
            weight=Heading.Regular
            color={theme.neutral_600}
          />
          <Text
            size={Body1}
            color={theme.neutral_900}
            value={`${(votingPower /. 1e6)->Format.fPretty(~digits=0)} (${(votingPower /.
              bondedTokenCount.amount *. 100.)->Format.fPercent})`}
            code=true
          />
        </div>
        <div className={Styles.halfWidth}>
          <Heading
            value="Est. APR"
            size=Heading.H5
            align=Heading.Left
            weight=Heading.Regular
            color={theme.neutral_600}
          />
          {switch aprSub {
          | Data(apr) =>
            <Text
              size={Xl}
              color={theme.neutral_900}
              value={(apr *. (100. -. commission) /. 100.)->Format.fPercent}
              code=true
            />
          | _ => <LoadingCensorBar width=150 height=18 />
          }}
        </div>
      </>
    | _ => <LoadingCensorBar width=150 height=18 />
    }}
    <div className={Styles.fullWidth}>
      <Heading
        value="Current Delegated (BAND)"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        color={theme.neutral_600}
      />
      <div className={Styles.currentDelegateHeader(theme)} />
      {
        let stakeSub = DelegationSub.getStakeByValidator(address, validator)
        switch stakeSub {
        | Data({amount}) =>
          <Text
            size={Body1}
            color={theme.neutral_900}
            value={amount->Coin.getBandAmountFromCoin->Format.fPretty(~digits=6)}
            code=true
          />
        | _ => <LoadingCensorBar width=150 height=18 />
        }
      }
    </div>
  </div>
}

module NoData = {
  @react.component
  let make = () => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className={CssHelper.flexBox()}>
      <div className={Styles.halfWidth}>
        <Heading
          value="Total BAND Bonded"
          size=Heading.H5
          align=Heading.Left
          weight=Heading.Regular
          color={theme.neutral_600}
        />
        <Text size={Body1} color={theme.neutral_900} value={"-"} code=true />
      </div>
      <div className={Styles.halfWidth}>
        <Heading
          value="Est. APR"
          size=Heading.H5
          align=Heading.Left
          weight=Heading.Regular
          color={theme.neutral_600}
        />
        <Text size={Body1} color={theme.neutral_900} value={"-"} code=true />
      </div>
      <div className={Styles.fullWidth}>
        <Heading
          value="Current Delegated (BAND)"
          size=Heading.H5
          align=Heading.Left
          weight=Heading.Regular
          color={theme.neutral_600}
        />
        <div className={Styles.currentDelegateHeader(theme)} />
        <Text size={Body1} color={theme.neutral_900} value={"-"} code=true />
      </div>
    </div>
  }
}
