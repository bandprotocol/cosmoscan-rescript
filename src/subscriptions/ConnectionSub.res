type state_t =
  | Uninitialized
  | Init
  | TryOpen
  | Open
  | Closed;

type channel_t = {
  port: string,
  counterpartyPort: string,
  channelID: string,
  counterpartyChannelID: string,
  state: state_t,
  order: string,
};

type internal_t = {
  clientID: string,
  connectionID: string,
  counterpartyChainID: string,
  counterpartyClientID: string,
  counterpartyConnectionID: string,
  channels: array<channel_t>,
};

type t = {
  clientID: string,
  connectionID: string,
  counterpartyChainID: string,
  counterpartyClientID: string,
  counterpartyConnectionID: string,
  channels: array<channel_t>,
};

exception NotMatch(string);
module State = {
  type t = state_t
  let parse = x =>
    switch x {
    | 0 => Uninitialized
    | 1 => Init
    | 2 => TryOpen
    | 3 => Open
    | 4 => Closed
    | x => raise(NotMatch(j`This $x doesn't match any state.`));
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
    | x => raise(NotMatch(j`This $x doesn't match any state.`));
    }
  let serialize = order => "order"
}


module MultiConfig = %graphql(`
  subscription Connections($limit: Int!, $offset: Int!, $chainID: String!, $connectionID: String!) {
    connections(offset: $offset, limit: $limit, where: {counterparty_chain: {chain_id: {_ilike: $chainID}}, connection_id: {_ilike: $connectionID}}) @ppxAs(type: "internal_t") {
      connectionID: connection_id
      clientID: client_id
      counterpartyClientID: counterparty_client_id
      counterpartyChainID: counterparty_chain_id
      counterpartyConnectionID: counterparty_connection_id
      channels @ppxAs(type: "channel_t") {
        channelID: channel
        counterpartyPort: counterparty_port
        counterpartyChannelID: counterparty_channel
        order @ppxCustom(module: "Order")
        state @ppxCustom(module: "State")
        port
      }
    }
  }
`)

module ConnectionCountConfig = %graphql(`
    subscription ConnectionCount($chainID: String!, $connectionID: String!){
       connections_aggregate(where: {counterparty_chain: {chain_id: {_ilike: $chainID}}, connection_id: {_ilike: $connectionID}}) {
        aggregate {
          count
        }
      }
    }
`)

let getList = (~counterpartyChainID, ~connectionID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize;
  let result = MultiConfig.use({
    chainID: counterpartyChainID !== "" ? counterpartyChainID : "%%",
    connectionID: j`%$connectionID%`,
    limit: pageSize,
    offset: offset
  })

  result
  -> Sub.fromData
  -> Sub.map(internal => internal.connections);
};

let getCount = (~counterpartyChainID, ~connectionID) => {
  let result = ConnectionCountConfig.use({
    chainID: counterpartyChainID !== "" ? counterpartyChainID : "%%",
    connectionID: j`%$connectionID%`,
  })

  result
  -> Sub.fromData
  -> Sub.map(x => x.connections_aggregate.aggregate |> Belt.Option.getExn |> (y => y.count));
};
