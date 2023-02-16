open ValidatorSub.Mini
open TxSub.Mini

type resolve_status_t =
  | Pending
  | Success
  | Failure
  | Expired
  | Unknown

module ResolveStatus = {
  let parse = json => {
    let status = json->Js.Json.decodeString->Belt.Option.getExn
    switch status {
    | "Open" => Pending
    | "Success" => Success
    | "Failure" => Failure
    | "Expired" => Expired
    | _ => Unknown
    }
  }
  // TODO: Impelement serialize
  let serialize = _ => "status"->Js.Json.string
}

module Mini = {
  type oracle_script_internal_t = {
    scriptID: ID.OracleScript.t,
    name: string,
    schema: string,
  }

  type aggregate_t = {count: int}
  type block_t = TxSub.Mini.block_t

  type aggregate_wrapper_intenal_t = {aggregate: option<aggregate_t>}
  type transactionOpt_t = TxSub.Mini.t

  type raw_request_t = {fee: Coin.t}
  type request_internal = {
    id: ID.Request.t,
    sender: option<Address.t>,
    clientID: string,
    requestTime: option<MomentRe.Moment.t>,
    resolveTime: option<MomentRe.Moment.t>,
    calldata: JsBuffer.t,
    oracleScript: oracle_script_internal_t,
    transactionOpt: option<TxSub.Mini.t>,
    reportsAggregate: aggregate_wrapper_intenal_t,
    minCount: int,
    resolveStatus: resolve_status_t,
    requestedValidatorsAggregate: aggregate_wrapper_intenal_t,
    result: option<JsBuffer.t>,
    rawDataRequests: array<raw_request_t>,
  }

  type raw_request_internal_t = {request: request_internal}

  type t = {
    id: ID.Request.t,
    sender: option<Address.t>,
    clientID: string,
    requestTime: option<MomentRe.Moment.t>,
    resolveTime: option<MomentRe.Moment.t>,
    calldata: JsBuffer.t,
    oracleScriptID: ID.OracleScript.t,
    oracleScriptName: string,
    txHash: option<Hash.t>,
    txTimestamp: option<MomentRe.Moment.t>,
    blockHeight: option<ID.Block.t>,
    reportsCount: int,
    minCount: int,
    askCount: int,
    resolveStatus: resolve_status_t,
    result: option<JsBuffer.t>,
    feeEarned: Coin.t,
  }

  module MultiMiniByDataSourceConfig = %graphql(`
      subscription RequestsMiniByDataSource($id: Int!, $limit: Int!, $offset: Int!) {
        rawDataRequests: raw_requests ( where: { data_source_id: { _eq: $id } } limit: $limit offset: $offset order_by: [{ request_id: desc }]) @ppxAs(type: "raw_request_internal_t"){
          request @ppxAs(type: "request_internal") {
            id @ppxCustom(module: "GraphQLParserModule.RequestID")
            clientID: client_id
            requestTime: request_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
            resolveTime: resolve_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
            sender @ppxCustom(module: "GraphQLParserModule.Address")
            calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
            oracleScript: oracle_script @ppxAs(type: "oracle_script_internal_t") {
              scriptID: id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
              name
              schema
            }
            transactionOpt: transaction  @ppxAs(type: "transactionOpt_t"){
              hash @ppxCustom(module: "GraphQLParserModule.Hash")
              blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
              block @ppxAs(type: "block_t") {
                timestamp @ppxCustom(module: "GraphQLParserModule.Date")
              }
              gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
            }
            reportsAggregate: reports_aggregate @ppxAs(type: "aggregate_wrapper_intenal_t") {
              aggregate @ppxAs(type: "aggregate_t") {
                count
              }
            }
            resolveStatus: resolve_status  @ppxCustom(module: "ResolveStatus")
            minCount: min_count
            requestedValidatorsAggregate: val_requests_aggregate @ppxAs(type: "aggregate_wrapper_intenal_t") {
              aggregate @ppxAs(type: "aggregate_t") {
                count
              }
            }
            result @ppxCustom(module: "GraphQLParserModule.Buffer")
            rawDataRequests: raw_requests(order_by: [{external_id: asc}]) @ppxAs(type: "raw_request_t") {
              fee @ppxCustom(module: "GraphQLParserModule.Coin")
            }
          }
        }
      }
`)

