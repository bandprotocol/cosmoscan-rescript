type filter_channel_t = {
  port: string,
  channel: string,
  lastUpdate: MomentRe.Moment.t,
}

type filter_connection_t = {channels: array<filter_channel_t>}

type filter_counterparty_t = {
  chainID: string,
  connections: array<filter_connection_t>,
}

module CounterpartyConfig = %graphql(`
  subscription Counterparty( $lastUpdate: timestamp_comparison_exp) {
    counterparty_chains {
      chainID: chain_id
      connections (where: { channels: { last_update: $lastUpdate } }){
        channels {
          channel
          port
          lastUpdate: last_update @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
    }
  }
`)

let getChainFilterList = (~lastUpdate, ()) => {
  let parseState = lastUpdate ? Some(Js.Json.string("1970-01-01T00:00:00")) : None
  let result = CounterpartyConfig.use({
    lastUpdate: Some({
      _gt: parseState,
      _eq: None,
      _gte: None,
      _in: None,
      _is_null: None,
      _lt: None,
      _lte: None,
      _neq: None,
      _nin: None,
    }),
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(internal => {
    let chainIDList = internal.counterparty_chains
    let chainIDArray =
      chainIDList
      ->Belt.Array.map(({chainID, connections}) => {
        let connectionArray = connections->Belt.Array.map(
          ({channels}) => {
            let channelArray = channels->Belt.Array.map(
              ({port, channel, lastUpdate}) => {
                {port, channel, lastUpdate}
              },
            )
            {channels: channelArray}
          },
        )
        {chainID, connections: connectionArray}
      })
      ->Belt.List.fromArray
      ->Belt.List.sort((a, b) => {
        a.chainID < b.chainID ? -1 : 1
      })
      ->Belt.List.keep(({chainID, connections}) => connections->Belt.Array.length > 0)
      ->Belt.List.toArray
    Sub.resolve(chainIDArray)
  })
}

// let getFilterList = () => {
//   let result = CounterpartyConfig.use(

//   )
//   result
//   ->Sub.fromData
//   ->Sub.map(internal => {
//     let portDict = Js.Dict.empty()
//     let chainIDList = internal.counterparty_chains

//     let connectionsList = chainIDList->Belt.Array.reduce([], (acc, {connections}) => {
//       acc->Belt.Array.concat(connections)
//     })

//     let channelsList = connectionsList->Belt.Array.reduce([], (acc, {channels}) => {
//       acc->Belt.Array.concat(channels)
//     })

//     let keys = ["oracle", "transfer", "icahost"]

//     keys->Belt_Array.forEach(key => {
//       let channelArray: array<string> =
//         channelsList->Belt.Array.reduce(
//           [],
//           (acc, {port, channel}) => port === key ? acc->Belt.Array.concat([channel]) : acc,
//         )
//       portDict->Js.Dict.set(key, channelArray)
//     })

//     portDict
//   })
// }
