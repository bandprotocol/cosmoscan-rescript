type aggregate_t = {count: int}

type transactions_aggregate_t = {aggregate: option<aggregate_t>}

type blocks_aggregate_t = {aggregate: option<aggregate_t>}

type internal_validator_t = {
  consensusAddress: string,
  operatorAddress: Address.t,
  moniker: string,
  identity: string,
}

type request_t = {
  id: ID.Request.t,
  isIBC: bool
}

type internal_t = {
  height: ID.Block.t,
  timestamp: MomentRe.Moment.t,
  hash: Hash.t,
  inflation: float,
  validator: internal_validator_t,
  transactions_aggregate: transactions_aggregate_t,
  requests: array<request_t>,
}


type t = {
  height: ID.Block.t,
  timestamp: MomentRe.Moment.t,
  hash: Hash.t,
  inflation: float,
  validator: ValidatorSub.Mini.t,
  txn: int,
  requests: array<request_t>,
}

let toExternal = ({height, hash, inflation, timestamp, validator, transactions_aggregate, requests}) => {
  height,
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
  requests
}

module MultiConfig = %graphql(`
  subscription Blocks($limit: Int!, $offset: Int!) {
    blocks(limit: $limit, offset: $offset, order_by: [{height: desc}]) @ppxAs(type: "internal_t") {
      height @ppxCustom(module: "GraphQLParserModule.BlockID")
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
      requests(where: {resolve_status: {_neq: "Open"}}) @ppxAs(type: "request_t"){
        id @ppxCustom(module: "GraphQLParserModule.RequestID")
        isIBC: is_ibc
      }
    }
  }
`)

module SingleConfig = %graphql(`
  subscription Block($height: Int!) {
    blocks_by_pk(height: $height) @ppxAs(type: "internal_t") {
      height @ppxCustom(module: "GraphQLParserModule.BlockID")
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
      requests(where: {resolve_status: {_neq: "Open"}}) @ppxAs(type: "request_t"){
        id @ppxCustom(module: "GraphQLParserModule.RequestID")
        isIBC: is_ibc
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
  let toExternal = (count: int) => (24 * 60 * 60)->Belt.Int.toFloat /. (count->Belt.Int.toFloat)
}

let getList = (~page, ~pageSize) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result 
  -> Sub.fromData 
  -> Sub.map(({blocks}) => blocks->Belt_Array.map(toExternal))
}

let get = (height: ID.Block.t) => {
  let result = SingleConfig.use({height: height -> ID.Block.toInt})

  result
  -> Sub.fromData 
  -> Sub.flatMap(({blocks_by_pk}) => 
    switch blocks_by_pk {
    | Some(data) => data->toExternal->Sub.resolve
    | None => NoData
    }
  )
}

let getAvgBlockTime = (greater, less) => {
  let result = PastDayBlockCountConfig.use({
    greater: greater->Js.Json.string,
    less: less->Js.Json.string,
  })

  result
  -> Sub.fromData
  -> Sub.map(({blocks_aggregate}) =>
    blocks_aggregate.aggregate->Belt_Option.getExn->(y => y.count)->BlockSum.toExternal
  )
}

let getLatest = () => {
  let result = getList(~pageSize=1, ~page=1)

  result 
  -> Sub.flatMap(blocks => {
    switch blocks->Belt_Array.get(0) {
    | Some(latestBlock) => latestBlock -> Sub.resolve
    | None => NoData
    }
  })
}
