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
  let serialize = x => "empty"->Js.Json.string
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

module BlockID = {
  type t = ID.Block.t
  let parse = blockID => blockID->ID.Block.fromInt
  //Note: just mock
  let serialize = blockID => blockID->ID.Block.toInt
}
