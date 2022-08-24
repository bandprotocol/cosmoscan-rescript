type aggregate_t = {count: int}

type transactions_aggregate_t = {aggregate: option<aggregate_t>}

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
  let result = MultiConfig.use({limit: pageSize, offset})

  result |> Sub.fromData |> Sub.map(_, ({blocks}) => blocks->Belt_Array.map(toExternal))
}

let get = (~height, ()) => {
  let result = SingleConfig.use({height: height})
  result
}
