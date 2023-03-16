type filter_channel_t = {
  port: string,
  channel: string,
}

type filter_connection_t = {channels: array<filter_channel_t>}

type filter_counterparty_t = {
  chainID: string,
  connections: array<filter_connection_t>,
}

module CounterpartyConfig = %graphql(`
  subscription Counterparty($chainID: String!) {
    counterparty_chains(where :{chain_id: {_ilike: $chainID}}) {
      chainID: chain_id
      connections {
        channels {
          channel
          port
        }
      }
    }
  }
`)

let getChainFilterList = () => {
  let result = CounterpartyConfig.use({chainID: "%%"})

  result
  ->Sub.fromData
  ->Sub.flatMap(internal => {
    let chainIDList = internal.counterparty_chains
    let chainIDArray = chainIDList->Belt.Array.map(({chainID, connections}) => {
      let connectionArray = connections->Belt.Array.map(
        ({channels}) => {
          let channelArray = channels->Belt.Array.map(
            ({port, channel}) => {
              {port, channel}
            },
          )
          {channels: channelArray}
        },
      )
      {chainID, connections: connectionArray}
    })
    Sub.resolve(chainIDArray)
  })
}

let getFilterList = (~chainID, ()) => {
  let result = CounterpartyConfig.use({chainID: chainID !== "" ? chainID : "%%"})
  result
  ->Sub.fromData
  ->Sub.map(internal => {
    let portDict = Js.Dict.empty()
    let chainIDList = internal.counterparty_chains

    let connectionsList = chainIDList->Belt.Array.reduce([], (acc, {connections}) => {
      acc->Belt.Array.concat(connections)
    })

    let channelsList = connectionsList->Belt.Array.reduce([], (acc, {channels}) => {
      acc->Belt.Array.concat(channels)
    })

    let keys = ["oracle", "transfer", "icahost"]

    keys->Belt_Array.forEach(key => {
      let channelArray: array<string> =
        channelsList->Belt.Array.reduce(
          [],
          (acc, {port, channel}) => port === key ? acc->Belt.Array.concat([channel]) : acc,
        )
      portDict->Js.Dict.set(key, channelArray)
    })

    portDict
  })
}