  module MultiMiniByOracleScriptConfig = %graphql(`
      subscription RequestsMiniByOracleScript($id: Int!, $limit: Int!, $offset: Int!) {
        requests(
          where: {oracle_script_id: {_eq: $id}}
          limit: $limit
          offset: $offset
          order_by: [{id: desc}]
        ) @ppxAs(type: "request_internal") {
          id @ppxCustom(module: "GraphQLParserModule.RequestID")
          clientID: client_id
          requestTime: request_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
          resolveTime: resolve_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
          sender @ppxCustom(module: "GraphQLParserModule.Address")
          calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
          oracleScript: oracle_script @ppxAs(type: "oracle_script_internal_t") {
            scriptID: id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
            name
            schema
          }
          transactionOpt: transaction @ppxAs(type: "transactionOpt_t") {
            hash @ppxCustom(module: "GraphQLParserModule.Hash")
            blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
            block @ppxAs(type: "block_t") {
              timestamp @ppxCustom(module: "GraphQLParserModule.Date")
            }
            gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
          }
          reportsAggregate: reports_aggregate @ppxAs(type: "aggregate_wrapper_intenal_t") {
            aggregate @ppxAs(type: "aggregate_t") {
              count
            }
          }
          resolveStatus: resolve_status  @ppxCustom(module: "ResolveStatus")
          minCount: min_count
          requestedValidatorsAggregate: val_requests_aggregate @ppxAs(type: "aggregate_wrapper_intenal_t") {
            aggregate @ppxAs(type: "aggregate_t") {
              count
            }
          }
          result @ppxCustom(module: "GraphQLParserModule.Buffer")
          rawDataRequests: raw_requests(order_by: [{external_id: asc}]) @ppxAs(type: "raw_request_t") {
            fee @ppxCustom(module: "GraphQLParserModule.Coin")
          }
        }
      }
`)

  module MultiMiniByTxHashConfig = %graphql(`
      subscription RequestsMiniByTxHashCon($tx_hash:bytea!) {
        requests(where: {transaction: {hash: {_eq: $tx_hash}}}) @ppxAs(type: "request_internal") {
          id @ppxCustom(module: "GraphQLParserModule.RequestID")
          clientID: client_id
          requestTime: request_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
          resolveTime: resolve_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
          sender @ppxCustom(module: "GraphQLParserModule.Address")
          calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
          oracleScript: oracle_script @ppxAs(type: "oracle_script_internal_t") {
            scriptID: id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
            name
            schema
          }
          transactionOpt: transaction @ppxAs(type: "transactionOpt_t") {
            hash @ppxCustom(module: "GraphQLParserModule.Hash")
            blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
            block @ppxAs(type: "block_t") {
              timestamp @ppxCustom(module: "GraphQLParserModule.Date")
            }
            gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
          }
          reportsAggregate: reports_aggregate @ppxAs(type: "aggregate_wrapper_intenal_t") {
            aggregate @ppxAs(type: "aggregate_t") {
              count
            }
          }
          resolveStatus: resolve_status  @ppxCustom(module: "ResolveStatus")
          minCount: min_count
          requestedValidatorsAggregate: val_requests_aggregate @ppxAs(type: "aggregate_wrapper_intenal_t") {
            aggregate @ppxAs(type: "aggregate_t") {
              count
            }
          }
          result @ppxCustom(module: "GraphQLParserModule.Buffer")
          rawDataRequests: raw_requests(order_by: [{external_id: asc}]) @ppxAs(type: "raw_request_t") {
            fee @ppxCustom(module: "GraphQLParserModule.Coin")
          }
        }
      }
`)

