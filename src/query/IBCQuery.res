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
  let parse = packetTOpt => {
    switch packetTOpt {
    | Some("oracle_request") => OracleRequest
    | Some("oracle response") => OracleResponse
    | Some("fungible_token") => FungibleToken
    | Some("interchain_account") => InterchainAccount
    | _ => Unknown
    }
  }
  let serialize = packetType => {
    switch packetType {
    | OracleRequest => Some("oracle_request")
    | OracleResponse => Some("oracle response")
    | FungibleToken => Some("fungible_token")
    | InterchainAccount => Some("interchain_account")
    | Unknown => None
    }
  }
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
type block_t = {timestamp: MomentRe.Moment.t}

type t = {
  srcChannel: string,
  srcPort: string,
  dstChannel: string,
  dstPort: string,
  sequence: int,
  packetType: packet_type_t,
  acknowledgement: option<acknowledgement_t>,
  blockHeight: ID.Block.t,
  // counterPartyChainID: string,
  txHash: option<Hash.t>,
  data: data_t,
  timestamp: MomentRe.Moment.t,
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
  block: block_t,
  // channel: option<channel_t>,
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
  block,
  // channel,
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
  // counterPartyChainID: {
  //   (channel->Belt.Option.getExn).connection.counterPartyChainID
  // },
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
  timestamp: block.timestamp,
}

module IncomingPacketsConfig = %graphql(`
    query IncomingPackets($limit: Int!, $offset: Int! $packetType: String!,  $port: String!, $channel: String!)  {
    incoming_packets(limit: $limit, offset: $offset, order_by: [{sequence: desc}], where: {type: { _ilike: $packetType},  dst_port: {_ilike: $port}, dst_channel: {_eq: $channel} }) @ppxAs(type: "internal_t"){
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
        block  @ppxAs(type: "block_t") {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
    }
`)

module OutgoingPacketsConfig = %graphql(`
    query OutgoingPackets($limit: Int!, $offset: Int!, $packetType: String!, $port: String!, $channel: String!)  {
        outgoing_packets(limit: $limit, offset: $offset, order_by: [{sequence: desc}], where: {type: { _ilike: $packetType}, src_port: {_eq: $port}, src_channel: {_eq: $channel} }) @ppxAs(type: "internal_t"){
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
            block  @ppxAs(type: "block_t")  {
              timestamp @ppxCustom(module: "GraphQLParserModule.Date")
            }
        }
    }
`)

let getList = (~page, ~pageSize, ~direction, ~packetType, ~port, ~channel, ~chainID, ()) => {
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
        // packetTypeIsNull: {
        //   switch packetTypeIsNull {
        //   | Some(true) => true
        //   | _ => false
        //   }
        // },
        port: {
          port !== "" ? port : "%%"
        },
        channel: {
          channel !== "" ? channel : "%%"
        },

        // chainID: {
        //   chainID !== "" ? chainID : "%%"
        // },
      },
      ~pollInterval=5000,
    )

    data
    ->Query.fromData
    ->Query.map(({incoming_packets}) => {
      incoming_packets->Belt.Array.map(toExternal)
    })

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
        // packetTypeIsNull: {
        //   switch packetTypeIsNull {
        //   | Some(true) => true
        //   | _ => false
        //   }
        // },
        port: {
          port !== "" ? port : "%%"
        },
        channel: {
          channel !== "" ? channel : "%%"
        },

        // chainID: {
        //   chainID !== "" ? chainID : "%%"
        // },
      },
      ~pollInterval=5000,
    )

    data
    ->Query.fromData
    ->Query.map(({outgoing_packets}) => {
      outgoing_packets->Belt.Array.map(toExternal)
    })
  }
  result
}
