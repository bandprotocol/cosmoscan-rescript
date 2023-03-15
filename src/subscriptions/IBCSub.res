module PacketsAggregate = {
  type t = int
  type aggregate_t = {count: int}
  type internal_t = {aggregate: option<aggregate_t>}

  let toExternal = ({count}: aggregate_t) => count
}

module IncomingPacketsCountConfig = %graphql(`
    subscription IncomingPacketsCount ($port: String!, $channel: String!, $packetType: String!, $packetTypeIsNull: Boolean!) {
        incoming_packets_aggregate (where: { dst_port: { _eq: $port }, dst_channel: { _eq: $channel }, type: {_is_null: $packetTypeIsNull, _ilike: $packetType} } ) @ppxAs(type: "PacketsAggregate.internal_t") {
            aggregate @ppxAs(type: "PacketsAggregate.aggregate_t"){
                count
            }
        }
    }
`)

module OutgoingPacketsCountConfig = %graphql(`
    subscription OutgoingPacketsCount ($port: String!, $channel: String!, $packetType: String!, $packetTypeIsNull: Boolean!) {
        outgoing_packets_aggregate (where: { src_port: { _eq: $port }, src_channel: { _eq: $channel }, type: {_is_null: $packetTypeIsNull, _ilike: $packetType} } ) @ppxAs(type: "PacketsAggregate.internal_t") {
            aggregate @ppxAs(type: "PacketsAggregate.aggregate_t"){
                count
            }
        }
    }
`)

let incomingCount = (~port, ~channel, ~packetType, ()) => {
  let packetTypeIsNull = {
    switch packetType {
    | "Unknown" => Some(true)
    | _ => None
    }
  }

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

  let result = IncomingPacketsCountConfig.use({
    port,
    channel,
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
  })
  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.incoming_packets_aggregate.aggregate->Belt.Option.mapWithDefault(0, a => a.count)
  )
}

let outgoingCount = (~port, ~channel, ~packetType, ()) => {
  let packetTypeIsNull = {
    switch packetType {
    | "Unknown" => Some(true)
    | _ => None
    }
  }

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

  let result = OutgoingPacketsCountConfig.use({
    port,
    channel,
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
  })

  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.outgoing_packets_aggregate.aggregate->Belt.Option.mapWithDefault(0, a => a.count)
  )
}
