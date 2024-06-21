module Channel = {
  type internal_t = {
    channel: string,
    counterpartyPort: string,
    counterpartyChannel: string,
    port: string,
    lastUpdate: MomentRe.Moment.t,
  }

  type t = {
    channel: string,
    counterpartyPort: string,
    counterpartyChannel: string,
    port: string,
    lastUpdate: MomentRe.Moment.t,
  }

  let toExternal = (
    {channel, counterpartyPort, counterpartyChannel, port, lastUpdate}: internal_t,
  ) => {
    channel,
    counterpartyPort,
    counterpartyChannel,
    port,
    lastUpdate,
  }
}

module ChannelInfoConfig = %graphql(`
    subscription ChannelInfo ($port: String!, $channel: String!) {
        channels_by_pk (port: $port, channel: $channel) @ppxAs(type: "Channel.internal_t") {
            channel
            counterpartyPort: counterparty_port
            counterpartyChannel: counterparty_channel
            port
            lastUpdate: last_update @ppxCustom(module: "GraphQLParserModule.Date")
        }
    }
`)

let getChannelInfo = (~port, ~channel, ()) => {
  let result = ChannelInfoConfig.use({
    port,
    channel,
  })

  result
  ->Sub.fromData
  ->Sub.map(({channels_by_pk}) => {
    switch channels_by_pk {
    | Some(data) => Sub.resolve(data->Channel.toExternal)
    | None => Sub.NoData
    }
  })
}
