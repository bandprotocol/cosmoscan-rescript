type connection_info_t = {
  channel: string,
  chainID: string,
  imgSrc: string,
  name: string,
}

type target_chain_t =
  | BAND
  | IBC(connection_info_t)

module TransferConnectionsConfig = %graphql(`
    query TransferConnection {
        connections(where: {channels: {port: {_eq: "transfer"}}}, order_by: [{counterparty_chain_id: asc}]) {
        channels {
            channel
        }
        counterparty_chain_id
        }
    }
`)

let getList = () => {
  let result = TransferConnectionsConfig.use(~pollInterval=5000, ())

  result
  ->Query.fromData
  ->Query.map(({connections}) => {
    connections
    ->Belt.Array.map(connection => {
      let chainID = connection.counterparty_chain_id
      let channel = {
        let channelInner = connection.channels->Belt.Array.get(0)
        switch channelInner {
        | Some({channel}) => channel
        | None => ""
        }
      }

      let (imgSrc, name) = VerifiedChain.parse(chainID, channel)
      {chainID, channel, imgSrc, name}
    })
    ->Belt.List.fromArray
    ->Belt.List.sort((a, b) => compare(a.name, b.name))
    ->Belt.List.toArray
    ->Belt.Array.map(each => IBC(each))
  })
}
