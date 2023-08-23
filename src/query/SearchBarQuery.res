module BlockSearch = {
  type t = {height: ID.Block.t}
}
module SearchBlockConfig = %graphql(`
    query SearchBlockID( $height: Int!)   {
        blocks_by_pk (height: $height) @ppxAs(type: "BlockSearch.t")  {
            height @ppxCustom(module: "GraphQLParserModule.BlockID")
        }
    }
`)

module RequestSearch = {
  type t = {id: ID.Request.t}
}

module SearchRequestConfig = %graphql(`
    query SearchRequestID( $id: Int!)   {
        requests_by_pk (id: $id) @ppxAs(type: "RequestSearch.t")  {
            id @ppxCustom(module: "GraphQLParserModule.RequestID")
        }
    }
`)

module OracleScriptSearch = {
  type t = {
    id: ID.OracleScript.t,
    name: string,
  }
}

module OracleScriptSearchConfig = %graphql(`
    query SearchOracleScriptID( $id: Int_comparison_exp, $name: String_comparison_exp) {
        oracle_scripts (where: { _and: [{ id: $id }, { name: $name}] }
	) @ppxAs(type: "OracleScriptSearch.t") {
            id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
            name
        }
    }

`)

module DataSourceSearch = {
  type t = {
    id: ID.DataSource.t,
    name: string,
  }
}

module DataSourceSearchConfig = %graphql(`
    query SearchDataSourceID( $id: Int_comparison_exp, $name: String_comparison_exp) {
        data_sources (where: { _and: [{ id: $id }, { name: $name}] }
	) @ppxAs(type: "DataSourceSearch.t") {
            id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
            name
        }
    }

`)

module DataSourceSearchSingleConfig = %graphql(`
  query DataSourceSearchSingle( $id: Int!) {
    data_sources_by_pk(id: $id) @ppxAs(type: "DataSourceSearch.t") {
      id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
      name
    }
  }
`)

module OracleScriptSearchSingleConfig = %graphql(`
  query OracleScriptSearchSingle( $id: Int!) {
    oracle_scripts_by_pk(id: $id) @ppxAs(type: "OracleScriptSearch.t") {
      id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
      name
    }
  }
`)

module ProposalSearch = {
  type t = {
    id: ID.Proposal.t,
    title: string,
  }
}

module ProposalSearchConfig = %graphql(`
    query SearchProposalID( $id: Int_comparison_exp, $title: String_comparison_exp) {
        proposals (where: { _and: [{ id: $id }, { title: $title}] }
	) @ppxAs(type: "ProposalSearch.t") {
            id @ppxCustom(module: "GraphQLParserModule.ProposalID")
            title
        }
    }

`)

module ValidatorSearch = {
  type t = {
    operatorAddress: Address.t,
    moniker: string,
    identity: string,
  }
}

module ValidatorSearchByAddressConfig = %graphql(`
    query SearchValidator( $operator_address: String!) {
       validators_by_pk(operator_address: $operator_address) @ppxAs(type: "ValidatorSearch.t") {
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            moniker
            identity
        }
    }
`)

module ValidatorSearchByMonikerConfig = %graphql(`
    query SearchValidator( $filter: String!) {
       validators(where: { moniker: { _ilike: $filter}}) @ppxAs(type: "ValidatorSearch.t") {
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            moniker
            identity
        }
    }
`)

let searchOracleScript = (~filter, ()) => {
  let result = OracleScriptSearchConfig.use({
    id: Some({
      _eq: filter->Belt.Int.fromString,
      _gt: None,
      _gte: None,
      _in: None,
      _is_null: None,
      _lt: None,
      _lte: None,
      _neq: None,
      _nin: None,
    }),
    name: Some({
      _regex: None,
      _eq: None,
      _gt: None,
      _gte: None,
      _in: None,
      _iregex: None,
      _is_null: None,
      _like: None,
      _ilike: Some(j`%$filter%`),
      _lt: None,
      _lte: None,
      _neq: None,
      _nilike: None,
      _nin: None,
      _niregex: None,
      _nlike: None,
      _nregex: None,
      _nsimilar: None,
      _similar: None,
    }),
  })

  result
  ->Query.fromData
  ->Query.map(({oracle_scripts}) => {
    switch oracle_scripts->Belt.Array.length > 0 {
    | true => oracle_scripts
    | false => []
    }
  })
}

