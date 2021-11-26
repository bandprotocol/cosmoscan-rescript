type t = {balance: Coin.t}

type validator_t = {
  operatorAddress: Address.t,
  moniker: string,
  identity: string,
}

type redelegate_list_t = {
  amount: Coin.t,
  completionTime: MomentRe.Moment.t,
  dstValidator: validator_t,
  srcValidator: validator_t,
}

module RedelegationByDelegatorConfig = %graphql(`
    subscription UnbondingByDelegator($limit: Int!, $offset: Int!, $delegator_address: String!, $current_time: timestamp!) {
      accounts_by_pk(address: $delegator_address) {
        redelegations(offset: $offset, limit: $limit, order_by: [{completion_time: asc}], where: {completion_time: {_gte: $current_time}}) @ppxAs(type: "redelegate_list_t"){
          amount @ppxCustom(module: "GraphQLParserModule.Coin")
          completionTime: completion_time @ppxCustom(module: "GraphQLParserModule.Date")
          srcValidator: validatorByValidatorSrcId @ppxAs(type: "validator_t"){
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            moniker
            identity
          }
          dstValidator: validatorByValidatorDstId @ppxAs(type: "validator_t"){
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            moniker
            identity
          }
        }
      }
    }
  `)

module RedelegateCountByDelegatorConfig = %graphql(`
    subscription UnbondingCountByDelegator($delegator_address: String!, $current_time: timestamp!) {
      accounts_by_pk(address: $delegator_address) {
        redelegations_aggregate(where: {completion_time: {_gte: $current_time}}) {
          aggregate{
            count
          }
        }
      }
    }
  `)

let getRedelegationByDelegator = (delegatorAddress, currentTime, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize

  let result = RedelegationByDelegatorConfig.use({
    delegator_address: delegatorAddress |> Address.toBech32,
    limit: pageSize,
    current_time: currentTime |> Js.Json.string,
    offset: offset,
  })

  result
  |> Sub.fromData
  |> Sub.flatMap(_, data =>
    switch data.accounts_by_pk {
    | Some(x') => Sub.resolve(x'.redelegations)
    | None => Sub.resolve([])
    }
  )
}

let getRedelegateCountByDelegator = (delegatorAddress, currentTime) => {
  let result = RedelegateCountByDelegatorConfig.use({
    delegator_address: delegatorAddress |> Address.toBech32,
    current_time: currentTime |> Js.Json.string,
  })

  result
  |> Sub.fromData
  |> Sub.flatMap(_, data =>
    switch data.accounts_by_pk {
    | Some(x') =>
      Sub.resolve(
        x'.redelegations_aggregate.aggregate
        |> Belt.Option.getExn
        |> (y => y.count)
        |> Belt.Option.getExn,
      )
    | None => Sub.resolve(0)
    }
  )
}
