module StakeSummary = {
  type sum_t = {
    amount: option<Js.Json.t>,
    reward: option<Js.Json.t>,
  }
  type aggregate_t = {sum: option<sum_t>}
  type internal_t = {aggregate: option<aggregate_t>}

  type t = {
    amount: Coin.t,
    reward: Coin.t,
  }

  let toExternal = (sum: sum_t) => {
    amount: sum.amount |> GraphQLParser.coinWithDefault,
    reward: sum.reward |> GraphQLParser.coinWithDefault,
  }
}

module Stake = {
  type internal_t = {
    amount: option<Js.Json.t>,
    delegatorAddress: option<string>,
    moniker: option<string>,
    operatorAddress: option<string>,
    reward: option<Js.Json.t>,
    sharePercentage: option<Js.Json.t>,
    identity: option<string>,
  }

  type t = {
    amount: Coin.t,
    delegatorAddress: Address.t,
    moniker: string,
    operatorAddress: Address.t,
    reward: Coin.t,
    sharePercentage: float,
    identity: string,
  }

  let toExternal = (
    {
      amount,
      delegatorAddress,
      moniker,
      operatorAddress,
      reward,
      sharePercentage,
      identity,
    }: internal_t,
  ) => {
    amount: amount |> GraphQLParser.coinExn,
    delegatorAddress: delegatorAddress |> GraphQLParser.addressExn,
    moniker: moniker |> GraphQLParser.stringExn,
    operatorAddress: operatorAddress |> GraphQLParser.addressExn,
    reward: reward |> GraphQLParser.coinExn,
    sharePercentage: sharePercentage |> GraphQLParser.floatWithDefault,
    identity: identity |> GraphQLParser.stringExn,
  }
}
module StakeWithDefault = {
  type internal_t = {
    amount: option<Js.Json.t>,
    reward: option<Js.Json.t>,
  }

  type t = {
    amount: Coin.t,
    reward: Coin.t,
  }

  let toExternal = ({amount, reward}: internal_t) => {
    amount: amount |> GraphQLParser.coinExn,
    reward: reward |> GraphQLParser.coinExn,
  }
}

module StakeCount = {
  type aggregate_t = {count: option<int>}
  type internal_t = {aggregate: option<aggregate_t>}

  type t = int

  let toExternal = ({count}: aggregate_t) => count |> Belt_Option.getExn
}

module StakeConfig = %graphql(`
  subscription Stake($limit: Int!, $offset: Int!, $delegator_address: String!)  {
    delegations_view(offset: $offset, limit: $limit, order_by: [{amount: desc}], where: {delegator_address: {_eq: $delegator_address}}) @ppxAs(type: "Stake.internal_t")  {
      amount
      delegatorAddress: delegator_address 
      moniker
      operatorAddress: operator_address 
      reward 
      sharePercentage: share_percentage 
      identity 
    }
  }
  `)

module TotalStakeByDelegatorConfig = %graphql(`
  subscription TotalStake($delegator_address: String!) {
    delegations_view_aggregate(where: {delegator_address: {_eq: $delegator_address}}) @ppxAs(type: "StakeSummary.internal_t") {
      aggregate @ppxAs(type :"StakeSummary.aggregate_t") {
        sum @ppxAs(type: "StakeSummary.sum_t") {
          amount 
          reward 
        }
      }
    }
  }
  `)

module StakeByValidatorConfig = %graphql(`
  subscription StakeByValidator($delegator_address: String!, $operator_address: String!) {
    delegations_view(where: {_and: [{delegator_address: {_eq: $delegator_address}, operator_address: {_eq: $operator_address}}]}) @ppxAs(type: "StakeWithDefault.internal_t")  {
      amount
      reward
    }
  }
`)

