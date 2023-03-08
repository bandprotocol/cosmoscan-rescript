type pos =
  | Msg
  | TxIndex
  | Fee

module Styles = {
  open CssJs

  let container = style(. [display(#flex), alignItems(#center)])
}

@react.component
let make = (~coins, ~pos=Msg, ~size=Text.Body1) => {
  <div className=Styles.container>
    {switch pos {
    | TxIndex =>
      <Text
        value={coins->Coin.getBandAmountFromCoins->Format.fPretty}
        code=true
        block=true
        nowrap=true
        size
      />
    | _ =>
      <Text
        value={coins->Coin.getBandAmountFromCoins->Format.fPretty}
        block=true
        nowrap=true
        code=true
        size
      />
    }}
    <HSpacing size=Spacing.sm />
    {switch pos {
    | Msg => <Text size value="BAND" weight=Text.Regular nowrap=true block=true />
    | TxIndex => <Text size value="BAND" weight=Text.Regular nowrap=true block=true />
    | Fee => React.null
    }}
  </div>
}
