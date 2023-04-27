type t = {
  address: Address.t,
  pubKey: PubKey.t,
  wallet: Wallet.t,
  chainID: string,
}

type a =
  | Connect(Wallet.t, Address.t, PubKey.t, string)
  | Disconnect

let reducer = (state, action) => {
  switch action {
  | Connect(wallet, address, pubKey, chainID) => Some({wallet, pubKey, address, chainID})
  | Disconnect => {
      switch state {
      | Some({wallet}) => wallet->Wallet.disconnect
      | None => ()
      }
      None
    }
  }
}

let context = React.createContext((None, _ => ()))

module Provider = {
  @react.component
  let make = (~children) => {
    let (state, dispatch) = React.useReducer(reducer, None)
    React.createElement(React.Context.provider(context), {value: (state, dispatch), children})
  }
}
