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

module FloatExn = {
  type t = float

  let parse = json => json -> Js.Json.decodeNumber
  //Note: just mock
  let serialize = float => float->Js.Float.toString->Js.Json.parseExn
}

module Test = {
  type t = float

  let parse = json => json -> Belt.Option.getExn -> Js.Json.decodeNumber -> Belt.Option.getExn
  //Note: just mock
  let serialize = float => float->Js.Float.toString->Js.Json.parseExn
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

module CoinWithDefault = {
  type t = Coin.t
  let parse = json => json->GraphQLParser.coinWithDefault
  //TODO: implement for coins
  let serialize = coin => "coin" |> Js.Json.string
}

module BlockID = {
  type t = ID.Block.t
  let parse = blockID => blockID->ID.Block.fromInt
  //Note: just mock
  let serialize = blockID => blockID->ID.Block.toInt
}

module ProposalID = {
  type t = ID.Proposal.t

  let parse = proposalID => proposalID->ID.Proposal.fromInt
  let serialize = proposalID => proposalID->ID.Proposal.toInt
}
