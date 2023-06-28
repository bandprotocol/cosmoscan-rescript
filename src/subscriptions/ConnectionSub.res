type state_t =
  | Uninitialized
  | Init
  | TryOpen
  | Open
  | Closed

type block_t = {timestamp: MomentRe.Moment.t}

type packet_t = {block: block_t}

type channel_t = {
  port: string,
  counterpartyPort: string,
  channelID: string,
  counterpartyChannelID: string,
  state: state_t,
  order: string,
  lastUpdate: MomentRe.Moment.t,
}

type external_channel_t = {
  port: string,
  counterpartyPort: string,
  channelID: string,
  counterpartyChannelID: string,
  state: state_t,
  order: string,
  lastUpdate: MomentRe.Moment.t,
}

type internal_t = {
  clientID: string,
  connectionID: string,
  counterpartyChainID: string,
  counterpartyClientID: string,
  counterpartyConnectionID: string,
  channels: array<channel_t>,
}

type t = {
  clientID: string,
  connectionID: string,
  counterpartyChainID: string,
  counterpartyClientID: string,
  counterpartyConnectionID: string,
  channels: array<external_channel_t>,
}

let toExternal = (
  {
    clientID,
    connectionID,
    counterpartyChainID,
    counterpartyClientID,
    counterpartyConnectionID,
    channels,
  }: internal_t,
) => {
  clientID,
  connectionID,
  counterpartyChainID,
  counterpartyClientID,
  counterpartyConnectionID,
  channels: channels->Belt.Array.map(channel => {
    {
      port: channel.port,
      counterpartyPort: channel.counterpartyPort,
      channelID: channel.channelID,
      counterpartyChannelID: channel.counterpartyChannelID,
      state: channel.state,
      order: channel.order,
      lastUpdate: channel.lastUpdate,
    }
  }),
}

exception NotMatch(string)
module State = {
  type t = state_t
  let parse = x =>
    switch x {
    | 0 => Uninitialized
    | 1 => Init
    | 2 => TryOpen
    | 3 => Open
    | 4 => Closed
    | x => raise(NotMatch(j`This $x doesn't match any state.`))
    }
  let serialize = state =>
    switch state {
    | Uninitialized => 0
    | Init => 1
    | TryOpen => 2
    | Open => 3
    | Closed => 4
    }
}

module Order = {
  type t = string
  let parse = x =>
    switch x {
    | "0" => "None"
    | "1" => "Unordered"
    | "2" => "Ordered"
    | x => raise(NotMatch(j`This $x doesn't match any state.`))
    }
  let serialize = _ => "order"
}

module MultiConfig = %graphql(`
  subscription Connections($limit: Int!, $offset: Int!, $chainID: String!, $state: Int_comparison_exp ) {
    connections(offset: $offset, limit: $limit, where: {counterparty_chain_id: {_eq: $chainID}, channels: { channel: { _is_null: false } } }) @ppxAs(type: "internal_t") {
      connectionID: connection_id
      clientID: client_id
      counterpartyClientID: counterparty_client_id
      counterpartyChainID: counterparty_chain_id
      counterpartyConnectionID: counterparty_connection_id
      channels (where: { state: $state}) @ppxAs(type: "channel_t") {
        channelID: channel
        counterpartyPort: counterparty_port
        counterpartyChannelID: counterparty_channel
        order @ppxCustom(module: "Order")
        state @ppxCustom(module: "State")
        port
        lastUpdate: last_update @ppxCustom(module: "GraphQLParserModule.Date")
        
      }
    }
  }
`)

module ConnectionCountConfig = %graphql(`
    subscription ConnectionCount($chainID: String!, $state: Int_comparison_exp){
       connections_aggregate(where: {counterparty_chain: {chain_id: {_eq: $chainID}}, channels: {state: $state}  }) {
        aggregate {
          count
        }
      }
    }
`)

let getList = (~counterpartyChainID, ~page, ~pageSize, ~state, ()) => {
  let offset = (page - 1) * pageSize

  let parseState = state ? Some(3) : None
  let result = MultiConfig.use({
    chainID: counterpartyChainID !== "" ? counterpartyChainID : "%%",
    // connectionID: j`%$connectionID%`,
    // state: Some({
    //   _eq: None,
    //   _gt: parseState,
    //   _gte: None,
    //   _in: None,
    //   _is_null: None,
    //   _lt: None,
    //   _lte: None,
    //   _neq: None,
    //   _nin: None,
    // }),
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
    limit: pageSize,
    offset,
  })

  result->Sub.fromData->Sub.map(internal => internal.connections->Belt.Array.map(toExternal))
}

let getCount = (~counterpartyChainID, ~state, ()) => {
  let parseState = state ? Some(3) : None
  let result = ConnectionCountConfig.use({
    chainID: counterpartyChainID !== "" ? counterpartyChainID : "%%",
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
  })

  result
  ->Sub.fromData
  ->Sub.map(x => x.connections_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))
}
