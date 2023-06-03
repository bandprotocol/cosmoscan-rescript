type t = {
  t: int,
  y: float,
}

module HistoricalConfig = %graphql(`
  subscription HistoricalBondedToken($operator_address: String!) {
    historical_bonded_token_on_validators(where: {validator: {operator_address: {_eq: $operator_address}}}, order_by: [{timestamp: asc}]) {
      bonded_tokens
      timestamp
    }
  }
`)

let get = operatorAddress => {
  let result = HistoricalConfig.use({
    operator_address: operatorAddress->Address.toOperatorBech32,
  })

  let x =
    result
    ->Sub.fromData
    ->Sub.map(({historical_bonded_token_on_validators}) => {
      historical_bonded_token_on_validators->Belt.Array.map(each => {
        t: each.timestamp->GraphQLParser.timestamp->MomentRe.Moment.toUnix,
        y: each.bonded_tokens
        ->Js.Json.decodeString
        ->Belt.Option.flatMap(Belt.Float.fromString)
        ->Belt.Option.getExn /. 1e6,
      })
    })
  x
}
