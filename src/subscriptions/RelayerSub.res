type state_t =
  | Uninitialized
  | Init
  | TryOpen
  | Open
  | Closed

type channel_t = {
  channel: string,
  counterpartyChannel: string,
  counterpartyPort: string,
  port: string,
  state: state_t,
  order: string,
  lastUpdate: MomentRe.Moment.t,
}

type connection_t = {
  connectionID: string,
  clientID: string,
  counterpartyClientID: string,
  counterpartyChainID: string,
  channels: array<channel_t>,
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

type internal_t = {
  chainID: string,
  connections: array<connection_t>,
}

type t = {
  chainID: string,
  connections: array<connection_t>,
}

module CounterPartyChainsConfig = %graphql(`
    subscription CounterPartyChains {
        counterparty_chains @ppxAs(type: "internal_t"){
            chainID: chain_id
            connections @ppxAs(type: "connection_t") {
                connectionID: connection_id
                clientID: client_id
                counterpartyClientID: counterparty_client_id
                counterpartyChainID: counterparty_chain_id
                channels @ppxAs(type: "channel_t") {
                    channel
                    counterpartyChannel: counterparty_channel
                    counterpartyPort: counterparty_port
                    port
                    state @ppxCustom(module: "State")
                    order  @ppxCustom(module: "Order")
                    lastUpdate: last_update @ppxCustom(module: "GraphQLParserModule.Date")
                }
            }
        }
    }
`)

let toExternal = ({chainID, connections}: internal_t): t => {
  chainID,
  connections,
}

let getList = () => {
  let result = CounterPartyChainsConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(({counterparty_chains}) => counterparty_chains->Belt.Array.map(toExternal))
}
