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
    }) =>
    switch state {
    | Some({address, wallet, pubKey, chainID}) => {
        let msg = TxCreator.createMsg(
          ~sender=address,
          ~msg=Request(
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
          (),
        )
        Js.log(msg)
        let promiseCallBack = async () => {
          let rawTx = await TxCreator.createRawTx(
            ~address,
            ~msgs=[msg],
            ~chainID,
            ~gas="700000",
            ~feeAmount="0",
            ~memo="send via scan",
            (),
          )
          let signature = await Wallet.sign(TxCreator.sortAndStringify(rawTx), wallet)
          let signedTx = TxCreator.createSignedTx(
            ~signature=signature->JsBuffer.toBase64,
            ~pubKey,
            ~tx=rawTx,
            ~mode="block",
            (),
          )

          let result = await TxCreator.broadcast(signedTx)

          result

          //TODO: update bandchain.js to 2.1.4
          // let jsonTxStr = rawTx->BandChainJS.Transaction.getSignMessage->JsBuffer.toUTF8;
          // let%Promise signature = Wallet.sign(jsonTxStr, wallet);
          // let signedTx = rawTx->BandChainJS.Transaction.getTxData(signature, wrappedPubKey, 127);
          // TxCreator2.broadcast(client, signedTx);
        }

        callback(()->promiseCallBack)
        state
      }

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