module StakeCountByDelegatorConfig = %graphql(`
  subscription CountByDelegator($delegator_address: String!) {
    delegations_view_aggregate(where: {delegator_address: {_eq: $delegator_address}}) @ppxAs(type: "StakeCount.internal_t"){
      aggregate @ppxAs(type: "StakeCount.aggregate_t"){
        count
      }
    }
  }
`)

module DelegatorsByValidatorConfig = %graphql(`
  subscription Stake($limit: Int!, $offset: Int!, $operator_address: String!)  {
    delegations_view(offset: $offset, limit: $limit, order_by: [{amount: desc}], where: {operator_address: {_eq: $operator_address}}) @ppxAs(type: "Stake.internal_t")  {
      amount
      delegatorAddress: delegator_address
      moniker
      operatorAddress: operator_address
      reward
      sharePercentage: share_percentage
      identity
    }
  }
  `)

module DelegatorCountConfig = %graphql(`
    subscription DelegatorCount($operator_address: String!) {
      delegations_view_aggregate(where: {operator_address: {_eq: $operator_address}}) @ppxAs(type: "StakeCount.internal_t") {
        aggregate @ppxAs(type: "StakeCount.aggregate_t") {
          count
        }
      }
    }
  `)

let getStakeList = (delegatorAddress, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize

  let result = StakeConfig.use({
    delegator_address: delegatorAddress |> Address.toBech32,
    limit: pageSize,
    offset: offset,
  })

  result
  |> Sub.fromData
  |> Sub.map(_, ({delegations_view}) => delegations_view->Belt_Array.map(Stake.toExternal))
}

let getDelegatorsByValidator = (validatorAddress, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize

  let result = DelegatorsByValidatorConfig.use({
    operator_address: validatorAddress |> Address.toOperatorBech32,
    limit: pageSize,
    offset: offset,
  })

  result
  |> Sub.fromData
  |> Sub.map(_, ({delegations_view}) => delegations_view->Belt_Array.map(Stake.toExternal))
}

let getTotalStakeByDelegator = delegatorAddress => {
  let result = TotalStakeByDelegatorConfig.use({
    delegator_address: delegatorAddress |> Address.toBech32,
  })

  result
  |> Sub.fromData
  |> Sub.flatMap(_, ({delegations_view_aggregate}) => {
    let agg = delegations_view_aggregate.aggregate |> Belt_Option.getExn
    switch agg.sum {
    | Some(data) => Sub.resolve(data |> StakeSummary.toExternal)
    | None => Sub.NoData
    }
  })
}

let getStakeByValidator = (delegatorAddress, operatorAddress) => {
  let result = StakeByValidatorConfig.use({
    operator_address: operatorAddress |> Address.toOperatorBech32,
    delegator_address: delegatorAddress |> Address.toBech32,
  })

  result
  |> Sub.fromData
  |> Sub.map(_, ({delegations_view}) =>
    delegations_view
    ->Belt_Array.get(0)
    ->Belt_Option.mapWithDefault(
      (
        {
          amount: Coin.newUBANDFromAmount(0.),
          reward: Coin.newUBANDFromAmount(0.),
        }: StakeWithDefault.t
      ),
      StakeWithDefault.toExternal,
    )
  )
}

let getStakeCountByDelegator = delegatorAddress => {
  let result = StakeCountByDelegatorConfig.use({
    delegator_address: delegatorAddress |> Address.toBech32,
  })

  result
  |> Sub.fromData
  |> Sub.map(_, ({delegations_view_aggregate}) =>
    delegations_view_aggregate.aggregate |> Belt_Option.getExn |> (y => y |> StakeCount.toExternal)
  )
}

let getDelegatorCountByValidator = validatorAddress => {
  let result = DelegatorCountConfig.use({
    operator_address: validatorAddress |> Address.toBech32,
  })

  result
  |> Sub.fromData
  |> Sub.map(_, ({delegations_view_aggregate}) =>
    delegations_view_aggregate.aggregate |> Belt_Option.getExn |> (y => y |> StakeCount.toExternal)
  )
}
