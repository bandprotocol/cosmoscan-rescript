module Styles = {
  open CssJs

  let root = style(. [paddingLeft(#px(480))])
  let content = style(. [position(#relative), zIndex(1)])
  let baseBg = style(. [position(#absolute), top(#px(40))])
  let left = style(. [left(#zero)])
  let right = style(. [right(#zero), transform(rotateZ(#deg(180.)))])
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let client = React.useContext(ClientContext.context)

  let handleClick = async () => {
    open Cosmostation.Cosmos

    let provider = await Cosmostation.cosmos()
    let account = await provider.getAccount("bandtestnet")
    let chainID = await client->BandChainJS.Client.getChainId
    let defaultFee = 5000 // Hard code fee for sending transaction on cosmoscan

    let msgs = [
      Msg.Input.SendMsg({
        fromAddress: "band1zv4qrj04u8v9fg9a59gfpld0l0g6w9xeuypyxr"->Address.fromBech32,
        toAddress: "band1zv4qrj04u8v9fg9a59gfpld0l0g6w9xeuypyxr"->Address.fromBech32,
        amount: list{200000.->Coin.newUBANDFromAmount},
      }),
    ]

    let rawTx = await TxCreator.createRawTx(
      client,
      account.address->Address.fromBech32,
      msgs,
      chainID,
      defaultFee,
      200000,
      "",
    )

    let serializedSignDoc =
      rawTx->BandChainJS.Transaction.getSignDoc(
        account.publicKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
      )

    open BandChainJS.SignDoc
    let deserializedSignDoc = serializedSignDoc->deserializeBinary

    let cosmosStationSignDoc = {
      chain_id: deserializedSignDoc->getChainId,
      account_number: deserializedSignDoc->getAccountNumber->Belt.Int.toString,
      auth_info_bytes: deserializedSignDoc->getAuthInfoBytes_asU8,
      body_bytes: deserializedSignDoc->getBodyBytes_asU8,
    }

    let signResponse = await provider.signDirect("bandtestnet", cosmosStationSignDoc, None)
    Js.log(signResponse.signature)

    let txRawBytes =
      rawTx->BandChainJS.Transaction.getTxData(
        signResponse.signature->JsBuffer.fromBase64,
        account.publicKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
        1,
      )

    let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    Js.log(broadcastResponse)
  }

  <Section pt=80 pb=80 bg={theme.neutral_000} style=Styles.root>
    <div>
      <button onClick={_ => handleClick()->ignore}> {"connect"->React.string} </button>
    </div>
  </Section>
}
