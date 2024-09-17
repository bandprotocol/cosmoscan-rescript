module Styles = {
  open CssJs

  let container = (theme: Theme.t) =>
    style(. [borderRadius(#px(8)), background(theme.neutral_100), padding2(~v=#px(12), ~h=#px(16))])
}

@react.component
let make = (~heading, ~amount, ~maxValue=?) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let infoSub = React.useContext(GlobalContext.context)

  <div>
    <Heading
      value={heading}
      size=Heading.H5
      align=Heading.Left
      weight=Heading.Regular
      marginBottom=4
      color={theme.neutral_600}
    />
    <div className={Styles.container(theme)}>
      <div className={CssHelper.flexBox()}>
        <Text
          size={Xl}
          weight={Bold}
          color={theme.neutral_900}
          code=true
          value={amount->Coin.getBandAmountFromCoin->Format.fPretty(~digits=6)}
        />
        {switch maxValue {
        | Some(maxVal) =>
          <Text
            size={Body1}
            weight={Bold}
            color={theme.neutral_600}
            code=true
            value={`/ ${maxVal->Coin.getBandAmountFromCoin->Format.fPretty(~digits=6)}`}
          />
        | None => React.null
        }}
      </div>
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
}
