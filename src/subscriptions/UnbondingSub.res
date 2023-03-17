type validator_t = {
  operatorAddress: Address.t,
  moniker: string,
  identity: string,
}

type unbonding_list_t = {
  amount: Coin.t,
  completionTime: MomentRe.Moment.t,
  validator: validator_t,
}

module Unbonding = {
  type sum_t = {amount: option<Js.Json.t>}
  type aggregate_t = {sum: option<sum_t>}
  type unbonding_delegations_aggregate_t = {aggregate: option<aggregate_t>}
  type internal_t = {unbonding_delegations_aggregate: unbonding_delegations_aggregate_t}

  type t = Coin.t

  let toExternal = (sum: sum_t) => sum.amount->GraphQLParser.coinWithDefault
}

module SingleConfig = %graphql(`
    subscription Unbonding($delegator_address: String!, $current_time: timestamp!) {
      accounts_by_pk(address: $delegator_address) @ppxAs(type: "Unbonding.internal_t") {
        unbonding_delegations_aggregate(where: {completion_time: {_gte: $current_time}}) @ppxAs(type: "Unbonding.unbonding_delegations_aggregate_t") {
          aggregate  @ppxAs(type: "Unbonding.aggregate_t"){
            sum  @ppxAs(type: "Unbonding.sum_t") {
              amount 
            }
          }
        }
      }
    }
`)

module UnbondingByValidatorConfig = %graphql(`
    subscription Unbonding($delegator_address: String!, $operator_address: String!, $current_time: timestamp!) {
      accounts_by_pk(address: $delegator_address) {
        unbonding_delegations_aggregate(where: {validator: {operator_address: {_eq: $operator_address}}, completion_time: {_gte: $current_time}}) {
          aggregate {
            sum {
              amount
            }
          }
        }
      }
    }
`)

module UnbondingByDelegatorConfig = %graphql(`
    subscription UnbondingByDelegator($limit: Int!, $offset: Int!, $delegator_address: String!, $current_time: timestamp!) {
      accounts_by_pk(address: $delegator_address) {
        unbonding_delegations(offset: $offset, limit: $limit, order_by: [{completion_time: asc}], where: {completion_time: {_gte: $current_time}}) @ppxAs(type: "unbonding_list_t") {
          amount @ppxCustom(module: "GraphQLParserModule.Coin")
          completionTime: completion_time @ppxCustom(module: "GraphQLParserModule.Date")
          validator @ppxAs(type: "validator_t"){
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            moniker
            identity
          }
        }
      }
    }
  `)

module UnbondingCountByDelegatorConfig = %graphql(`
    subscription UnbondingCountByDelegator($delegator_address: String!, $current_time: timestamp!) {
      accounts_by_pk(address: $delegator_address) {
        unbonding_delegations_aggregate(where: {completion_time: {_gte: $current_time}}) {
          aggregate{
            count
          }
        }
      }
    }
  `)

let getUnbondingBalance = (delegatorAddress, currentTime) => {
  let result = SingleConfig.use({
    delegator_address: delegatorAddress->Address.toBech32,
    current_time: currentTime->Js.Json.string,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(({accounts_by_pk}) => {
    switch accounts_by_pk {
    | Some(data) =>
      Sub.resolve(
        data.unbonding_delegations_aggregate.aggregate->Belt.Option.mapWithDefault(
          Coin.newUBANDFromAmount(0.),
          data => data.sum->Belt.Option.getExn->Unbonding.toExternal,
        ),
      )
    | None => Sub.resolve(Coin.newUBANDFromAmount(0.))
    }
  })
}

let getUnbondingBalanceByValidator = (delegatorAddress, operatorAddress, currentTime) => {
  let result = UnbondingByValidatorConfig.use({
    delegator_address: delegatorAddress->Address.toBech32,
    operator_address: operatorAddress->Address.toOperatorBech32,
    current_time: currentTime->Js.Json.string,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(data =>
    switch data.accounts_by_pk {
    | Some(account) => Sub.resolve((
      switch account.unbonding_delegations_aggregate.aggregate {
      | Some(aggregate') => (aggregate'.sum->Belt.Option.getExn).amount->GraphQLParser.coinWithDefault
      | None => Coin.newUBANDFromAmount(0.)
      }
    ))
    | None => Sub.resolve(Coin.newUBANDFromAmount(0.))
    }
  )
}

let getUnbondingByDelegator = (delegatorAddress, currentTime, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize

  let result = UnbondingByDelegatorConfig.use({
    delegator_address: delegatorAddress->Address.toBech32,
    limit: pageSize,
    current_time: currentTime->Js.Json.string,
    offset,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(data =>
    switch data.accounts_by_pk {
    | Some(x') => Sub.resolve(x'.unbonding_delegations)
    | None => Sub.resolve([])
    }
  )
}

let getUnbondingCountByDelegator = (delegatorAddress, currentTime) => {
  let result = UnbondingCountByDelegatorConfig.use({
    delegator_address: delegatorAddress->Address.toBech32,
    current_time: currentTime->Js.Json.string,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(data =>
    switch data.accounts_by_pk {
    | Some(x') =>
      Sub.resolve(
        x'.unbonding_delegations_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count),
      )
    | None => Sub.resolve(0)
    }
  )
}
