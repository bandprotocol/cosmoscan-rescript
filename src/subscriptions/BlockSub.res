type aggregate_t = {count: option<int>}

type transactions_aggregate_t = {aggregate: option<aggregate_t>}

type internal_t = {
  timestamp: MomentRe.Moment.t,
  hash: Hash.t,
  inflation: float,
  validator: ValidatorSub.Mini.t,
  transactions_aggregate: transactions_aggregate_t,
}

module MultiConfig = %graphql(`
  subscription Blocks($limit: Int!, $offset: Int!) {
    blocks(limit: $limit, offset: $offset, order_by: [{height: desc}]) @ppxAs(type: "internal_t") {
      timestamp @ppxCustom(module: "GraphQLParserModule.Date")
      hash @ppxCustom(module: "GraphQLParserModule.Hash")
      inflation @ppxCustom(module: "GraphQLParserModule.FloatString")
      validator @ppxAs(type: "ValidatorSub.Mini.t"){
        consensusAddress: consensus_address
        operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
        moniker
        identity
      }
      transactions_aggregate @ppxAs(type: "transactions_aggregate_t"){
        aggregate @ppxAs(type: "aggregate_t"){
          count
        }
      }
    }
  }
`)

module SingleConfig = %graphql(`
  subscription Block($height: Int!) {
    blocks_by_pk(height: $height) @ppxAs(type: "internal_t") {
      timestamp @ppxCustom(module: "GraphQLParserModule.Date")
      hash @ppxCustom(module: "GraphQLParserModule.Hash")
      inflation @ppxCustom(module: "GraphQLParserModule.FloatString")
      validator @ppxAs(type: "ValidatorSub.Mini.t"){
        consensusAddress: consensus_address
        operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
        moniker
        identity
      }
      transactions_aggregate @ppxAs(type: "transactions_aggregate_t"){
        aggregate @ppxAs(type: "aggregate_t"){
          count 
        }
      }
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
