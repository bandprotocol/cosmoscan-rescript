type t = {
  address: Address.t,
  pubKey: PubKey.t,
  wallet: Wallet.t,
  chainID: string,
}

type send_request_t = {
  oracleScriptID: ID.OracleScript.t,
  calldata: JsBuffer.t,
  callback: promise<TxCreator.response_t> => unit,
  askCount: string,
  minCount: string,
  clientID: string,
  feeLimit: int,
  prepareGas: int,
  executeGas: int,
  gaslimit: string,
}

type a =
  | Connect(Wallet.t, Address.t, PubKey.t, string)
  | Disconnect
  | SendRequest(send_request_t)

let reducer = (state, action) =>
  switch action {
  | Connect(wallet, address, pubKey, chainID) => Some({wallet, pubKey, address, chainID})
  | Disconnect =>
    switch state {
    | Some({wallet}) => wallet->Wallet.disconnect
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
      gaslimit,
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
              {amount: feeLimit->Belt.Int.toString, denom: "uband"},
              prepareGas->Belt.Int.toString,
              executeGas->Belt.Int.toString,
            ),
          ],
          ~chainID,
          ~gas={
            switch (gaslimit->Belt.Int.fromString) {
            | Some(gasOpt) => gasOpt
            | _ => 1000000
            };
          },
          ~feeAmount={
            switch (int_of_string_opt(gaslimit)) {
            | Some(gasOpt) => Js.Float.toString(float_of_int(gasOpt) *. 0.0025)
            | _ => "2500"
            };
          },
          ~memo="send via scan",
          (),
        )->Promise.then(rawTx => {
          Wallet.sign(TxCreator.sortAndStringify(rawTx), wallet)->Promise.then(signature => {
            let signedTx = TxCreator.createSignedTx(
              ~signature=signature->JsBuffer.toBase64,
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

type props = {value: (option<t>, a => unit), children: React.element}
let context = React.createContext((None, _ => ()))

module Provider = {
  @react.component
  let make = (~children) => {
    let (state, dispatch) = React.useReducer(reducer, None)
    React.createElement(React.Context.provider(context), {value: (state, dispatch), children})
  }
}
