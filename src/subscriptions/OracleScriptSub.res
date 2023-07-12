type data_source_t = {
  dataSourceID: ID.DataSource.t,
  dataSourceName: string,
}

type resolve_status_t =
  | Success
  | Failure
  | Unknown

type related_data_sources = {dataSource: data_source_t}
type block_t = {timestamp: MomentRe.Moment.t}
type transaction_t = {block: block_t}
type request_stat_t = {count: int}

type version_t =
  | Ok
  | Redeploy
  | Nothing

let parseVersion = version => {
  switch version {
  | Some(v) =>
    switch v {
    | 1 => Redeploy
    | 2 => Ok
    | _ => Nothing
    }
  | None => Nothing
  }
}

module ResolveStatus = {
  type t = resolve_status_t
  let parse = json => {
    exception NotFound(string)
    let statusOpt = json->Js.Json.decodeString
    switch statusOpt {
    | Some("Success") => Success
    | Some("Failure") => Failure
    | _ => raise(NotFound("The resolve status is not existing"))
    }
  }
  let serialize = status => {
    let str = switch status {
    | Success => "Success"
    | Failure => "Failure"
    | Unknown => "Unknown"
    }
    str->Js.Json.string
  }
}

type response_last_1_day_t = {
  id: option<ID.OracleScript.t>,
  responseTime: option<float>,
  resolveStatus: option<resolve_status_t>,
  count: option<string>,
}

type response_last_1_day_external = {
  id: ID.OracleScript.t,
  responseTime: float,
  resolveStatus: resolve_status_t,
  count: int,
}

module Version = {
  type t =
    | Ok
    | Redeploy
    | Nothing

  let parse = version => {
    switch version {
    | Some(v) =>
      switch v {
      | 1 => Redeploy
      | 2 => Ok
      | _ => Nothing
      }
    | None => Nothing
    }
  }
}

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
  version: option<int>,
}

type internal_with_stat_t = {
  id: ID.OracleScript.t,
  owner: Address.t,
  name: string,
  description: string,
  schema: string,
  sourceCodeURL: string,
  transaction: option<transaction_t>,
  relatedDataSources: array<related_data_sources>,
  requestStat: option<request_stat_t>,
  version: option<int>,
  stats: response_last_1_day_external,
}
type t = {
  id: ID.OracleScript.t,
  owner: Address.t,
  name: string,
  description: string,
  schema: string,
  sourceCodeURL: string,
  timestampOpt: option<MomentRe.Moment.t>,
  relatedDataSources: list<data_source_t>,
  requestCount: int,
  version: version_t,
}

type t_with_stats = {
  id: ID.OracleScript.t,
  owner: Address.t,
  name: string,
  description: string,
  schema: string,
  sourceCodeURL: string,
  timestamp: option<MomentRe.Moment.t>,
  relatedDataSources: list<data_source_t>,
  requestCount: int,
  version: version_t,
  stat: response_last_1_day_external,
}

type request_timestamp_by_os_t = {transaction: transaction_t}

let toExternal = (
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
    version,
  }: internal_t,
) => {
  id,
  owner,
  name,
  description,
  schema,
  sourceCodeURL,
  timestampOpt: txOpt->Belt.Option.map(({block: {timestamp}}) => timestamp),
  relatedDataSources: relatedDataSources
  ->Belt.Array.map(({dataSource}) => dataSource)
  ->Belt.List.fromArray,
  // Note: requestCount can't be nullable value.
  requestCount: requestStatOpt->Belt.Option.map(({count}) => count)->Belt.Option.getWithDefault(0),
  version: version->parseVersion,
}

let statToExternal = ({id, responseTime, resolveStatus, count}: response_last_1_day_t) => {
  id: id->Belt.Option.getExn,
  responseTime: responseTime->Belt.Option.getExn,
  resolveStatus: resolveStatus->Belt.Option.getWithDefault(Success),
  count: count->Belt.Option.getExn->Belt.Int.fromString->Belt.Option.getWithDefault(0),
}

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
      version
    }
  },
