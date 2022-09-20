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

module String = {
  type t = string
  let parse = json => json->GraphQLParser.string

  //Note: just mock
  let serialize = str => str->Js.Json.string
}

module FromUnixSecond = {
  type t = option<MomentRe.Moment.t>
  let parse = timeInt => timeInt->GraphQLParser.fromUnixSecond

  //Note: just mock
  let serialize = momentT => momentT->MomentRe.Moment.toUnix
}

module FloatExn = {
  type t = float

  let parse = json => json -> Js.Json.decodeNumber
  //Note: just mock
  let serialize = float => float->Js.Float.toString->Js.Json.parseExn
}

module Test = {
  type t = int

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

  let parse = json => json->GraphQLParser.floatWithDefault
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

module AddressOpt = {
  type t = Address.t
  //Note: just mock
  let parse = jsonOpt => jsonOpt->GraphQLParser.addressOpt
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
  let parse = jsonOpt => jsonOpt->GraphQLParser.coinWithDefault
  let serialize = coin => "coin" |> Js.Json.string
}

module Buffer = {
  type t = JsBuffer.t
  let parse = json => json->GraphQLParser.buffer
  let serialize = coin => "buffer" |> Js.Json.string
}

module OptionBuffer = {
  type t = option<JsBuffer.t>
  let parse = jsonOpt => jsonOpt->GraphQLParser.optionBuffer
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

module OracleScriptID = {
  type t = ID.OracleScript.t

  let parse = oracleScriptID => oracleScriptID->ID.OracleScript.fromInt
  let serialize = oracleScriptID => oracleScriptID->ID.OracleScript.toInt
}

module DataSourceID = {
  type t = ID.DataSource.t

  let parse = datasourceID => datasourceID->ID.DataSource.fromInt
  let serialize = datasourceID => datasourceID->ID.DataSource.toInt
}

module RequestID = {
  type t = ID.Request.t

  let parse = datasourceID => datasourceID->ID.Request.fromInt
  let serialize = datasourceID => datasourceID->ID.Request.toInt
}
