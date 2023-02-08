type aggregate_t = {count: int}

module ReportersByValidatorAddressConfig = %graphql(`
    subscription ReportersConfig($operator_address: String!, $limit: Int!, $offset: Int!) {
    reporters(where: {operator_address: {_eq: $operator_address}}, offset: $offset, limit: $limit, order_by: [{reporter_id: asc}]) {
      account {
        address
      }
    }
  }
`)

module ReportersCountConfig = %graphql(`
    subscription ReporterCount($operator_address: String!) {
      reporters_aggregate(where: {operator_address: {_eq: $operator_address}}) {
        aggregate @ppxAs(type: "aggregate_t") {
          count 
        }
      }
    }
`)

let getList = (~operatorAddress, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize

  let result = ReportersByValidatorAddressConfig.use({
    operator_address: operatorAddress->Address.toOperatorBech32,
    limit: pageSize,
    offset,
  })

  result
  ->Sub.fromData
  ->Sub.map(({reporters}) =>
    reporters->Belt.Array.map(each => each.account.address->Address.fromBech32)
  )
}

let count = operatorAddress => {
  let result = ReportersCountConfig.use({
    operator_address: operatorAddress->Address.toOperatorBech32,
  })

  result
  ->Sub.fromData
  ->Sub.map(x => x.reporters_aggregate.aggregate->Belt.Option.getExn->(({count}) => count))
}