let searchBlockID = (~id, ()) => {
  let parseID = {
    switch id->Belt.Int.fromString {
    | Some(id) => id
    | None => 0
    }
  }

  let result = SearchBlockConfig.use({height: parseID})
  result
  ->Query.fromData
  ->Query.map(({blocks_by_pk}) => {
    switch blocks_by_pk {
    | Some(block) => [block]
    | None => []
    }
  })
}

let searchRequestID = (~id, ()) => {
  let parseID = {
    switch id->Belt.Int.fromString {
    | Some(id) => id
    | None => 0
    }
  }

  let result = SearchRequestConfig.use({id: parseID})
  result
  ->Query.fromData
  ->Query.map(({requests_by_pk}) => {
    switch requests_by_pk {
    | Some(request) => [request]
    | None => []
    }
  })
}

let searchDataSource = (~filter, ()) => {
  let result = DataSourceSearchConfig.use({
    id: Some({
      _eq: filter->Belt.Int.fromString,
      _gt: None,
      _gte: None,
      _in: None,
      _is_null: None,
      _lt: None,
      _lte: None,
      _neq: None,
      _nin: None,
    }),
    name: Some({
      _regex: None,
      _eq: None,
      _gt: None,
      _gte: None,
      _in: None,
      _iregex: None,
      _is_null: None,
      _like: None,
      _ilike: Some(j`%$filter%`),
      _lt: None,
      _lte: None,
      _neq: None,
      _nilike: None,
      _nin: None,
      _niregex: None,
      _nlike: None,
      _nregex: None,
      _nsimilar: None,
      _similar: None,
    }),
  })

  result
  ->Query.fromData
  ->Query.map(({data_sources}) => {
    switch data_sources->Belt.Array.length > 0 {
    | true => data_sources
    | false => []
    }
  })
}

let searchProposal = (~filter, ()) => {
  let result = ProposalSearchConfig.use({
    id: Some({
      _eq: filter->Belt.Int.fromString,
      _gt: None,
      _gte: None,
      _in: None,
      _is_null: None,
      _lt: None,
      _lte: None,
      _neq: None,
      _nin: None,
    }),
    title: Some({
      _regex: None,
      _eq: None,
      _gt: None,
      _gte: None,
      _in: None,
      _iregex: None,
      _is_null: None,
      _like: None,
      _ilike: Some(j`%$filter%`),
      _lt: None,
      _lte: None,
      _neq: None,
      _nilike: None,
      _nin: None,
      _niregex: None,
      _nlike: None,
      _nregex: None,
      _nsimilar: None,
      _similar: None,
    }),
  })

  result
  ->Query.fromData
  ->Query.map(({proposals}) => {
    switch proposals->Belt.Array.length > 0 {
    | true => proposals
    | false => []
    }
  })
}

let getValidatorMoniker = (~address, ()) => {
  let result = ValidatorSearchByAddressConfig.use({
    operator_address: address->Address.toOperatorBech32,
  })
  result
  ->Query.fromData
  ->Query.map(({validators_by_pk}) => {
    validators_by_pk
  })
}

let searchValidatorByMoniker = (~filter, ()) => {
  let result = ValidatorSearchByMonikerConfig.use({
    filter: `%${filter}%`,
  })

  result
  ->Query.fromData
  ->Query.map(({validators}) => {
    switch validators->Belt.Array.length > 0 {
    | true => validators
    | false => []
    }
  })
}

let getDataSourceName = (~id, ()) => {
  let result = DataSourceSearchSingleConfig.use({
    id: id,
  })
  result
  ->Query.fromData
  ->Query.map(({data_sources_by_pk}) => {
    switch data_sources_by_pk {
    | Some(dataSource) => Query.resolve(dataSource)
    | None => Query.NoData
    }
  })
}

let getOracleScriptName = (~id, ()) => {
  let result = OracleScriptSearchSingleConfig.use({
    id: id,
  })
  result
  ->Query.fromData
  ->Query.map(({oracle_scripts_by_pk}) => {
    switch oracle_scripts_by_pk {
    | Some(os) => Query.resolve(os)
    | None => Query.NoData
    }
  })
}
