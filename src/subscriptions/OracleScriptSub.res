type data_source_t = {
  dataSourceID: ID.DataSource.t,
  dataSourceName: string,
};
type related_data_sources = {dataSource: data_source_t};
type block_t = {timestamp: MomentRe.Moment.t};
type transaction_t = {block: block_t};
type request_stat_t = {count: int};
type response_last_1_day_t = {
  id: option<ID.OracleScript.t>,
  responseTime: option<float>,
};

type response_last_1_day_external = {
  id: ID.OracleScript.t,
  responseTime: float,
};

type internal_t = {
  id: ID.OracleScript.t,
  owner: Address.t,
  name: string,
  description: string,
  schema: string,
  sourceCodeURL: string,
  transaction: option<transaction_t>,
  relatedDataSources: array<related_data_sources>,
  requestStat: option<request_stat_t>,
};

type t = {
  id: ID.OracleScript.t,
  owner: Address.t,
  name: string,
  description: string,
  schema: string,
  sourceCodeURL: string,
  timestamp: option<MomentRe.Moment.t>,
  relatedDataSources: list<data_source_t>,
  requestCount: int,
};

let toExternal =
    (
      {
        id,
        owner,
        name,
        description,
        schema,
        sourceCodeURL,
        transaction: txOpt,
        relatedDataSources,
        requestStat: requestStatOpt,
      },
    ) => {
  id,
  owner,
  name,
  description,
  schema,
  sourceCodeURL,
  timestamp: {
    let tx = txOpt->Belt.Option.getExn;
    Some(tx.block.timestamp);
  },
  relatedDataSources:
    relatedDataSources->Belt.Array.map(({dataSource}) => dataSource)->Belt.List.fromArray,
  // Note: requestCount can't be nullable value.
  requestCount: requestStatOpt->Belt.Option.map(({count}) => count)->Belt.Option.getExn,
};

module SingleConfig = %graphql(`
  subscription OracleScript($id: Int!) {
    oracle_scripts_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
      owner @ppxCustom(module: "GraphQLParserModule.Address")
      name
      description
      schema
      sourceCodeURL: source_code_url
      transaction @ppxAs(type: "transaction_t") {
        block @ppxAs(type: "block_t") {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      relatedDataSources: related_data_source_oracle_scripts @ppxAs(type: "related_data_sources") {
        dataSource: data_source @ppxAs(type: "data_source_t") {
          dataSourceID: id  @ppxCustom(module: "GraphQLParserModule.DataSourceID")
          dataSourceName: name
        }
      }
      requestStat: request_stat @ppxAs(type: "request_stat_t") {
        count
      }
    }
  },
`)

module MultiConfig = %graphql(`
  subscription OracleScripts($limit: Int!, $offset: Int!, $searchTerm: String!) {
    oracle_scripts(limit: $limit, offset: $offset,where: {name: {_ilike: $searchTerm}}, order_by: [{request_stat: {count: desc}, transaction: {block: {timestamp: desc}}, id: desc}]) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
      owner @ppxCustom(module: "GraphQLParserModule.Address")
      name
      description
      schema
      sourceCodeURL: source_code_url
      transaction @ppxAs(type: "transaction_t") {
        block @ppxAs(type: "block_t") {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      relatedDataSources: related_data_source_oracle_scripts @ppxAs(type: "related_data_sources") {
        dataSource: data_source @ppxAs(type: "data_source_t") {
          dataSourceID: id  @ppxCustom(module: "GraphQLParserModule.DataSourceID")
          dataSourceName: name
        }
      }
      requestStat: request_stat @ppxAs(type: "request_stat_t") {
        count
      }
    }
  }
`)

module OracleScriptsCountConfig = %graphql(`
  subscription OracleScriptsCount($searchTerm: String!) {
    oracle_scripts_aggregate(where: {name: {_ilike: $searchTerm}}){
      aggregate{
        count
      }
    }
  }
`)

module MultiOracleScriptStatLast1DayConfig = %graphql(`
  subscription MultiOracleScriptStatLast1DayConfig {
    oracle_script_statistic_last_1_day(where: {resolve_status: {_eq: "Success"}}) @ppxAs(type: "response_last_1_day_t") {
      id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
      responseTime: response_time @ppxCustom(module: "GraphQLParserModule.FloatString")
    }
  }
`)

module SingleOracleScriptStatLast1DayConfig = %graphql(`
  subscription SingleOracleScriptStatLast1DayConfig($id: Int!) {
    oracle_script_statistic_last_1_day(where: {resolve_status: {_eq: "Success"}, id: {_eq: $id}}) @ppxAs(type: "response_last_1_day_t") {
      id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
      responseTime: response_time @ppxCustom(module: "GraphQLParserModule.FloatString")
    }
  }
`)

let get = id => {
  let result = SingleConfig.use({id: id -> ID.OracleScript.toInt})

  result -> Sub.fromData
  -> Sub.flatMap(({oracle_scripts_by_pk}) => {
    switch oracle_scripts_by_pk {
    | Some(data) => Sub.resolve(data -> toExternal)
    | None => Sub.NoData
    }
  })
};

let getList = (~page, ~pageSize, ~searchTerm, ()) => {
  let offset = (page - 1) * pageSize;
  let keyword = {j`%$searchTerm%`};
  let result = MultiConfig.use({limit: pageSize, offset: offset, searchTerm:keyword})

  result
  -> Sub.fromData
  -> Sub.map(internal => internal.oracle_scripts->Belt_Array.map(toExternal));
};

let count = (~searchTerm, ()) => {
  let keyword = {j`%$searchTerm%`};
  let result = OracleScriptsCountConfig.use({searchTerm: keyword})

  result
  -> Sub.fromData
  -> Sub.map(x => x.oracle_scripts_aggregate.aggregate |> Belt.Option.getExn |> (y => y.count));
};

let getResponseTimeList = () => {
  let result = MultiOracleScriptStatLast1DayConfig.use()
  result
  -> Sub.fromData 
  -> Sub.map(
    internal => internal.oracle_script_statistic_last_1_day -> Belt.Array.map(
      (element) => {
        id: element.id -> Belt.Option.getExn,
        responseTime: element.responseTime -> Belt.Option.getExn
      }
    )
  )
};

let getResponseTime = id => {
  let result = SingleOracleScriptStatLast1DayConfig.use({id: id |> ID.OracleScript.toInt})

  result
  -> Sub.fromData 
  -> Sub.map(internal => internal.oracle_script_statistic_last_1_day -> Belt.Array.get(0));
};
