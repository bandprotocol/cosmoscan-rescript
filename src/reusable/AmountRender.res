type pos =
  | Msg
  | TxIndex
  | Fee

module Styles = {
  open CssJs

  let container = style(. [display(#flex), alignItems(#center)])
}

@react.component
let make = (~coins, ~pos=Msg, ~size=Text.Body1, ~color=?) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let textColor = color->Belt.Option.getWithDefault(theme.neutral_600)

  <div className=Styles.container>
    {switch pos {
    | TxIndex =>
      <Text
        value={coins->Coin.getBandAmountFromCoins->Format.fPretty}
        code=true
        block=true
        nowrap=true
        size
        color=textColor
      />
    | _ =>
      <Text
        value={coins->Coin.getBandAmountFromCoins->Format.fPretty}
        block=true
        nowrap=true
        code=true
        size
        color=textColor
      />
    }}
    <HSpacing size=Spacing.sm />
    {switch pos {
    | Msg => <Text size value="BAND" weight=Text.Regular color=textColor nowrap=true block=true />
    | TxIndex =>
      <Text size value="BAND" weight=Text.Regular color=textColor nowrap=true block=true />
    | Fee => React.null
    }}
  </div>
}
