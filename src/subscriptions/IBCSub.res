module PacketsAggregate = {
  type t = int
  type aggregate_t = {count: int}
  type internal_t = {aggregate: option<aggregate_t>}

  let toExternal = ({count}: aggregate_t) => count
}

module IncomingPacketsCountConfig = %graphql(`
    subscription IncomingPacketsCount {
        incoming_packets_aggregate @ppxAs(type: "PacketsAggregate.internal_t") {
            aggregate @ppxAs(type: "PacketsAggregate.aggregate_t"){
                count
            }
        }
    }
`)

module OutgoingPacketsCountConfig = %graphql(`
    subscription OutgoingPacketsCount {
        outgoing_packets_aggregate @ppxAs(type: "PacketsAggregate.internal_t") {
            aggregate @ppxAs(type: "PacketsAggregate.aggregate_t"){
                count
            }
        }
    }
`)

let count = () => {
  let incomingPacketsSub = IncomingPacketsCountConfig.use()
  let outgoingPacketsSub = OutgoingPacketsCountConfig.use()

  let totalIncoming = {
    switch incomingPacketsSub.data {
    | Some({incoming_packets_aggregate: {aggregate: Some({count})}}) => count
    | _ => 0
    }
  }

  let totalOutgoing = {
    switch outgoingPacketsSub.data {
    | Some({outgoing_packets_aggregate: {aggregate: Some({count})}}) => count
    | _ => 0
    }
  }
  let total = totalIncoming + totalOutgoing
  total
}

let incomingCount = () => {
  let result = IncomingPacketsCountConfig.use()
  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.incoming_packets_aggregate.aggregate->Belt.Option.mapWithDefault(0, a => a.count)
  )
}

let outgoingCount = () => {
  let result = OutgoingPacketsCountConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.outgoing_packets_aggregate.aggregate->Belt.Option.mapWithDefault(0, a => a.count)
  )
}