  let toExternal = ({
    id,
    sender,
    clientID,
    requestTime,
    resolveTime,
    calldata,
    oracleScript,
    transactionOpt,
    reportsAggregate,
    minCount,
    resolveStatus,
    requestedValidatorsAggregate,
    result,
    rawDataRequests,
  }) => {
    id,
    sender,
    clientID,
    requestTime,
    resolveTime,
    calldata,
    oracleScriptID: oracleScript.scriptID,
    oracleScriptName: oracleScript.name,
    txHash: transactionOpt->Belt.Option.map(({hash}) => hash),
    txTimestamp: transactionOpt->Belt.Option.map(({block}) => block.timestamp),
    blockHeight: transactionOpt->Belt.Option.map(({blockHeight}) => blockHeight),
    reportsCount: reportsAggregate.aggregate
    ->Belt.Option.map(({count}) => count)
    ->Belt.Option.getExn,
    minCount,
    askCount: requestedValidatorsAggregate.aggregate
    ->Belt.Option.map(({count}) => count)
    ->Belt.Option.getExn,
    resolveStatus,
    result,
    feeEarned: rawDataRequests
    ->Belt.Array.reduce(0., (a, {fee: {amount}}) => a +. amount)
    ->Coin.newUBANDFromAmount,
  }

  let getListByDataSource = (id, ~page, ~pageSize) => {
    let offset = (page - 1) * pageSize
    let result = MultiMiniByDataSourceConfig.use({
      id: id->ID.DataSource.toInt,
      limit: pageSize,
      offset,
    })

    result
    ->Sub.fromData
    ->Sub.map(x =>
      x.rawDataRequests->Belt.Array.mapWithIndex((_, each) => toExternal(each.request))
    )
  }

  let getListByOracleScript = (id, ~page, ~pageSize, ()) => {
    let offset = (page - 1) * pageSize
    let result = MultiMiniByOracleScriptConfig.use({
      id: id->ID.OracleScript.toInt,
      limit: pageSize,
      offset,
    })

    result->Sub.fromData->Sub.map(x => x.requests->Belt.Array.map(toExternal))
  }

  let getListByTxHash = (txHash: Hash.t) => {
    let hash = txHash->Hash.toHex->(x => "\\x" ++ x)->Js.Json.string
    let result = MultiMiniByTxHashConfig.use({tx_hash: hash})
    result->Sub.fromData->Sub.map(x => x.requests->Belt.Array.map(toExternal))
  }
}

module RequestCountByDataSourceConfig = %graphql(`
  subscription RequestsMiniCountByDataSource($id: Int!) {
    data_source_requests(where: {data_source_id: {_eq: $id}}) {
      count
    }
  }
`)

module RequestCountByOracleScriptConfig = %graphql(`
  subscription RequestsCountMiniByOracleScript($id: Int!) {
    oracle_script_requests(where: {oracle_script_id: {_eq: $id}}) {
      count
    }
  }
`)

type report_detail_t = {
  externalID: string,
  exitCode: string,
  data: JsBuffer.t,
}

type report_t = {
  transactionOpt: option<TxSub.Mini.t>,
  reportDetails: array<report_detail_t>,
  reportValidator: ValidatorSub.Mini.t,
}

type data_source_internal_t = {
  dataSourceID: ID.DataSource.t,
  name: string,
}

type oracle_script_internal_t = {
  oracleScriptID: ID.OracleScript.t,
  name: string,
  schema: string,
}

type raw_data_request_t = {
  externalID: string,
  fee: Coin.t,
  dataSource: data_source_internal_t,
  calldata: JsBuffer.t,
}

type requested_validator_internal_t = {validator: ValidatorSub.Mini.t}

type aggregate_t = {count: int}
type aggregate_wrapper_intenal_t = {aggregate: option<aggregate_t>}

type internal_t = {
  id: ID.Request.t,
  clientID: string,
  requestTime: option<MomentRe.Moment.t>,
  resolveTime: option<MomentRe.Moment.t>,
  oracleScript: oracle_script_internal_t,
  calldata: JsBuffer.t,
  isIBC: bool,
  reason: option<string>,
  prepareGas: int,
  executeGas: int,
  feeLimit: list<Coin.t>,
  feeUsed: list<Coin.t>,
  resolveHeight: option<int>,
  requestedValidators: array<requested_validator_internal_t>,
  minCount: int,
  resolveStatus: resolve_status_t,
  sender: option<Address.t>,
  transactionOpt: option<TxSub.Mini.t>,
  rawDataRequests: array<raw_data_request_t>,
  reports: array<report_t>,
  result: option<JsBuffer.t>,
}

