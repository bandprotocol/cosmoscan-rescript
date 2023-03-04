module Channel = {
  type t = {
    channel: string,
    counterpartyPort: string,
    counterpartyChannel: string,
    port: string,
  }
}
module ChannelInfoConfig = %graphql(`
    query ChannelInfo ($port: String!, $channel: String!) {
        channels_by_pk (port: $port, channel: $channel) @ppxAs(type: "Channel.t") {
            channel
            counterpartyPort: counterparty_port
            counterpartyChannel: counterparty_channel
            port
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
    channels_by_pk->Belt.Option.getExn
  })
}
