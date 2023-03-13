type t = {
  address: Address.t,
  pubKey: PubKey.t,
  wallet: Wallet.t,
  chainID: string,
}

type send_request_t = {
  msg: Msg.Oracle.Request.t<unit, unit, unit>,
  clientID: string,
  gaslimit: string,
  callback: Promise.t<TxCreator2.response_t> => unit,
}

type a =
  | Connect(Wallet.t, Address.t, PubKey.t, string)
  | Disconnect
  | SendRequest(send_request_t, BandChainJS.Client.t)

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

  | SendRequest({msg, gaslimit, clientID, callback}, client) =>
    let {oracleScriptID, calldata, askCount, minCount, feeLimit, prepareGas, executeGas} = msg
    switch state {
    | Some({address, wallet, pubKey, chainID}) =>
      // let feeLimitCoin = BandChainJS.Coin.create()
      // feeLimitCoin->BandChainJS.Coin.setAmount(feeLimit)
      // feeLimitCoin->BandChainJS.Coin.setDenom("uband")

      let pubKeyHex = pubKey->PubKey.toHex
      let wrappedPubKey = pubKeyHex->BandChainJS.PubKey.fromHex

      callback({
        let createRawTX = async () => {
          let rawTx = await TxCreator2.createRawTx(
            ~sender=address,
            ~msgs=[
              Request({
                msg: {
                  oracleScriptID,
                  calldata,
                  askCount,
                  minCount,
                  prepareGas,
                  executeGas,
                  feeLimit,
                  sender: address,
                  id: (),
                  oracleScriptName: (),
                  schema: (),
                },
                clientID,
              }),
            ],
            ~chainID,
            ~gas={
              switch int_of_string_opt(gaslimit) {
              | Some(gasOpt) => gasOpt
              | _ => 1000000
              }
            },
            ~feeAmount={
              switch int_of_string_opt(gaslimit) {
              | Some(gasOpt) => Js.Float.toString(float_of_int(gasOpt) *. 0.0025)
              | _ => "2500"
              }
            },
            ~memo="send via scan",
            ~client,
          )

          let jsonTxStr = rawTx->BandChainJS.Transaction.getSignMessage->JsBuffer.toUTF8
          let signature = await Wallet.sign(jsonTxStr, wallet)
          let signedTx = rawTx->BandChainJS.Transaction.getTxData(signature, wrappedPubKey, 127)
          await TxCreator2.broadcast(client, signedTx)
        }
        createRawTX()
      })
      state
    | None => state
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
