module ValidatorReport = {
  type oracle_script_t = {
    oracleScriptID: ID.OracleScript.t,
    name: string,
  }

  type request_t = {
    id: ID.Request.t,
    oracleScript: oracle_script_t,
  }

  type data_source_t = {
    dataSourceID: ID.DataSource.t,
    dataSourceName: string,
  }

  type raw_request_t = {
    calldata: JsBuffer.t,
    dataSource: data_source_t,
  }

  type report_details_t = {
    externalID: string,
    exitCode: string,
    data: JsBuffer.t,
    rawRequest: option<raw_request_t>,
  }

  type transaction_t = {hash: Hash.t}

  type internal_t = {
    request: request_t,
    transaction: option<transaction_t>,
    reportDetails: array<report_details_t>,
  }

  type t = {
    txHash: option<Hash.t>,
    request: request_t,
    reportDetails: array<report_details_t>,
  }

  let toExternal = ({request, transaction, reportDetails}) => {
    txHash: transaction->Belt.Option.map(({hash}) => hash),
    request,
    reportDetails,
  }

  module MultiConfig = %graphql(`
    subscription Reports ($limit: Int!, $offset: Int!, $validator: String!) {
        validators_by_pk(operator_address: $validator) {
          reports (limit: $limit, offset: $offset, order_by: [{request_id: desc}]) @ppxAs(type: "internal_t") {
              request @ppxAs(type: "request_t") {
                id @ppxCustom(module: "GraphQLParserModule.RequestID")
                oracleScript: oracle_script @ppxAs(type: "oracle_script_t" ) {
                  oracleScriptID: id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
                  name
                }
              }
              transaction @ppxAs(type: "transaction_t") {
                hash @ppxCustom (module: "GraphQLParserModule.Hash")
              }
              reportDetails: raw_reports @ppxAs(type: "report_details_t") {
                externalID: external_id @ppxCustom(module: "GraphQLParserModule.String")
                exitCode: exit_code  @ppxCustom ( module: "GraphQLParserModule.String")
                data @ppxCustom ( module:  "GraphQLParserModule.Buffer")
                rawRequest: raw_request @ppxAs(type: "raw_request_t") {
                    calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
                    dataSource: data_source @ppxAs(type: "data_source_t") {
                    dataSourceID: id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
                    dataSourceName: name
                  }
                }
              }
            }
          }
        }
  `)

  module ReportCountConfig = %graphql(`
    subscription ReportsCount ($validator: String!) {
      validators_by_pk(operator_address: $validator) {
        validator_report_count {
          count
        }
      }
    }
`)

  let getListByValidator = (~page=1, ~pageSize=5, ~validator) => {
    let offset = (page - 1) * pageSize

    let result = MultiConfig.use({limit: pageSize, offset, validator})

    result
    ->Sub.fromData
    ->Sub.flatMap(({validators_by_pk}) => {
      switch validators_by_pk {
      | Some(data) => Sub.resolve(data.reports->Belt_Array.map(toExternal))
      | None => []->Sub.resolve
      }
    })
  }

  let count = validator => {
    let result = ReportCountConfig.use({
      validator: validator->Address.toOperatorBech32,
    })

    result
    ->Sub.fromData
    ->Sub.flatMap(({validators_by_pk}) => {
      switch validators_by_pk {
      | Some(data) =>
        Sub.resolve(
          data.validator_report_count
          ->Belt.Option.flatMap(({count}) => count)
          ->Belt.Option.getWithDefault(_, 0),
        )
      | None => Sub.resolve(0)
      }
    })
  }
}