`)

module MultiConfig = %graphql(`
  subscription OracleScripts($searchTerm: String!, $searchID: Int ) {
    oracle_scripts(where: {_or: [
        {id: {_eq: $searchID }}
				{ name: { _ilike: $searchTerm } } 
				{
					related_data_source_oracle_scripts: {
						data_source: { name: { _ilike: $searchTerm } }
					}
				}]
			}, order_by: [{request_stat: {count: desc}, transaction: {block: {timestamp: desc}}, id: desc}]) @ppxAs(type: "internal_t") {
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
      version
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
    oracle_script_statistic_last_1_day @ppxAs(type: "response_last_1_day_t") {
      id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
      responseTime: response_time @ppxCustom(module: "GraphQLParserModule.FloatString")
      resolveStatus: resolve_status @ppxCustom(module: "ResolveStatus")
      count @ppxCustom(module: "GraphQLParserModule.String")
    }
  }
`)

module SingleOracleScriptStatLast1DayConfig = %graphql(`
  subscription SingleOracleScriptStatLast1DayConfig($id: Int!) {
    oracle_script_statistic_last_1_day(where: {resolve_status: {_eq: "Success"},  id: {_eq: $id}}) @ppxAs(type: "response_last_1_day_t") {
      id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
      responseTime: response_time @ppxCustom(module: "GraphQLParserModule.FloatString")
      resolveStatus: resolve_status @ppxCustom(module: "ResolveStatus")
      count @ppxCustom(module: "GraphQLParserModule.String")
    }
  }
`)

module OracleScriptsLastRequestTimestampConfig = %graphql(`
  subscription OracleScriptsLastRequestTimestampConfig($id: Int!) {
    requests(limit: 1, 	order_by: [{ id: desc }], where: { oracle_script_id: { _eq: $id } }) @ppxAs(type: "request_timestamp_by_os_t") {
      transaction @ppxAs(type: "transaction_t") {
        block @ppxAs(type: "block_t") {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
	  }
  }
`)

let get = id => {
  let result = SingleConfig.use({id: id->ID.OracleScript.toInt})

  result
  ->Sub.fromData
  ->Sub.flatMap(({oracle_scripts_by_pk}) => {
    switch oracle_scripts_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~page, ~pageSize, ~searchTerm, ~sortedBy, ()) => {
  let offset = (page - 1) * pageSize

  let lists = MultiConfig.use({
    searchTerm: {j`%$searchTerm%`},
    searchID: searchTerm->Js.String2.toLowerCase->Js.String2.startsWith("o")
      ? Some(
          searchTerm
          ->Js.String2.slice(~from=1, ~to_=searchTerm->Js.String2.length)
          ->Belt.Int.fromString
          ->Belt.Option.getWithDefault(-1),
        )
      : Some(searchTerm->Belt.Int.fromString->Belt.Option.getWithDefault(-1)),
  })
  let stats = MultiOracleScriptStatLast1DayConfig.use()

  let listsSub =
    lists
    ->Sub.fromData
    ->Sub.map(internal => {
      internal.oracle_scripts
      ->Belt.Array.map(toExternal)
      ->Belt.Array.map((t: t): t_with_stats => {
        let stat_arr =
          stats
          ->Sub.fromData
          ->Sub.map(
            internal_stat =>
              internal_stat.oracle_script_statistic_last_1_day
              ->Belt.Array.keep(
                s => {
                  switch s.id {
                  | Some(id) => id == t.id
                  | None => false
                  }
                },
              )
              ->Belt.Array.map(statToExternal),
          )

        let s_result: response_last_1_day_external = switch stat_arr {
        | Data(os_inner) =>
          os_inner
          ->Belt.Array.keep(r => r.id == t.id)
          ->Belt.Array.reduce(
            {
              id: t.id,
              responseTime: 0.0,
              resolveStatus: Unknown,
              count: 0,
            },
            (acc, {responseTime, resolveStatus, count}) => {
              {
                id: t.id,
                // responseTime: (acc.responseTime +. responseTime),
                responseTime: os_inner
                ->Belt.Array.keep(r => r.id == t.id && r.resolveStatus == Success)
                ->Belt.Array.get(0)
                ->Belt.Option.map(r => r.responseTime)
                ->Belt.Option.getWithDefault(0.),
                resolveStatus,
                count: acc.count + count,
              }
            },
          )

        | _ => {
            id: t.id,
            responseTime: 0.0,
            resolveStatus: Unknown,
            count: 0,
          }
        }

        {
          id: t.id,
          owner: t.owner,
          name: t.name,
          description: t.description,
          schema: t.schema,
          sourceCodeURL: t.sourceCodeURL,
          timestamp: t.timestamp,
          relatedDataSources: t.relatedDataSources,
          requestCount: t.requestCount,
          version: t.version,
          stat: s_result,
        }
      })
    })

  listsSub
}

let count = (~searchTerm, ()) => {
  let keyword = {j`%$searchTerm%`}
  let result = OracleScriptsCountConfig.use({searchTerm: keyword})

  result
  ->Sub.fromData
  ->Sub.map(x => x.oracle_scripts_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))
}

let getResponseTimeList = () => {
  let result = MultiOracleScriptStatLast1DayConfig.use()
  result
  ->Sub.fromData
  ->Sub.map(internal =>
    internal.oracle_script_statistic_last_1_day->Belt.Array.map(element => statToExternal(element))
  )
}

let getResponseTime = id => {
  let result = SingleOracleScriptStatLast1DayConfig.use({id: id->ID.OracleScript.toInt})

  result
  ->Sub.fromData
  ->Sub.map(internal => internal.oracle_script_statistic_last_1_day->Belt.Array.get(0))
}

let getLatestRequestTimestampByID = id => {
  let result = OracleScriptsLastRequestTimestampConfig.use({
    id: id->ID.OracleScript.toInt,
  })

  result
  ->Sub.fromData
  ->Sub.map(internal => {
    internal.requests->Belt.Array.get(0)
  })
}
