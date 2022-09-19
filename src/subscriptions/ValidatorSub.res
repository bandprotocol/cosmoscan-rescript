type t = {
  rank: int,
  isActive: bool,
  oracleStatus: bool,
  operatorAddress: Address.t,
  consensusAddress: Address.t,
  moniker: string,
  identity: string,
  website: string,
  details: string,
  uptime: option<float>,
  tokens: Coin.t,
  commission: float,
  commissionMaxChange: float,
  commissionMaxRate: float,
  votingPower: float,
}

type internal_t = {
  oracleStatus: bool,
  operatorAddress: Address.t,
  consensusAddress: string,
  moniker: string,
  identity: string,
  website: string,
  jailed: bool,
  details: string,
  tokens: Coin.t,
  commissionRate: float,
  commissionMaxChange: float,
  commissionMaxRate: float,
}

type validator_vote_t = {
  consensusAddress: Address.t,
  count: int,
  voted: bool,
}

module Mini = {
  type t = {
    consensusAddress: string,
    operatorAddress: Address.t,
    moniker: string,
    identity: string,
  }
}


let toExternal = (
  {
    operatorAddress,
    consensusAddress,
    moniker,
    identity,
    website,
    jailed,
    oracleStatus,
    details,
    tokens,
    commissionRate,
    commissionMaxChange,
    commissionMaxRate,
  }: internal_t,
  rank,
) => {
  rank,
  isActive: !jailed,
  operatorAddress,
  consensusAddress: consensusAddress |> Address.fromHex,
  tokens,
  commission: commissionRate *. 100.,
  commissionMaxChange: commissionMaxChange *. 100.,
  commissionMaxRate: commissionMaxRate *. 100.,
  moniker,
  identity,
  website,
  oracleStatus,
  details,
  uptime: None,
  votingPower: tokens.amount,
}

open Address
module MultiConfig = %graphql(`
  subscription Validators($jailed: Boolean!) {
    validators(where: {jailed: {_eq: $jailed}}, order_by: [{tokens: desc, moniker: asc}]) @ppxAs(type: "internal_t") {
      operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
      consensusAddress: consensus_address
      moniker
      identity
      website
      jailed
      oracleStatus: status
      details
      tokens @ppxCustom(module: "GraphQLParserModule.Coin")
      commissionRate: commission_rate @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
      commissionMaxChange: commission_max_change @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
      commissionMaxRate: commission_max_rate @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
    }
  }
`)

module ValidatorAggCount = {
  type t = int
  type aggregate_t = {count: int}
  type internal_t = {aggregate: option<aggregate_t>}

  let toExternal = ({count}: aggregate_t) => count
}

module TotalBondedAmount = {
  type t = Coin.t
  type sum_t = {tokens: option<Js.Json.t>}
  type aggregate_t = {sum: option<sum_t>}
  type internal_t = {aggregate: option<aggregate_t>}

  let toExternal = (sum: sum_t) => sum.tokens |> GraphQLParser.coinWithDefault
}

module ValidatorCountConfig = %graphql(`
  subscription ValidatorCount {
    validators_aggregate @ppxAs(type: "ValidatorAggCount.internal_t") {
      aggregate @ppxAs(type: "ValidatorAggCount.aggregate_t") {
        count
      }
    }
  }
`)

module ValidatorCountByJailedConfig = %graphql(`
  subscription ValidatorCountByJailed($jailed: Boolean!) {
    validators_aggregate(where: {jailed: {_eq: $jailed}})  @ppxAs(type: "ValidatorAggCount.internal_t") {
      aggregate @ppxAs(type: "ValidatorAggCount.aggregate_t"){
        count
      }
    }
  }
`)

module TotalBondedAmountConfig = %graphql(`
  subscription TotalBondedAmount {
    validators_aggregate @ppxAs(type: "TotalBondedAmount.internal_t") {
      aggregate @ppxAs(type: "TotalBondedAmount.aggregate_t") {
        sum @ppxAs(type: "TotalBondedAmount.sum_t") {
          tokens
        }
      }
    }
  }
`)

module MultiLast100VotedConfig = %graphql(`
  subscription ValidatorsLast25Voted {
    validator_last_100_votes {
      consensus_address
      count
      voted
    }
  }
`)

let getList = (~isActive, ()) => {
  let result = MultiConfig.use({jailed: !isActive})
  
  result
  -> Sub.fromData
  -> Sub.map(({validators}) =>
    validators->Belt_Array.mapWithIndex((idx, each) => toExternal(each, idx + 1))
  )
}

let count = () => {
  let result = ValidatorCountConfig.use()

  result
  -> Sub.fromData
  -> Sub.map(({validators_aggregate}) =>
    validators_aggregate.aggregate |> Belt_Option.getExn |> (y => y |> ValidatorAggCount.toExternal)
  )
}

let countByActive = isActive => {
  let result = ValidatorCountByJailedConfig.use({jailed: !isActive})

  result
  -> Sub.fromData
  -> Sub.map(({validators_aggregate}) =>
    validators_aggregate.aggregate |> Belt_Option.getExn |> (y => y |> ValidatorAggCount.toExternal)
  )
}

let getTotalBondedAmount = () => {
  let result = TotalBondedAmountConfig.use()

  result
  -> Sub.fromData
  -> Sub.map(a =>
    a.validators_aggregate.aggregate
    -> Belt_Option.getExn
    -> ((y: TotalBondedAmount.aggregate_t) => y.sum)
    -> Belt_Option.getExn
    -> TotalBondedAmount.toExternal
  )
}

let getListVotesBlock = () => {
  let result = MultiLast100VotedConfig.use()

  result
  -> Sub.fromData
  -> Sub.map(x =>
    x.validator_last_100_votes->Belt_Array.map(each => {
      consensusAddress: each.consensus_address->Belt.Option.getExn->Address.fromHex,
      count: each.count->Belt.Option.getExn->GraphQLParser.int64,
      voted: each.voted->Belt.Option.getExn,
    })
  )
}
