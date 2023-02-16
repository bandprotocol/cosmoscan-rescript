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

let searchOracleScript = (~filter, ()) => {
  let isNumber = switch filter->Belt.Int.fromString {
  | Some(_) => true
  | None => false
  }
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
      _ilike: None,
      _in: None,
      _iregex: None,
      _is_null: None,
      _like: Some(j`%$filter%`),
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

let searchDataSource = (~filter, ()) => {
  let isNumber = switch filter->Belt.Int.fromString {
  | Some(_) => true
  | None => false
  }
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
      _ilike: None,
      _in: None,
      _iregex: None,
      _is_null: None,
      _like: Some(j`%$filter%`),
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
