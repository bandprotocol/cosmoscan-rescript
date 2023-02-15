module OracleRequestAcknowledge = {
  type t = {requestID: option<int>}

  let decode = json => {
    open JsonUtils.Decode
    json->mustDecode({
      object(json => {
        requestID: json.optional(. "request_id", int),
      })
    })
  }
}

module OracleResponseData = {
  type status_t =
    | Success
    | Fail
    | Unknown

  let getStatus = status => {
    switch status {
    | 1 => Success
    | 2 => Fail
    | _ => Unknown
    }
  }

  type t = {
    requestID: int,
    resolveStatus: status_t,
  }

  let decode = json => {
    open JsonUtils.Decode
    json->mustDecode({
      object(json => {
        requestID: json.required(. "request_id", int),
        resolveStatus: json.required(. "resolve_status", int)->getStatus,
      })
    })
  }
}

type packet_type_t =
  | OracleRequest
  | OracleResponse
  | FungibleToken
  | InterchainAccount
  | Unknown

type packet_direction_t =
  | Incoming
  | Outgoing

type acknowledge_data_t =
  | Request(OracleRequestAcknowledge.t)
  | Empty

type data_t =
  | Response(OracleResponseData.t)
  | Empty

type packet_status_t =
  | Pending
  | Success
  | Fail

type acknowledgement_t = {
  data: acknowledge_data_t,
  reason: option<string>,
  status: packet_status_t,
}

module PacketType = {
  type t = packet_type_t
  let parse = packetT => {
    switch packetT {
    | Some("oracle_request") => OracleRequest
    | Some("oracle response") => OracleResponse
    | Some("fungible_token") => FungibleToken
    | Some("interchain_account") => InterchainAccount
    | _ => Unknown
    }
  }
  // TODO: Impelement serialize
  let serialize = packetType => packetType->Js.Json.serializeExn
}

let getPacketTypeText = packetTypeText => {
  switch packetTypeText {
  | OracleRequest => "Oracle Request"
  | OracleResponse => "Oracle Response"
  | FungibleToken => "Fungible Token"
  | InterchainAccount => "Interchain Account"
  | Unknown => "Unknown"
  }
}

let getPacketStatus = packetStatus => {
  switch packetStatus {
  | "success" => Success
  | "pending" => Pending
  | "failure" => Fail
  | _ => raise(Not_found)
  }
}

type tx_t = {hash: Hash.t}

type connection_t = {counterPartyChainID: string}
type channel_t = {connection: connection_t}

type sequence_t = {_eq: int}

type t = {
  srcChannel: string,
  srcPort: string,
  dstChannel: string,
  dstPort: string,
  sequence: int,
  packetType: packet_type_t,
  acknowledgement: option<acknowledgement_t>,
  blockHeight: ID.Block.t,
  counterPartyChainID: string,
  txHash: option<Hash.t>,
  data: data_t,
}

type internal_t = {
  srcChannel: string,
  srcPort: string,
  dstChannel: string,
  dstPort: string,
  sequence: int,
  packetType: option<string>,
  acknowledgement: option<Js.Json.t>,
  dataOpt: option<Js.Json.t>,
  transaction: option<tx_t>,
  blockHeight: ID.Block.t,
  channel: option<channel_t>,
}

let toExternal = ({
  packetType,
  srcChannel,
  srcPort,
  dstChannel,
  sequence,
  dstPort,
  acknowledgement,
  dataOpt,
  transaction,
  blockHeight,
  channel,
}) => {
  dstPort,
  packetType: {
    packetType->PacketType.parse
  },
  srcChannel,
  srcPort,
  sequence,
  dstChannel,
  blockHeight,
  counterPartyChainID: {
    (channel->Belt.Option.getExn).connection.counterPartyChainID
  },
  acknowledgement: {
    switch acknowledgement {
    | None => None
    | Some(ackOpt) => {
        open JsonUtils.Decode
        Some(
          ackOpt->mustDecode({
            object(json => {
              data: switch packetType->PacketType.parse {
              | InterchainAccount
              | OracleRequest =>
                Request(ackOpt->OracleRequestAcknowledge.decode)
              | OracleResponse
              | FungibleToken
              | _ =>
                Empty
              },
              reason: json.optional(. "reason", string),
              status: json.required(. "status", string)->getPacketStatus,
            })
          }),
        )
      }
    }
  },
  txHash: {
    switch transaction {
    | None => None
    | Some(tx) => Some(tx.hash)
    }
  },
  data: {
    let packetParse = packetType->PacketType.parse
    switch (packetParse, dataOpt) {
    | (OracleResponse, Some(data)) => Response(OracleResponseData.decode(data))
    | _ => Empty
    }
  },
}

module IncomingPacketsConfig = %graphql(`
    query IncomingPackets($limit: Int!, $offset: Int! $packetType: String!, $packetTypeIsNull: Boolean!, $port: String!, $channel: String!, $chainID: String!, $sequence: Int_comparison_exp)  {
    incoming_packets(limit: $limit, offset: $offset, order_by: [{block_height: desc}], where: {type: {_is_null: $packetTypeIsNull, _ilike: $packetType}, sequence: $sequence, dst_port: {_ilike: $port}, dst_channel: {_ilike: $channel}, channel:{connection: {counterparty_chain: {chain_id: {_ilike: $chainID}}}}}) @ppxAs(type: "internal_t"){
        packetType: type
        srcPort: src_port
        srcChannel: src_channel
        sequence
        dstPort: dst_port
        dstChannel: dst_channel
        dataOpt: data
        acknowledgement
        transaction @ppxAs(type: "tx_t") {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
        }
        blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
        channel @ppxAs(type: "channel_t")  {
          connection @ppxAs(type: "connection_t") {
            counterPartyChainID: counterparty_chain_id
          }
        }
      }
    }
`)

