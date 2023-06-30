// As you can see we need to define a type t and two functions, parse and serialize.
// These two functions are to go from Js.Json.t to t and how to go from t back to Js.Json.t.
// see https://beta.graphql-ppx.com/docs/directives#ppxcustom

module Date = {
  type t = MomentRe.Moment.t
  let parse = json => json->GraphQLParser.timestamp
  let serialize = date => date->MomentRe.Moment.toJSON->Belt.Option.getExn->Js.Json.string
}

module DateOpt = {
  type t = MomentRe.Moment.t
  let parse = jsonOpt => jsonOpt->GraphQLParser.timestampOpt
  let serialize = date => date->MomentRe.Moment.toJSON->Belt.Option.getExn->Js.Json.string
}

module Hash = {
  type t = Hash.t
  let parse = json => json->GraphQLParser.hash
  let serialize = hash => hash->Hash.toHex->Js.Json.string
}

module String = {
  type t = string
  let parse = json => json->GraphQLParser.string
  let serialize = str => str->Js.Json.string
}

module FromUnixSecond = {
  type t = option<MomentRe.Moment.t>
  let parse = timeInt => timeInt->GraphQLParser.fromUnixSecond
  let serialize = momentT => momentT->MomentRe.Moment.toUnix
}

module FloatExn = {
  type t = float
  let parse = json => json->Js.Json.decodeNumber->Belt.Option.getExn
  let serialize = float => float->Js.Float.toString->Js.Json.parseExn
}

module FloatString = {
  type t = float
  let parse = json => json->GraphQLParser.floatString
  let serialize = float => float->Js.Float.toString->Js.Json.string
}

module IntString = {
  type t = float
  let parse = json => json->GraphQLParser.int64
  let serialize = float => float->Js.Int.toString->Js.Json.string
}

module FloatWithDefault = {
  type t = float
  let parse = jsonOpt => jsonOpt->GraphQLParser.floatWithDefault
  let serialize = float => Some(float->Js.Float.toString->Js.Json.parseExn)
}

module FloatStringExn = {
  type t = float
  let parse = str => str->Belt.Float.fromString->Belt.Option.getExn
  let serialize = float => float->Js.Float.toString
}

module AddressOpt = {
  type t = Address.t
  let parse = jsonOpt => jsonOpt->GraphQLParser.addressOpt
  let serialize = addrOpt => addrOpt->Belt.Option.map(Address.toBech32)
}

module Address = {
  type t = Address.t
  let parse = json => json->Address.fromBech32
  let serialize = addr => addr->Address.toBech32
}

module Coins = {
  type t = list<Coin.t>
  let parse = str => str->GraphQLParser.coins
  let serialize = coins => coins->GraphQLParser.coinSerialize
}

module CoinWithDefault = {
  type t = Coin.t
  let parse = jsonOpt => jsonOpt->GraphQLParser.coinWithDefault
  let serialize = coin => Some(
    coin
    ->Coin.getUBandAmountFromCoin
    ->(amount => amount->Belt.Float.toString ++ "uband")
    ->Js.Json.string,
  )
}

module Coin = {
  type t = Coin.t
  let parse = json => json->GraphQLParser.coin
  let serialize = coin =>
    coin
    ->Coin.getUBandAmountFromCoin
    ->(amount => amount->Belt.Float.toString ++ "uband")
    ->Js.Json.string
}

module Buffer = {
  type t = JsBuffer.t
  let parse = json => json->GraphQLParser.buffer
  let serialize = buff => ("0x" ++ buff->JsBuffer.toHex)->Js.Json.string
}

module BufferOpt = {
  type t = option<JsBuffer.t>
  let parse = jsonOpt => jsonOpt->GraphQLParser.optionBuffer
  let serialize = buffOpt =>
    buffOpt->Belt.Option.map(buff => ("0x" ++ buff->JsBuffer.toHex)->Js.Json.string)
}

module BlockID = {
  type t = ID.Block.t
  let parse = blockID => blockID->ID.Block.fromInt
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
