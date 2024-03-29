type t = {
  denom: string,
  amount: float,
}

let decodeCoin = {
  open JsonUtils.Decode
  object(fields => {
    denom: fields.required(. "denom", string),
    amount: fields.required(. "amount", floatstr),
  })
}

let newUBANDFromAmount = amount => {denom: "uband", amount}

let newCoin = (denom, amount) => {denom, amount}

let getBandAmountFromCoin = coin => coin.amount /. 1e6

let getBandAmountFromCoins = coins =>
  coins
  ->Belt.List.keep(coin => coin.denom == "uband")
  ->Belt.List.get(0)
  ->Belt.Option.mapWithDefault(0., getBandAmountFromCoin)

let getUBandAmountFromCoin = coin => coin.amount

let getUBandAmountFromCoins = coins =>
  coins
  ->Belt.List.keep(coin => coin.denom == "uband")
  ->Belt.List.get(0)
  ->Belt.Option.mapWithDefault(0., getUBandAmountFromCoin)

let toBandChainJsCoin = (coin: t) => {
  let bandCoin = BandChainJS.Coin.create()
  bandCoin->BandChainJS.Coin.setDenom(coin.denom)
  bandCoin->BandChainJS.Coin.setAmount(coin.amount->Js.Math.floor_float->Js.Float.toString)

  bandCoin
}
let toBandChainJsCoins = (coins: list<t>) => {
  coins->Belt.List.map(toBandChainJsCoin)->Belt.List.toArray
}
