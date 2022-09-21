module Date = {
  type t = MomentRe.Moment.t
  let parse = json => json->GraphQLParser.timestamp

  let serialize = date => date->MomentRe.Moment.toJSON->Belt.Option.getExn->Js.Json.string
}

module Hash = {
  type t = Hash.t
  let parse = json => json->GraphQLParser.hash

  //Note: just mock
  let serialize = x => "empty"->Js.Json.string
}

module FloatString = {
  type t = float

  let parse = json => json->GraphQLParser.floatString
  //Note: just mock
  let serialize = float => float->Js.Float.toString->Js.Json.parseExn
}

module FloatWithDefault = {
  type t = float

  let parse = jsonOpt => jsonOpt->GraphQLParser.floatWithDefault
  let serialize = float => Some(float->Js.Float.toString->Js.Json.parseExn)
}

module FloatStringExn = {
  type t = float

  let parse = json => json->Belt.Float.fromString->Belt.Option.getExn
  let serialize = float => float->Js.Float.toString
}

module Address = {
  type t = Address.t
  //Note: just mock
  let parse = json => json->Address.fromBech32
  let serialize = addr => addr->Address.toBech32
}

module Coins = {
  type t = list<Coin.t>
  let parse = json => json->GraphQLParser.coins
  //TODO: implement for coins
  let serialize = coins => "coins"
}

module Coin = {
  type t = Coin.t
  let parse = json => json->GraphQLParser.coin
  //TODO: implement for coins
  let serialize = coin => "coin" |> Js.Json.string
}

module BlockID = {
  type t = ID.Block.t
  let parse = blockID => blockID->ID.Block.fromInt
  //Note: just mock
  let serialize = blockID => blockID->ID.Block.toInt
}

module Buffer = {
  type t = JsBuffer.t
  let parse = json => json->GraphQLParser.buffer
  let serialize = buffer => buffer->Js.Json.string
}

module DataSourceID = {
  type t = ID.DataSource.t

  let parse = datasourceID => datasourceID->ID.DataSource.fromInt
  let serialize = datasourceID => datasourceID->ID.DataSource.toInt
}
