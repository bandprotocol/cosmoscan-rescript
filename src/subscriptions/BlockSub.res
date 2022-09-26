type aggregate_t = {count: int}

type transactions_aggregate_t = {aggregate: option<aggregate_t>}

type blocks_aggregate_t = {aggregate: option<aggregate_t>}

type internal_validator_t = {
  consensusAddress: string,
  operatorAddress: Address.t,
  moniker: string,
  identity: string,
}

type internal_t = {
  timestamp: MomentRe.Moment.t,
  hash: Hash.t,
  inflation: float,
  validator: internal_validator_t,
  transactions_aggregate: transactions_aggregate_t,
}

type t = {
  hash: Hash.t,
  inflation: float,
  timestamp: MomentRe.Moment.t,
  validator: ValidatorSub.Mini.t,
  txn: int,
}

let toExternal = ({hash, inflation, timestamp, validator, transactions_aggregate}) => {
  hash,
  inflation,
  timestamp,
  validator: {
    consensusAddress: validator.consensusAddress,
    operatorAddress: validator.operatorAddress,
    moniker: validator.moniker,
    identity: validator.identity,
  },
  txn: switch transactions_aggregate.aggregate {
  | Some(aggregate) => aggregate.count
  | _ => 0
  },
}

module MultiConfig = %graphql(`
  subscription Blocks($limit: Int!, $offset: Int!) {
    blocks(limit: $limit, offset: $offset, order_by: [{height: desc}]) @ppxAs(type: "internal_t") {
      timestamp @ppxCustom(module: "GraphQLParserModule.Date")
      hash @ppxCustom(module: "GraphQLParserModule.Hash")
      inflation @ppxCustom(module: "GraphQLParserModule.FloatString")
      validator @ppxAs(type: "internal_validator_t"){
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
      validator @ppxAs(type: "internal_validator_t"){
        consensusAddress: consensus_address
        operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
        moniker
        identity
      }
      transactions_aggregate @ppxAs(type: "transactions_aggregate_t") {
        aggregate @ppxAs(type: "aggregate_t"){
          count 
        }
      }
    }
  }
`)

module PastDayBlockCountConfig = %graphql(`
  subscription AvgDayBlocksCount($greater: timestamp!, $less: timestamp!) {
    blocks_aggregate(where: {timestamp: {_lte: $less, _gte: $greater}}) @ppxAs(type: "blocks_aggregate_t") {
      aggregate  @ppxAs(type: "aggregate_t") {
        count
      }
    }
  }
`)

module BlockSum = {
  let toExternal = (count: int) => (24 * 60 * 60)->float_of_int /. count->float_of_int
}

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(({blocks}) => blocks->Belt.Array.map(toExternal))
}

let get = (~height, ()) => {
  let result = SingleConfig.use({height: height})
  result
}

let getAvgBlockTime = (greater, less) => {
  let result = PastDayBlockCountConfig.use({
    greater: greater->Js.Json.string,
    less: less->Js.Json.string,
  })

  result
  ->Sub.fromData
  ->Sub.map(({blocks_aggregate}) =>
    blocks_aggregate.aggregate->Belt_Option.getExn->(y => y.count)->BlockSum.toExternal
  )
}

let getLatest = () => {
  let result = getList(~pageSize=1, ~page=1, ())

  result->Sub.flatMap(_, blocks => {
    switch blocks->Belt.Array.get(0) {
    | Some(latestBlock) => latestBlock->Sub.resolve
    | None => NoData
    }
  })
}
