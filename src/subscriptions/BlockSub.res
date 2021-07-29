// Example for decoder
module Date = {
  type t = MomentRe.Moment.t
  let parse = json => json->GraphQLParser.timestamp

  let serialize = date => "empty"->Js.Json.string
}

type internal_t = {timestamp: MomentRe.Moment.t}

module MultiConfig = %graphql(`
  subscription Blocks($limit: Int!, $offset: Int!) {
    blocks(limit: $limit, offset: $offset, order_by: [{height: desc}]) @ppxAs(type: "internal_t") {
      timestamp @ppxCustom(module: "Date")
    }
  }
`)

module SingleConfig = %graphql(`
  subscription Block($height: Int!) {
    blocks_by_pk(height: $height) @ppxAs(type: "internal_t") {
      timestamp @ppxCustom(module: "Date")
    }
  }
`)

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset: offset})

  // result |> Sub.fromData |> Sub.map(_, ({blocks}) => blocks)
  result
}

let get = (~height, ()) => {
  let result = SingleConfig.use({height: height})
  result
}
