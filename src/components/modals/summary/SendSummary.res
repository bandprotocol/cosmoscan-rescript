module Styles = {
  open CssJs

  let summaryContainer = style(. [padding2(~v=#px(24), ~h=#px(0))])
  let borderBottomLine = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_300)])
  let currentDelegateHeader = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_200), margin2(~v=#px(4), ~h=#px(0))])

  let amountContainer = (theme: Theme.t) =>
    style(. [borderRadius(#px(8)), background(theme.neutral_100), padding2(~v=#px(12), ~h=#px(16))])

  let halfWidth = style(. [width(#percent(50.))])
  let fullWidth = style(. [width(#percent(100.)), margin2(~v=#px(24), ~h=#zero)])
}

@react.component
let make = (~fromAddress, ~toAddress, ~amount) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let infoSub = React.useContext(GlobalContext.context)

  <div className={Styles.summaryContainer}>
    <div className={CssHelper.mb(~size=24, ())}>
      <Heading
        value="from"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        marginBottom=4
        color={theme.neutral_900}
      />
      <Text
        value={fromAddress->Address.toBech32}
        size={Body1}
        weight=Text.Regular
        color={theme.neutral_900}
        code=true
      />
    </div>
    <div className={CssHelper.mb(~size=24, ())}>
      <Heading
        value="to"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        marginBottom=4
        color={theme.neutral_900}
      />
      <Text
        value={toAddress->Address.toBech32}
        size={Body1}
        weight=Text.Regular
        color={theme.neutral_900}
        code=true
      />
    </div>
    <div>
      <Heading
        value="Amount (BAND)"
        size=Heading.H5
        align=Heading.Left
        weight=Heading.Regular
        marginBottom=4
        color={theme.neutral_600}
      />
      <div className={Styles.amountContainer(theme)}>
        <Text
          size={Xl}
          weight={Bold}
          color={theme.neutral_900}
          code=true
          value={amount->Coin.getBandAmountFromCoins->Format.fPretty}
        />
        <VSpacing size={#px(4)} />
        {switch infoSub {
        | Data({financial}) =>
          <Text
            size={Body2}
            code=true
            value={`$${(amount->Coin.getBandAmountFromCoins *. financial.usdPrice)
                ->Format.fPretty(~digits=2)} USD`}
          />
        | _ => <LoadingCensorBar width=50 height=20 />
        }}
      </div>
    </div>
  </div>
}
