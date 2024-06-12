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
  let (address, setAddress) = React.useState(_ => "")
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  let connectWalletKeplr = async () => {
    let chainID = await client->BandChainJS.Client.getChainId
    await Keplr.enable(chainID)
    let account = await Keplr.getKey(chainID)
    setAddress(_ => account.bech32Address)
  }

  let selectWallet = async () => {
    let chainID = await client->BandChainJS.Client.getChainId
    dispatchModal(OpenModal(SelectWallet(chainID)))
  }

  React.useEffect0(() => {
    connectWalletKeplr()->ignore

    None
  })

  let handleClickKeplr = async () => {
    let chainID = await client->BandChainJS.Client.getChainId
    await Keplr.enable(chainID)
    let account = await Keplr.getKey(chainID)

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.bech32Address,
        account.bech32Address,
        account.pubKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
      )

    open Keplr
    open BandChainJS.SignDoc
    let keplrSignDoc = {
      chainId: signDoc->getChainId,
      accountNumber: signDoc->getAccountNumber->Long.fromNumber,
      authInfoBytes: signDoc->getAuthInfoBytes_asU8,
      bodyBytes: signDoc->getBodyBytes_asU8,
    }

    let signResponse = await Keplr.signDirect(
      chainID,
      account.bech32Address,
      keplrSignDoc,
      {
        preferNoSetFee: true,
        preferNoSetMemo: false,
        disableBalanceCheck: false,
      },
    )

    Js.log(signResponse)

    let txRawBytes =
      rawTx->BandChainJS.Transaction.getTxData(
        signResponse.signature.signature->JsBuffer.fromBase64,
        account.pubKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
        1,
      )

    let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    Js.log(broadcastResponse)
  }

  let handleClickKeplrAmino = async () => {
    let chainID = await client->BandChainJS.Client.getChainId
    await Keplr.enable(chainID)
    let account = await Keplr.getKey(chainID)
    let bandChainJsAccount = await client->BandChainJS.Client.getAccount(account.bech32Address)
    let sequence = bandChainJsAccount.sequence->Belt.Int.toString

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.bech32Address,
        account.bech32Address,
        account.pubKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
      )

    open Keplr
    open BandChainJS.SignDoc

    let signResponse = await Keplr.signAmino(
      chainID,
      account.bech32Address,
      Keplr.getAminoSignDocFromTx(rawTx),
      {
        preferNoSetFee: true,
        preferNoSetMemo: false,
        disableBalanceCheck: false,
      },
    )

    Js.log(signResponse)

    let txRawBytes =
      rawTx->BandChainJS.Transaction.getTxData(
        signResponse.signature.signature->JsBuffer.fromBase64,
        account.pubKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
        127,
      )

    let broadcastResponse = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)
    Js.log(broadcastResponse)
  }

  <Section pt=80 pb=80 bg={theme.neutral_000} style=Styles.root>
    <h3> {address->React.string} </h3>
    <Button onClick={_ => selectWallet()->ignore}> {"select wallet"->React.string} </Button>
  </Section>
}
