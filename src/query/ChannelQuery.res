module Channel = {
  type internal_t = {
    channel: string,
    counterpartyPort: string,
    counterpartyChannel: string,
    port: string,
    lastUpdate: MomentRe.Moment.t,
    // incomingPacketsCount: IBCSub.PacketsAggregate.internal_t,
    // outgoingPacketsCount: IBCSub.PacketsAggregate.internal_t,
  }

  type t = {
    channel: string,
    counterpartyPort: string,
    counterpartyChannel: string,
    port: string,
    lastUpdate: MomentRe.Moment.t,
    totalPackets: int,
  }

  let toExternal = (
    {
      channel,
      counterpartyPort,
      counterpartyChannel,
      port,
      lastUpdate,
      // incomingPacketsCount,
      // outgoingPacketsCount,
    }: internal_t,
  ) => {
    channel,
    counterpartyPort,
    counterpartyChannel,
    port,
    lastUpdate,
    // totalPackets: {
    // let incomingPackets =
    //   incomingPacketsCount.aggregate->Belt.Option.mapWithDefault(0, a => a.count)
    // let outgoingPackets =
    //   outgoingPacketsCount.aggregate->Belt.Option.mapWithDefault(0, a => a.count)
    // incomingPackets + outgoingPackets
    // },
    totalPackets: 0,
  }
}

module ChannelInfoConfig = %graphql(`
    query ChannelInfo ($port: String!, $channel: String!) {
        channels_by_pk (port: $port, channel: $channel) @ppxAs(type: "Channel.internal_t") {
            channel
            counterpartyPort: counterparty_port
            counterpartyChannel: counterparty_channel
            port
            lastUpdate: last_update @ppxCustom(module: "GraphQLParserModule.Date")
            # incomingPacketsCount: incoming_packets_aggregate @ppxAs(type: "IBCSub.PacketsAggregate.internal_t") {
            #   aggregate @ppxAs(type: "IBCSub.PacketsAggregate.aggregate_t") {
            #     count
            #   }
            # }
            # outgoingPacketsCount: outgoing_packets_aggregate @ppxAs(type: "IBCSub.PacketsAggregate.internal_t") {
            #     aggregate @ppxAs(type: "IBCSub.PacketsAggregate.aggregate_t"){
            #         count
            #     }
            # }
        }
    }
`)

let getChannelInfo = (~port, ~channel, ()) => {
  let result = ChannelInfoConfig.use({
    port,
    channel,
  })

  result
  ->Query.fromData
  ->Query.map(({channels_by_pk}) => {
    switch channels_by_pk {
    | Some(data) => Query.resolve(data->Channel.toExternal)
    | None => Query.NoData
    }
  })
}