type t = {
  id: ID.Request.t,
  clientID: string,
  requestTime: option<MomentRe.Moment.t>,
  resolveTime: option<MomentRe.Moment.t>,
  oracleScript: oracle_script_internal_t,
  calldata: JsBuffer.t,
  isIBC: bool,
  reason: option<string>,
  prepareGas: int,
  executeGas: int,
  feeLimit: list<Coin.t>,
  feeUsed: list<Coin.t>,
  resolveHeight: option<ID.Block.t>,
  requestedValidators: array<requested_validator_internal_t>,
  minCount: int,
  resolveStatus: resolve_status_t,
  requester: option<Address.t>,
  transactionOpt: option<TxSub.Mini.t>,
  rawDataRequests: array<raw_data_request_t>,
  reports: array<report_t>,
  result: option<JsBuffer.t>,
}

let toExternal = ({
  id,
  clientID,
  requestTime,
  resolveTime,
  oracleScript,
  calldata,
  isIBC,
  reason,
  prepareGas,
  executeGas,
  feeLimit,
  feeUsed,
  resolveHeight,
  requestedValidators,
  minCount,
  resolveStatus,
  sender,
  transactionOpt,
  rawDataRequests,
  reports,
  result,
}) => {
  id,
  clientID,
  requestTime,
  resolveTime,
  oracleScript,
  calldata,
  isIBC,
  reason,
  prepareGas,
  executeGas,
  feeLimit,
  feeUsed,
  resolveHeight: resolveHeight->Belt.Option.map(ID.Block.fromInt),
  requestedValidators,
  minCount,
  resolveStatus,
  requester: sender,
  transactionOpt,
  rawDataRequests,
  reports,
  result,
}

module SingleRequestConfig = %graphql(`
  subscription Request($id: Int!) {
    requests_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.RequestID")
      clientID: client_id
      requestTime: request_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
      resolveTime: resolve_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
      oracleScript: oracle_script @ppxAs(type: "oracle_script_internal_t") {
        oracleScriptID:id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
        name
        schema
      }
      calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
      isIBC: is_ibc
      reason
      prepareGas: prepare_gas
      executeGas: execute_gas
      feeLimit: fee_limit @ppxCustom(module: "GraphQLParserModule.Coins")
      feeUsed: total_fees @ppxCustom(module: "GraphQLParserModule.Coins")
      resolveHeight: resolve_height
      reports(order_by: [{validator_id: asc}]) @ppxAs(type: "report_t") {
        transactionOpt: transaction @ppxAs(type: "TxSub.Mini.t") {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
          block @ppxAs(type: "block_t") {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
          gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
        }
        reportDetails: raw_reports(order_by: [{external_id: asc}]) @ppxAs(type: "report_detail_t") {
          externalID: external_id @ppxCustom(module: "GraphQLParserModule.String")
          exitCode: exit_code @ppxCustom(module: "GraphQLParserModule.String")
          data @ppxCustom(module: "GraphQLParserModule.Buffer")
        }
        reportValidator: validator @ppxAs(type: "ValidatorSub.Mini.t") {
          consensusAddress: consensus_address
          operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
          moniker
          identity
        }
      }
      requestedValidators: val_requests(order_by: [{validator_id: asc}]) @ppxAs(type: "requested_validator_internal_t") {
        validator @ppxAs(type: "ValidatorSub.Mini.t") {
          consensusAddress: consensus_address
          operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
          moniker
          identity
        }
      }
      minCount: min_count
      resolveStatus: resolve_status  @ppxCustom(module: "ResolveStatus")
      sender @ppxCustom(module: "GraphQLParserModule.Address")
      transactionOpt: transaction @ppxAs(type: "TxSub.Mini.t") {
        hash @ppxCustom(module: "GraphQLParserModule.Hash")
        blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
        block @ppxAs(type: "block_t") {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
        gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
      }
      rawDataRequests: raw_requests(order_by: [{external_id: asc}]) @ppxAs(type: "raw_data_request_t") {
        externalID: external_id @ppxCustom(module: "GraphQLParserModule.String")
        fee @ppxCustom(module: "GraphQLParserModule.Coin")
        dataSource: data_source @ppxAs(type: "data_source_internal_t") {
          dataSourceID: id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
          name
        }
        calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
      }
      result @ppxCustom(module: "GraphQLParserModule.Buffer")
    }
  }
`)

