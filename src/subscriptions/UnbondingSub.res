// type t = {balance: Coin.t}

// type unbonding_status_t = {
//   completionTime: MomentRe.Moment.t,
//   amount: Coin.t,
// }

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

// module UnbondingList = {
//   type validator_t = {
//     operatorAddress: Address.t,
//     moniker: string,
//     identity: string,
//   }
//   type t = {
//     amount: Coin.t,
//     completionTime: MomentRe.Moment.t,
//     validator: validator_t,
//   }

//   let toExternal = ({amount, completionTime, validator}) => {
//     amount: amount,
//     completionTime: completionTime,
//     validator: validator,
//   }
// }

module Unbonding = {
  type sum_t = {amount: option<Js.Json.t>}
  type aggregate_t = {sum: option<sum_t>}
  type unbonding_delegations_aggregate_t = {aggregate: option<aggregate_t>}
  type internal_t = {unbonding_delegations_aggregate: unbonding_delegations_aggregate_t}

  type t = Coin.t

  let toExternal = (sum: sum_t) => sum.amount |> GraphQLParser.coinWithDefault
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

// module MultiConfig = %graphql(`
//   subscription Unbonding($delegator_address: String!, $operator_address: String!, $completion_time: timestamp) {
//   accounts_by_pk(address: $delegator_address) {
//     unbonding_delegations(order_by: {completion_time: asc}, where: {_and: {completion_time: {_gte: $completion_time}, validator: {operator_address: {_eq: $operator_address}}}}) @bsRecord {
//       completionTime: completion_time @bsDecoder(fn: "GraphQLParser.timestamp")
//       amount @bsDecoder(fn: "GraphQLParser.coin")
//     }
//   }
//   }
// `)

// module UnbondingByValidatorConfig = %graphql(`
//     subscription Unbonding($delegator_address: String!, $operator_address: String!, $current_time: timestamp) {
//       accounts_by_pk(address: $delegator_address) {
//         unbonding_delegations_aggregate(where: {validator: {operator_address: {_eq: $operator_address}}, completion_time: {_gte: $current_time}}) {
//           aggregate {
//             sum {
//               amount @bsDecoder(fn: "GraphQLParser.coinWithDefault")
//             }
//           }
//         }
//       }
//     }
// `)

module UnbondingByDelegatorConfig = %graphql(`
    subscription UnbondingByDelegator($limit: Int!, $offset: Int!, $delegator_address: String!, $current_time: timestamp!) {
      accounts_by_pk(address: $delegator_address) {
        unbonding_delegations(offset: $offset, limit: $limit, order_by: [{completion_time: asc}], where: {completion_time: {_gte: $current_time}}) {
          amount @ppxCustom(module: "GraphQLParserModule.Coin")
          completionTime: completion_time @ppxCustom(module: "GraphQLParserModule.Date")
          validator @bsRecord{
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Addr")
            moniker
            identity
          }
        }
      }
    }
  `)

// module UnbondingCountByDelegatorConfig = %graphql(`
//     subscription UnbondingCountByDelegator($delegator_address: String!, $current_time: timestamp) {
//       accounts_by_pk(address: $delegator_address) {
//         unbonding_delegations_aggregate(where: {completion_time: {_gte: $current_time}}) {
//           aggregate{
//             count @bsDecoder(fn: "Belt_Option.getExn")
//           }
//         }
//       }
//     }
//   `)

let getUnbondingBalance = (delegatorAddress, currentTime) => {
  let result = SingleConfig.use({
    delegator_address: delegatorAddress |> Address.toBech32,
    current_time: currentTime |> Js.Json.string,
  })

  result
  |> Sub.fromData
  |> Sub.flatMap(_, ({accounts_by_pk}) => {
    switch accounts_by_pk {
    | Some(data) =>
      Sub.resolve(
        data.unbonding_delegations_aggregate.aggregate
        |> Belt_Option.getExn
        |> (data => data.sum |> Belt_Option.getExn |> Unbonding.toExternal),
      )
    | None => Sub.resolve(Coin.newUBANDFromAmount(0.))
    }
  })
}

// let getUnbondingBalanceByValidator = (delegatorAddress, operatorAddress, currentTime) => {
//   let (result, _) = ApolloHooks.useSubscription(
//     UnbondingByValidatorConfig.definition,
//     ~variables=UnbondingByValidatorConfig.makeVariables(
//       ~delegator_address=delegatorAddress |> Address.toBech32,
//       ~operator_address=operatorAddress |> Address.toOperatorBech32,
//       ~current_time=currentTime |> Js.Json.string,
//       (),
//     ),
//   )

//   let unbondingInfoSub = result |> Sub.map(_, a =>
//     switch a["accounts_by_pk"] {
//     | Some(account) =>
//       (
//         (
//           account["unbonding_delegations_aggregate"]["aggregate"] |> Belt_Option.getExn
//         )["sum"] |> Belt_Option.getExn
//       )["amount"]
//     | None => Coin.newUBANDFromAmount(0.)
//     }
//   )

//   %Sub({
//     let unbondingInfo = unbondingInfoSub
//     unbondingInfo |> Sub.resolve
//   })
// }

let getUnbondingByDelegator = (delegatorAddress, currentTime, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize

  let result = UnbondingByDelegatorConfig.use({
    delegator_address: delegatorAddress |> Address.toBech32,
    limit: pageSize,
    current_time: currentTime |> Js.Json.string,
    offset: offset,
  })

  result
  |> Sub.fromData
  |> Sub.flatMap(_, data =>
    switch data.accounts_by_pk {
    | Some(x') => Sub.resolve(x'.unbonding_delegations)
    | None => Sub.resolve([])
    }
  )
}

// let getUnbondingCountByDelegator = (delegatorAddress, currentTime) => {
//   let (result, _) = ApolloHooks.useSubscription(
//     UnbondingCountByDelegatorConfig.definition,
//     ~variables=UnbondingCountByDelegatorConfig.makeVariables(
//       ~delegator_address=delegatorAddress |> Address.toBech32,
//       ~current_time=currentTime |> Js.Json.string,
//       (),
//     ),
//   )
//   result |> Sub.map(_, x =>
//     switch x["accounts_by_pk"] {
//     | Some(x') =>
//       x'["unbonding_delegations_aggregate"]["aggregate"] |> Belt_Option.getExn |> (y => y["count"])
//     | None => 0
//     }
//   )
// }

// let getUnbondingList = (delegatorAddress, operatorAddress, completionTime) => {
//   let (result, _) = ApolloHooks.useSubscription(
//     MultiConfig.definition,
//     ~variables=MultiConfig.makeVariables(
//       ~delegator_address=delegatorAddress |> Address.toBech32,
//       ~operator_address=operatorAddress |> Address.toOperatorBech32,
//       ~completion_time=completionTime |> Js.Json.string,
//       (),
//     ),
//   )
//   result |> Sub.map(_, x =>
//     switch x["accounts_by_pk"] {
//     | Some(x') => x'["unbonding_delegations"]
//     | None => []
//     }
//   )
// }
