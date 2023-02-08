type t = {
  t: int,
  y: float,
}

module HistoricalConfig = %graphql(`
query HistoricalBondedToken($operator_address: String!) {
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

  let x = result->Query.fromData->Query.flatMap({historical_bonded_token_on_validators})

  Query.resolve(
    x->Belt_Array.map(each => {
      t: each.timestamp->GraphQLParser.timestamp->MomentRe.Moment.toUnix,
      y: each.bonded_tokens->Js.Json.decodeString->Belt.Option.getExn->float_of_string /. 1e6,
    }),
  )
}
