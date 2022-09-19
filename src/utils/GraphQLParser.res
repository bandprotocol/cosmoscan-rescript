let int64 = json => json |> Js.Json.decodeString |> Belt.Option.getExn |> int_of_string
let string = json => json |> Js.Json.decodeString |> Belt.Option.getExn
let jsonToStringExn = jsonOpt =>
  jsonOpt |> Belt.Option.getExn |> Js.Json.decodeString |> Belt.Option.getExn
let stringExn = (stringOpt: option<string>) => stringOpt |> Belt.Option.getExn
let buffer = json =>
  json
  |> Js.Json.decodeString
  |> Belt.Option.getExn
  |> Js.String.substr(~from=2)
  |> JsBuffer.fromHex

let timeS = json =>
  json
  |> Js.Json.decodeNumber
  |> Belt.Option.getExn
  |> int_of_float
  |> MomentRe.momentWithUnix
  |> MomentRe.Moment.defaultUtc

let fromUnixSecondOpt = timeOpt =>
  timeOpt->Belt.Option.map(x => x |> MomentRe.momentWithUnix |> MomentRe.Moment.defaultUtc)

let timeMS = json =>
  json
  |> Js.Json.decodeNumber
  |> Belt.Option.getExn
  |> MomentRe.momentWithTimestampMS
  |> MomentRe.Moment.defaultUtc

let timestamp = json =>
  json |> Js.Json.decodeString |> Belt.Option.getExn |> MomentRe.momentUtcDefaultFormat

let timeNS = json =>
  json
  |> Js.Json.decodeNumber
  |> Belt.Option.getExn
  |> (nanoSec => nanoSec /. 1e6)
  |> MomentRe.momentWithTimestampMS
  |> MomentRe.Moment.defaultUtc

let timestampOpt = Belt.Option.map(_, timestamp)

let timestampWithDefault = jsonOpt =>
  jsonOpt
  -> Belt.Option.flatMap(x => Some(timestamp(x)))
  -> Belt.Option.getWithDefault(_, MomentRe.momentNow())

let optionBuffer = Belt.Option.map(_, buffer)

let optionTimeMS = Belt.Option.map(_, timeMS)

let optionTimeS = Belt.Option.map(_, timeS)

let optionTimeSExn = timeSOpt => timeSOpt |> Belt.Option.getExn |> timeS

let bool = json => json |> Js.Json.decodeBoolean |> Belt.Option.getExn

let hash = json =>
  json |> Js.Json.decodeString |> Belt.Option.getExn |> Js.String.substr(~from=2) |> Hash.fromHex

let coinRegEx = "([0-9]+)([a-z][a-z0-9/]{2,31})" |> Js.Re.fromString

let intToCoin = int_ => int_ |> float_of_int |> Coin.newUBANDFromAmount

let coin = json =>
  json |> Js.Json.decodeString |> Belt.Option.getExn |> float_of_string |> Coin.newUBANDFromAmount

let coinExn = jsonOpt =>
  jsonOpt
  -> Belt.Option.flatMap(Js.Json.decodeString)
  |> Belt.Option.getExn
  |> float_of_string
  |> Coin.newUBANDFromAmount
  
let coinWithDefault = jsonOpt =>
  jsonOpt
  -> Belt.Option.flatMap(Js.Json.decodeNumber)
  |> Belt.Option.getWithDefault(_, 0.0)
  |> Coin.newUBANDFromAmount

let coins = str =>
  str
  |> Js.String.split(",")
  |> Belt_List.fromArray
  |> Belt_List.keepMap(_, coin =>
    if coin == "" {
      None
    } else {
      let result = coin |> Js.Re.exec_(coinRegEx) |> Belt.Option.getExn |> Js.Re.captures
      Some({
        Coin.denom: result[2] |> Js.Nullable.toOption |> Belt.Option.getExn,
        amount: result[1] |> Js.Nullable.toOption |> Belt.Option.getExn |> float_of_string,
      })
    }
  )

let addressExn = jsonOpt => jsonOpt |> Belt.Option.getExn |> Address.fromBech32
let addressOpt = jsonOpt => jsonOpt |> Belt.Option.map(_, Address.fromBech32)

let numberWithDefault = jsonOpt =>
  jsonOpt -> Belt.Option.flatMap( Js.Json.decodeNumber) |> Belt.Option.getWithDefault(_, 0.0)

let floatWithDefault = jsonOpt =>
  jsonOpt
  -> Belt.Option.flatMap(Js.Json.decodeString)
  -> Belt.Option.mapWithDefault(0., float_of_string)

let floatString = json => json |> Js.Json.decodeString |> Belt.Option.getExn |> float_of_string

let floatExn = jsonOpt => 
  jsonOpt -> Js.Json.decodeNumber -> Belt.Option.getExn;
