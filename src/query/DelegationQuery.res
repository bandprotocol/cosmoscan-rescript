open DelegationSub

module StakeConfig = %graphql(`
  query Stake( $delegator_address: String!)  {
    delegations_view( order_by: [{amount: desc}], where: {delegator_address: {_eq: $delegator_address}}) @ppxAs(type: "Stake.internal_t")  {
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

let getStakeList = delegatorAddress => {
  let result = StakeConfig.use({
    delegator_address: delegatorAddress->Address.toBech32,
  })

  result
  ->Query.fromData
  ->Query.map(({delegations_view}) => delegations_view->Belt.Array.map(Stake.toExternal))
}
