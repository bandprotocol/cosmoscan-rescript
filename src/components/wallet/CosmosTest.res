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
    open CosmostationClient.Cosmos

    let account = data.account

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.address,
        account.address,
        account.public_key.value->BandChainJS.PubKey.fromHex,
      )

    open BandChainJS.SignDoc
    let cosmosStationSignDoc = {
      chain_id: signDoc->getChainId,
      account_number: signDoc->getAccountNumber->Belt.Int.toString,
      auth_info_bytes: signDoc->getAuthInfoBytes_asU8,
      body_bytes: signDoc->getBodyBytes_asU8,
    }

    Js.log(CosmostationClient.Cosmos.getAminoSignDocFromTx(rawTx))

    let signResponse = await data.methods.signAmino(
      CosmostationClient.Cosmos.getAminoSignDocFromTx(rawTx),
      None,
    )

    Js.log(signResponse)

    let txRawBytes =
      rawTx->BandChainJS.Transaction.getTxData(
        signResponse.signature->JsBuffer.fromBase64,
        account.public_key.value->BandChainJS.PubKey.fromHex,
        127,
      )

    let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    Js.log(broadcastResponse)
  }

  <div>
    {switch data {
    | Some(d) =>
      <>
        <pre> {d->Js.Json.stringifyAny->Belt.Option.getExn->React.string} </pre>
        <button onClick={_ => d.methods.disconnect()}> {"disconnect"->React.string} </button>
        <button onClick={_ => test(d)->ignore}> {"test"->React.string} </button>
      </>
    | None => React.null
    }}
  </div>
}
