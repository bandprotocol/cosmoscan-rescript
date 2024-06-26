module Styles = {
  open CssJs

  let root = style(. [paddingLeft(#px(480))])
  let content = style(. [position(#relative), zIndex(1)])
  let baseBg = style(. [position(#absolute), top(#px(40))])
  let left = style(. [left(#zero)])
  let right = style(. [right(#zero), transform(rotateZ(#deg(180.)))])
}

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

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let client = React.useContext(ClientContext.context)
  let trackingSub = TrackingSub.use()

  let handleClickCosmostation = async chainId => {
    open CosmostationClient.Cosmos

    let provider = await CosmostationClient.cosmos()
    let account = await provider.getAccount(chainId)

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.address,
        account.address,
        account.publicKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
      )

    open BandChainJS.SignDoc
    let cosmosStationSignDoc = {
      chain_id: signDoc->getChainId,
      account_number: signDoc->getAccountNumber->Belt.Int.toString,
      auth_info_bytes: signDoc->getAuthInfoBytes_asU8,
      body_bytes: signDoc->getBodyBytes_asU8,
    }

    let signResponse = await provider.signDirect("bandtestnet", cosmosStationSignDoc, None)

    let txRawBytes =
      rawTx->BandChainJS.Transaction.getTxData(
        signResponse.signature->JsBuffer.fromBase64,
        account.publicKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
        1,
      )

    let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    Js.log(broadcastResponse)
  }

  let handleClickCosmostationAmino = async chainID => {
    let provider = await CosmostationClient.cosmos()
    let account = await provider.getAccount(chainID)

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.address,
        account.address,
        account.publicKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
      )

    let signResponse = await provider.signAmino(
      chainID,
      CosmostationClient.Cosmos.getAminoSignDocFromTx(rawTx),
      None,
    )

    Js.log(signResponse)

    // let txRawBytes =
    //   rawTx->BandChainJS.Transaction.getTxData(
    //     signResponse.signature->JsBuffer.fromBase64,
    //     account.publicKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
    //     127,
    //   )

    // let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    // Js.log(broadcastResponse)
  }

  let test = async chainID => {
    let provider = await CosmostationClient.cosmos()
    let account = await provider.getAccount(chainID)
    Js.log(account)
  }

  let {cosmosWallets, selectWallet} = CosmosProvider.useCosmosWallets()

  <Section pt=80 pb=80 bg={theme.neutral_000} style=Styles.root>
    {switch trackingSub {
    | Data({chainID}) =>
      <div>
        <button onClick={_ => handleClickCosmostationAmino(chainID)->ignore}>
          {"cosmos amino"->React.string}
        </button>
        <button onClick={_ => selectWallet(cosmosWallets[0].id)}>
          {"connect"->React.string}
        </button>
        <pre> {cosmosWallets[0]->Js.Json.stringifyAny->Belt.Option.getExn->React.string} </pre>
        <CosmosTest chainID />
      </div>
    | _ => React.null
    }}
  </Section>
}