module OutgoingPacketsConfig = %graphql(`
    query OutgoingPackets($limit: Int!, $offset: Int!, $packetType: String!, $packetTypeIsNull: Boolean!, $port: String!, $channel: String!, $chainID: String!, $sequence: Int_comparison_exp)  {
        outgoing_packets(limit: $limit, offset: $offset, order_by: [{block_height: desc}], where: {type: {_is_null: $packetTypeIsNull, _ilike: $packetType},sequence: $sequence,  dst_port: {_ilike: $port}, dst_channel: {_ilike: $channel}, channel:{connection: {counterparty_chain: {chain_id: {_ilike: $chainID}}}}}) @ppxAs(type: "internal_t"){
            packetType: type
            srcPort: src_port
            srcChannel: src_channel
            sequence
            dstPort: dst_port
            dstChannel: dst_channel
            dataOpt: data
            acknowledgement
            transaction @ppxAs(type: "tx_t") {
              hash @ppxCustom(module: "GraphQLParserModule.Hash")
            }
            blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
            channel @ppxAs(type: "channel_t")  {
              connection @ppxAs(type: "connection_t") {
                counterPartyChainID: counterparty_chain_id
              }
            }
        }
    }
`)

let getList = (
  ~page,
  ~pageSize,
  ~direction,
  ~packetType,
  ~port,
  ~channel,
  ~sequence: option<int>,
  ~chainID,
  (),
) => {
  let offset = (page - 1) * pageSize

  let packetTypeKeyword = {
    switch packetType {
    | "Oracle Request" => Some("oracle_request")
    | "Oracle Response" => Some("oracle response")
    | "Fungible Token" => Some("fungible_token")
    | "Interchain Account" => Some("interchain_account")
    | _ => None
    // | _ => raise(Not_found)
    }
  }
  let packetTypeIsNull = {
    switch packetType {
    | "Unknown" => Some(true)
    | _ => None
    }
  }

  let result = switch direction {
  | Incoming =>
    let data = IncomingPacketsConfig.use(
      {
        limit: pageSize,
        offset,
        packetType: {
          switch packetTypeKeyword {
          | Some("oracle_request") => "oracle_request"
          | Some("oracle response") => "oracle response"
          | Some("fungible_token") => "fungible_token"
          | Some("interchain_account") => "interchain_account"
          | _ => "%%"
          }
        },
        packetTypeIsNull: {
          switch packetTypeIsNull {
          | Some(true) => true
          | _ => false
          }
        },
        port: {
          port !== "" ? port : "%%"
        },
        channel: {
          channel !== "" ? channel : "%%"
        },
        chainID: {
          chainID !== "" ? chainID : "%%"
        },
        sequence: Some({
          _eq: sequence,
          _gt: None,
          _gte: None,
          _in: None,
          _is_null: None,
          _lt: None,
          _lte: None,
          _neq: None,
          _nin: None,
        }),
      },
      ~pollInterval=5000,
    )->Query.resolve

    // data
    // ->Query.fromData
    // ->Query.map(({incoming_packets}) => incoming_packets->Belt.Array.map(toExternal))

    switch data {
    | Data(x) =>
      switch x {
      | {data: Some({incoming_packets: _, _}), error: None, loading: true, _} => Query.NoData
      | {loading: false, error: None, data: Some({incoming_packets})} =>
        incoming_packets->Belt.Array.map(toExternal)->Query.resolve
      | {error: Some(_error)} => Error(_error)
      | _ => Query.NoData
      }
    | Error(_error) => Error(_error)
    | NoData => Query.NoData
    | Loading => Query.Loading
    }

  | Outgoing =>
    let data = OutgoingPacketsConfig.use(
      {
        limit: pageSize,
        offset,
        packetType: {
          switch packetTypeKeyword {
          | Some("oracle_request") => "oracle_request"
          | Some("oracle response") => "oracle response"
          | Some("fungible_token") => "fungible_token"
          | Some("interchain_account") => "interchain_account"
          | _ => "%%"
          }
        },
        packetTypeIsNull: {
          switch packetTypeIsNull {
          | Some(true) => true
          | _ => false
          }
        },
        port: {
          port !== "" ? port : "%%"
        },
        channel: {
          channel !== "" ? channel : "%%"
        },
        chainID: {
          chainID !== "" ? chainID : "%%"
        },
        sequence: Some({
          _eq: sequence,
          _gt: None,
          _gte: None,
          _in: None,
          _is_null: None,
          _lt: None,
          _lte: None,
          _neq: None,
          _nin: None,
        }),
      },
      ~pollInterval=5000,
    )->Query.resolve

    // data
    // ->Sub.fromData
    // ->Sub.flatMap(({outgoing_packets}) => {
    //   outgoing_packets->Belt.Array.map(toExternal)->Sub.resolve
    // })

    switch data {
    | Data(x) =>
      switch x {
      | {data: Some({outgoing_packets: _, _}), error: None, loading: true, _} => Query.NoData
      | {loading: false, error: None, data: Some({outgoing_packets})} =>
        outgoing_packets->Belt.Array.map(toExternal)->Query.resolve
      | {error: Some(_error)} => Error(_error)
      | _ => Query.NoData
      }
    | Error(_error) => Error(_error)
    | NoData => Query.NoData
    | Loading => Query.Loading
    }
  }

  result
}
