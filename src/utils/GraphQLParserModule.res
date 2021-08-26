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
  let parse = json => json->GraphQLParser.string->Address.fromBech32
  let serialize = x => "empty"->Js.Json.string
}
