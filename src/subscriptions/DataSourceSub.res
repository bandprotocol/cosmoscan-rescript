type sort_t =
  | ID
  | Name
  | Fee
  | TotalRequest

type block_t = {timestamp: MomentRe.Moment.t}
type transaction_t = {block: block_t}
type request_stat_t = {count: int}

type internal_t = {
  id: ID.DataSource.t,
  owner: Address.t,
  treasury: Address.t,
  name: string,
  description: string,
  executable: JsBuffer.t,
  fee: list<Coin.t>,
  accumulatedRevenue: string,
  transaction: option<transaction_t>,
  requestStat: option<request_stat_t>,
}

type t = {
  id: ID.DataSource.t,
  owner: Address.t,
  treasury: Address.t,
  name: string,
  description: string,
  executable: JsBuffer.t,
  fee: list<Coin.t>,
  accumulatedRevenue: list<Coin.t>,
  timestamp: option<MomentRe.Moment.t>,
  requestCount: int,
}

let toExternal = ({
  id,
  owner,
  treasury,
  name,
  description,
  executable,
  fee,
  accumulatedRevenue,
  transaction: txOpt,
  requestStat: requestStatOpt,
}) => {
  id,
  owner,
  treasury,
  name,
  description,
  executable,
  fee,
  accumulatedRevenue: list{
    accumulatedRevenue->Belt.Float.fromString->Belt.Option.getExn->Coin.newUBANDFromAmount,
  },
  timestamp: txOpt->Belt.Option.map(tx => tx.block.timestamp),
  requestCount: requestStatOpt->Belt.Option.mapWithDefault(0, ({count}) => count),
}

module SingleConfig = %graphql(`
  subscription DataSource($id: Int!) {
    data_sources_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
      owner @ppxCustom(module: "GraphQLParserModule.Address")
      treasury @ppxCustom(module: "GraphQLParserModule.Address")
      name
      description
      executable @ppxCustom(module: "GraphQLParserModule.Buffer")
      fee @ppxCustom(module: "GraphQLParserModule.Coins")
      accumulatedRevenue: accumulated_revenue @ppxCustom(module: "GraphQLParserModule.String")
      transaction @ppxAs(type:"transaction_t") {
        block @ppxAs(type:"block_t") {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      requestStat: request_stat @ppxAs(type: "request_stat_t") {
        count
      }
    }
  },
`)

module MultiConfig = %graphql(`
  subscription DataSources($limit: Int!, $offset: Int!, $searchTerm: String!, $searchID: Int, $orderBy: data_sources_order_by!) {
    data_sources(limit: $limit, offset: $offset, where: {_or: [
        {id: {_eq: $searchID }}
				{ name: { _ilike: $searchTerm } } ]
			}, order_by: [ $orderBy ]) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
      owner @ppxCustom(module: "GraphQLParserModule.Address")
      treasury @ppxCustom(module: "GraphQLParserModule.Address")
      name
      description
      executable @ppxCustom(module: "GraphQLParserModule.Buffer")
      fee @ppxCustom(module: "GraphQLParserModule.Coins")
      accumulatedRevenue: accumulated_revenue @ppxCustom(module: "GraphQLParserModule.String")
      transaction @ppxAs(type: "transaction_t") {
        block @ppxAs(type: "block_t") {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      requestStat: request_stat @ppxAs(type: "request_stat_t") {
        count
      }
    }
  },
`)

module DataSourcesCountConfig = %graphql(`
  subscription DataSourcesCount($searchTerm: String!) {
    data_sources_aggregate(where: {name: {_ilike: $searchTerm}}){
      aggregate{
        count
      }
    }
  }
`)

let get = id => {
  let result = SingleConfig.use({id: id->ID.DataSource.toInt})

  result
  ->Sub.fromData
  ->Sub.flatMap(({data_sources_by_pk}) => {
    switch data_sources_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~page, ~pageSize, ~searchTerm, ~sortDirection, ~sortBy, ()) => {
  let offset = (page - 1) * pageSize
  let keyword = {j`%$searchTerm%`}
  // let defaultSortBy = {transaction: {block: {timestamp: desc_nulls_last}}, id: desc}
  let defaultSortBy: MultiConfig.MultiConfig_inner.t_variables_data_sources_order_by = {
    id: None,
    accumulated_revenue: None,
    description: None,
    executable: None,
    fee: None,
    name: None,
    owner: None,
    raw_requests_aggregate: None,
    data_source_requests_per_days_aggregate: None,
    related_data_source_oracle_scripts_aggregate: None,
    last_request: None,
    request_stat: None,
    transaction: None,
    transaction_id: None,
    treasury: None,
    data_source_requests_per_days_aggregate: None,
    last_request: None
  }

  let requestStatSortBy: MultiConfig.MultiConfig_inner.t_variables_data_source_requests_order_by = {
    count: Some(#asc),
    data_source_id: None,
    data_source: None,
  }

  let orderBy: MultiConfig.MultiConfig_inner.t_variables_data_sources_order_by = {
    switch (sortBy, sortDirection) {
    | (ID, Sort.ASC) => {
        ...defaultSortBy,
        id: Some(#asc),
      }
    | (ID, DESC) => {
        ...defaultSortBy,
        id: Some(#desc),
      }
    | (Name, ASC) => {
        ...defaultSortBy,
        name: Some(#asc_nulls_last),
      }
    | (Name, DESC) => {
        ...defaultSortBy,
        name: Some(#desc_nulls_last),
      }

    | (Fee, ASC) => {
        ...defaultSortBy,
        fee: Some(#asc),
      }
    | (Fee, DESC) => {
        ...defaultSortBy,
        fee: Some(#desc),
      }
    | (TotalRequest, ASC) => {
        ...defaultSortBy,
        request_stat: Some(requestStatSortBy),
      }
    | (TotalRequest, DESC) => {
        ...defaultSortBy,
        request_stat: Some({
          ...requestStatSortBy,
          count: Some(#desc),
        }),
      }
    }
  }
  let result = MultiConfig.use({
    limit: pageSize,
    offset,
    searchTerm: keyword,
    orderBy,
    searchID: Some(searchTerm->Belt.Int.fromString->Belt.Option.getWithDefault(-1)),
  })

  result->Sub.fromData->Sub.map(internal => internal.data_sources->Belt.Array.map(toExternal))
}

let count = (~searchTerm, ()) => {
  let keyword = {j`%$searchTerm%`}
  let result = DataSourcesCountConfig.use({searchTerm: keyword})

  result
  ->Sub.fromData
  ->Sub.map(x => x.data_sources_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))
}

let parseSortString = sortOption => {
  switch sortOption {
  | ID => "Data Source ID"
  | Name => "Data Source Name"
  | TotalRequest => "Total Request" // TODO: will change to 24 hr requests
  | _ => ""
  }
}