module MultiRequestConfig = %graphql(`
    subscription Requests($limit: Int!, $offset: Int!) {
      requests(limit: $limit, offset: $offset, order_by: [{id: desc}]) @ppxAs(type: "internal_t") {
        id @ppxCustom(module: "GraphQLParserModule.RequestID")
        clientID: client_id
        requestTime: request_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
        resolveTime: resolve_time @ppxCustom(module: "GraphQLParserModule.FromUnixSecond")
        oracleScript: oracle_script @ppxAs(type: "oracle_script_internal_t") {
          oracleScriptID:id @ppxCustom(module: "GraphQLParserModule.OracleScriptID")
          name
          schema
        }
        calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
        isIBC: is_ibc
        reason
        prepareGas: prepare_gas
        executeGas: execute_gas
        feeLimit: fee_limit @ppxCustom(module: "GraphQLParserModule.Coins")
        feeUsed: total_fees @ppxCustom(module: "GraphQLParserModule.Coins")
        resolveHeight: resolve_height
        reports @ppxAs(type: "report_t") {
          transactionOpt: transaction @ppxAs(type: "TxSub.Mini.t") {
            hash @ppxCustom(module: "GraphQLParserModule.Hash")
            blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
            block @ppxAs(type: "block_t") {
              timestamp @ppxCustom(module: "GraphQLParserModule.Date")
            }
            gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
          }
          reportDetails: raw_reports(order_by: [{external_id: asc}]) @ppxAs(type: "report_detail_t") {
            externalID: external_id @ppxCustom(module: "GraphQLParserModule.String")
            exitCode: exit_code @ppxCustom(module: "GraphQLParserModule.String")
            data @ppxCustom(module: "GraphQLParserModule.Buffer")
          }
          reportValidator: validator @ppxAs(type: "ValidatorSub.Mini.t") {
            consensusAddress: consensus_address
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            moniker
            identity
          }
        }
        requestedValidators: val_requests @ppxAs(type: "requested_validator_internal_t") {
          validator @ppxAs(type: "ValidatorSub.Mini.t") {
            consensusAddress: consensus_address
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            moniker
            identity
          }
        }
        minCount: min_count
        resolveStatus: resolve_status  @ppxCustom(module: "ResolveStatus")
        sender @ppxCustom(module: "GraphQLParserModule.Address")
        transactionOpt: transaction @ppxAs(type: "TxSub.Mini.t") {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
          block @ppxAs(type: "block_t") {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
          gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
        }
        rawDataRequests: raw_requests(order_by: [{external_id: asc}]) @ppxAs(type: "raw_data_request_t") {
          externalID: external_id @ppxCustom(module: "GraphQLParserModule.String")
          fee @ppxCustom(module: "GraphQLParserModule.Coin")
          dataSource: data_source @ppxAs(type: "data_source_internal_t") {
            dataSourceID: id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
            name
          }
          calldata @ppxCustom(module: "GraphQLParserModule.Buffer")
        }
        result @ppxCustom(module: "GraphQLParserModule.Buffer")
      }
    }
`)

module RequestCountConfig = %graphql(`
  subscription RequestCount {
    requests_aggregate @ppxAs(type: "aggregate_wrapper_intenal_t"){
      aggregate @ppxAs(type: "aggregate_t") {
        count
      }
    }
  }
`)

let get = id => {
  let result = SingleRequestConfig.use({id: id->ID.Request.toInt})

  result
  ->Sub.fromData
  ->Sub.flatMap(({requests_by_pk}) => {
    switch requests_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~page, ~pageSize) => {
  let offset = (page - 1) * pageSize
  let result = MultiRequestConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.requests->Belt.Array.map(toExternal))
}

let count = () => {
  let result = RequestCountConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(x => x.requests_aggregate.aggregate->Belt.Option.getExn->(y => y.count))
}

let countByOracleScript = id => {
  let result = RequestCountByOracleScriptConfig.use({id: id->ID.OracleScript.toInt})

  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.oracle_script_requests->Belt.Array.get(0)->Belt.Option.mapWithDefault(0, y => y.count)
  )
}

let countByDataSource = id => {
  let result = RequestCountByDataSourceConfig.use({id: id->ID.DataSource.toInt})

  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.data_source_requests->Belt.Array.get(0)->Belt.Option.mapWithDefault(0, y => y.count)
  )
}
