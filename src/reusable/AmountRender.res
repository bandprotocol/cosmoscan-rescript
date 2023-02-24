type pos =
  | Msg
  | TxIndex
  | Fee

module Styles = {
  open CssJs

  let container = style(. [display(#flex), alignItems(#center)])
}

@react.component
let make = (~coins, ~pos=Msg) => {
  <div className=Styles.container>
    {switch pos {
    | TxIndex =>
      <Text
        value={coins->Coin.getBandAmountFromCoins->Format.fPretty}
        code=true
        block=true
        nowrap=true
        size=Text.Body1
      />
    | _ =>
      <Text
        value={coins->Coin.getBandAmountFromCoins->Format.fPretty}
        block=true
        nowrap=true
        code=true
        size=Text.Body1
      />
    }}
    <HSpacing size=Spacing.sm />
    {switch pos {
    | Msg => <Text size=Text.Body1 value="BAND" weight=Text.Regular nowrap=true block=true />
    | TxIndex => <Text size=Text.Body1 value="BAND" weight=Text.Regular nowrap=true block=true />
    | Fee => React.null
    }}
  </div>
}
