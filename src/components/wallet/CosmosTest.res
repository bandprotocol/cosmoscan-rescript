@react.component
let make = (~chainID) => {
  let {data} = CosmosProvider.useCosmosAccount(chainID)
  let client = React.useContext(ClientContext.context)

  let createSendTx = async (client, sender, reciever, pubKey) => {
    let msgs = [
      Msg.Input.SendMsg({
        fromAddress: sender->Address.fromBech32,
        toAddress: reciever->Address.fromBech32,
        amount: list{200000.->Coin.newUBANDFromAmount},
      }),
    ]
    let chainID = await client->BandChainJS.Client.getChainId

    let rawTx = await TxCreator.createRawTx(
      client,
      sender->Address.fromBech32,
      msgs,
      chainID,
      5000,
      200000,
      "",
    )

    let serializedSignDoc = rawTx->BandChainJS.Transaction.getSignDoc(
      // account.publicKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
      pubKey,
    )

    (rawTx, serializedSignDoc->BandChainJS.SignDoc.deserializeBinary)
  }

  let test = async (data: CosmosProvider.use_cosmos_account_data_t) => {
    let account = data.account

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.address,
        account.address,
        account.public_key.value->PubKey.fromBase64->PubKey.toHex->BandChainJS.PubKey.fromHex,
      )

    Js.log(CosmosProvider.getAminoSignDocFromTx(rawTx))

    open CosmosProvider
    let signResponse = await data.methods.signAmino(
      CosmosProvider.getAminoSignDocFromTx(rawTx),
      Some({
        edit_mode: {
          fee: false,
          memo: false,
        },
      }),
    )

    Js.log(signResponse)

    let txRawBytes =
      rawTx->BandChainJS.Transaction.getTxData(
        signResponse.signature->JsBuffer.fromBase64,
        account.public_key.value->PubKey.fromBase64->PubKey.toHex->BandChainJS.PubKey.fromHex,
        127,
      )

    let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    Js.log(broadcastResponse)
  }

  let test2 = async (data: CosmosProvider.use_cosmos_account_data_t) => {
    let account = data.account

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.address,
        account.address,
        account.public_key.value->PubKey.fromBase64->PubKey.toHex->BandChainJS.PubKey.fromHex,
      )

    let signResponse = await Cosmostation.request({
      method: "cos_signAmino",
      params: {
        chainName: chainID,
        doc: Cosmostation.getAminoSignDocFromTx(rawTx),
        isEditFee: false,
        isEditMemo: false,
      },
    })

    Js.log(signResponse)

    // let txRawBytes =
    //   rawTx->BandChainJS.Transaction.getTxData(
    //     signResponse.signature->JsBuffer.fromBase64,
    //     account.public_key.value->PubKey.fromBase64->PubKey.toHex->BandChainJS.PubKey.fromHex,
    //     127,
    //   )

    // let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    // Js.log(broadcastResponse)
  }

  <div>
    {switch data {
    | Some(d) =>
      <>
        <pre> {d->Js.Json.stringifyAny->Belt.Option.getExn->React.string} </pre>
        <pre>
          {d.account.public_key.value
          ->PubKey.fromBase64
          ->PubKey.toAddress
          ->Address.toBech32
          ->React.string}
        </pre>
        <button onClick={_ => test(d)->ignore}> {"test"->React.string} </button>
        <button onClick={_ => test2(d)->ignore}> {"test 2"->React.string} </button>
      </>
    | None => React.null
    }}
  </div>
}
