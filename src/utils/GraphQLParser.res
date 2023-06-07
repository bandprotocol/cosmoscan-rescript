let int64 = json =>
  json->Js.Json.decodeString->Belt.Option.flatMap(Belt.Int.fromString)->Belt.Option.getExn
let string = json => json->Js.Json.decodeString->Belt.Option.getExn
let jsonToStringExn = jsonOpt =>
  jsonOpt->Belt.Option.getExn->Js.Json.decodeString->Belt.Option.getExn
let stringExn = (stringOpt: option<string>) => stringOpt->Belt.Option.getExn
let buffer = json =>
  json->Js.Json.decodeString->Belt.Option.getExn->Js.String2.substr(~from=2)->JsBuffer.fromHex

let timeS = json =>
  json
  ->Js.Json.decodeNumber
  ->Belt.Option.getExn
  ->Belt.Float.toInt
  ->MomentRe.momentWithUnix
  ->MomentRe.Moment.defaultUtc

let timeMS = json =>
  json
  ->Js.Json.decodeNumber
  ->Belt.Option.getExn
  ->MomentRe.momentWithTimestampMS
  ->MomentRe.Moment.defaultUtc
let fromUnixSecond = timeInt => timeInt->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc

let fromUnixSecondOpt = timeOpt =>
  timeOpt->Belt.Option.map(x => x->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc)

let timestamp = json =>
  json->Js.Json.decodeString->Belt.Option.getExn->MomentRe.momentUtcDefaultFormat

let timestampOpt = Belt.Option.map(_, timestamp)

let timestampWithDefault = jsonOpt =>
  jsonOpt
  ->Belt.Option.flatMap(x => Some(timestamp(x)))
  ->Belt.Option.getWithDefault(_, MomentRe.momentNow())

// let timeNS = json =>
//   json
//   -> Js.Json.decodeNumber
//   -> Belt.Option.getExn
//   -> (nanoSec => nanoSec /. 1e6)
//   -> MomentRe.momentWithTimestampMS
//   -> MomentRe.Moment.defaultUtc

let optionBuffer = Belt.Option.map(_, buffer)

let optionTimeMS = Belt.Option.map(_, timeMS)

let optionTimeS = Belt.Option.map(_, timeS)

let optionTimeSExn = timeSOpt => timeSOpt->Belt.Option.getExn->timeS

let bool = json => json->Js.Json.decodeBoolean->Belt.Option.getExn

let hash = json =>
  json->Js.Json.decodeString->Belt.Option.getExn->Js.String2.substr(~from=2)->Hash.fromHex

let intToCoin = int_ => int_->Belt.Float.fromInt->Coin.newUBANDFromAmount

let coin = json =>
  json
  ->Js.Json.decodeString
  ->Belt.Option.flatMap(Belt.Float.fromString)
  ->Belt.Option.getExn
  ->Coin.newUBANDFromAmount

let coinExn = jsonOpt =>
  jsonOpt
  ->Belt.Option.flatMap(Js.Json.decodeString)
  ->Belt.Option.flatMap(Belt.Float.fromString)
  ->Belt.Option.getExn
  ->Coin.newUBANDFromAmount

let coinWithDefault = jsonOpt => {
  jsonOpt
  ->Belt.Option.flatMap(Js.Json.decodeString)
  ->Belt.Option.flatMap(Belt.Float.fromString)
  ->Belt.Option.getWithDefault(0.)
  ->Coin.newUBANDFromAmount
}

let coinStr = str => {
  str->Belt.Float.fromString->Belt.Option.getExn->Coin.newUBANDFromAmount
}

let coinRegEx = "([0-9]+)([a-z][a-z0-9/]{2,31})"->Js.Re.fromString

let coins = str => {
  str
  ->Js.String2.split(",")
  ->Belt.List.fromArray
  ->Belt.List.keepMap(coin => {
    if coin === "" {
      None
    } else {
      let result = Js.Re.exec_(coinRegEx, coin)
      switch result {
      | None => None
      | Some(x) =>
        let re = x->Js.Re.captures
        Some({
          Coin.denom: {
            switch re[2]->Js.Nullable.toOption {
            | None => ""
            | Some(x) => x
            }
          },
          amount: {
            switch re[1]->Js.Nullable.toOption {
            | None => 0.
            | Some(x) => x->Belt.Float.fromString->Belt.Option.getExn
            }
          },
        })
      }
    }
  })
  // let result = Js.Re.exec_(coinRegEx, coin)->Belt.Option.getExn->Js.Re.captures

  // Some({
  //   Coin.denom: result[2]->Js.Nullable.toOption->Belt.Option.getExn,
  //   amount: result[1]->Js.Nullable.toOption->Belt.Option.flatMap(Belt.Float.fromString)->Belt.Option.getExn
  // })
}

let coinSerialize = coins => {
  coins
  ->Belt.List.map(Coin.getUBandAmountFromCoin)
  ->Belt.List.map(x => x->Belt.Float.toString->Js.String2.concat("uband"))
  ->Belt.List.reduceWithIndex("", (acc, item, index) =>
    acc ++
    switch index {
    | 0 => ""
    | _ => ", "
    } ++
    item
  )
}

let addressExn = strOpt => strOpt->Belt.Option.getExn->Address.fromBech32
let addressOpt = strOpt => strOpt->Belt.Option.map(Address.fromBech32)

let numberWithDefault = jsonOpt =>
  jsonOpt->Belt.Option.flatMap(Js.Json.decodeNumber)->Belt.Option.getWithDefault(_, 0.0)

let floatWithDefault = jsonOpt =>
  jsonOpt
  ->Belt.Option.flatMap(Js.Json.decodeString)
  ->Belt.Option.flatMap(Belt.Float.fromString)
  ->Belt.Option.getWithDefault(0.)

let floatString = json =>
  json->Js.Json.decodeString->Belt.Option.flatMap(Belt.Float.fromString)->Belt.Option.getExn

let floatExn = json => json->Js.Json.decodeNumber->Belt.Option.getExn
