type filter_channel_t = {
  port: string,
  channel: string,
  state: int,
}

type filter_connection_t = {channels: array<filter_channel_t>}

type filter_counterparty_t = {
  chainID: string,
  connections: array<filter_connection_t>,
  activeChannel: int,
}

module CounterpartyConfig = %graphql(`
  subscription Counterparty( $state: Int_comparison_exp, $search: String!, $searchChannel: String_comparison_exp ) {
    counterparty_chains (
		where: { _or: [
      {connections: { channels: { channel: $searchChannel } }},
      {
        chain_id: {
          _ilike: $search
        }
      }
    ] }
	){
      chainID: chain_id
      connections (where: { channels: { state: $state } }){
        channels {
          channel
          port
          state
        }
      }
    }
  }
`)

let getChainFilterList = (~state, ~search, ()) => {
  let parseState = state ? Some(3) : None
  let result = CounterpartyConfig.use({
    state: Some({
      _gt: None,
      _eq: parseState,
      _gte: None,
      _in: None,
      _is_null: None,
      _lt: None,
      _lte: None,
      _neq: None,
      _nin: None,
    }),
    searchChannel: Some({
      _regex: None,
      _eq: search == "" ? None : Some(search),
      _gt: None,
      _gte: None,
      _in: None,
      _iregex: None,
      _is_null: None,
      _like: None,
      _ilike: None,
      _lt: None,
      _lte: None,
      _neq: None,
      _nilike: None,
      _nin: None,
      _niregex: None,
      _nlike: None,
      _nregex: None,
      _nsimilar: None,
      _similar: None,
    }),
    search: {j`%$search%`},
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
              ({port, channel, state}) => {
                {port, channel, state}
              },
            )
            {channels: channelArray}
          },
        )

        let activeChannel =
          connections
          ->Belt.Array.map(
            ({channels}) => {
              channels->Belt.Array.keep(({state}) => state === 3)->Belt.Array.length
            },
          )
          ->Belt.Array.reduce(0, (acc, x) => acc + x)

        {chainID, connections: connectionArray, activeChannel}
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
