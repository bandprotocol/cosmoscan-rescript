type t = {
  address: Address.t,
  pubKey: PubKey.t,
  wallet: Wallet.t,
  chainID: string,
}

type send_request_t = {
  oracleScriptID: ID.OracleScript.t,
  calldata: JsBuffer.t,
  callback: Promise.t<TxCreator.response_t> => unit,
  askCount: string,
  minCount: string,
  clientID: string,
  feeLimit: int,
  prepareGas: int,
  executeGas: int,
}

type a =
  | Connect(Wallet.t, Address.t, PubKey.t, string)
  | Disconnect
  | SendRequest(send_request_t)

let reducer = (state, x) =>
  switch x {
  | Connect(wallet, address, pubKey, chainID) =>
    Some({wallet: wallet, pubKey: pubKey, address: address, chainID: chainID})
  | Disconnect =>
    switch state {
    | Some({wallet}) => wallet |> Wallet.disconnect
    | None => ()
    }
    None
  | SendRequest({
      oracleScriptID,
      calldata,
      callback,
      askCount,
      minCount,
      clientID,
      feeLimit,
      prepareGas,
      executeGas,
    }) =>
    switch state {
    | Some({address, wallet, pubKey, chainID}) =>
      callback(
        TxCreator.createRawTx(
          ~address,
          ~msgs=[
            Request(
              oracleScriptID,
              calldata,
              askCount,
              minCount,
              address,
              clientID,
              {amount: feeLimit |> string_of_int, denom: "uband"},
              prepareGas |> string_of_int,
              executeGas |> string_of_int,
            ),
          ],
          ~chainID,
          ~gas="700000",
          ~feeAmount="0",
          ~memo="send via scan",
          (),
        )->Promise.then(rawTx => {
          Wallet.sign(TxCreator.sortAndStringify(rawTx), wallet)->Promise.then(signature => {
            let signedTx = TxCreator.createSignedTx(
              ~signature=signature |> JsBuffer.toBase64,
              ~pubKey,
              ~tx=rawTx,
              ~mode="block",
              (),
            )
            TxCreator.broadcast(signedTx)
          })
        }),
      )

      state
    | None =>
      callback(Promise.resolve(TxCreator.Unknown))
      state
    }
  }

let context = React.createContext(ContextHelper.default)

@react.component
let make = (~children) => {
  let (state, dispatch) = React.useReducer(reducer, None)

  React.createElement(
    React.Context.provider(context),
    {"value": (state, dispatch), "children": children},
  )
}
