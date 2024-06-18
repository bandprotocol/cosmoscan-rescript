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
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let trackingSub = TrackingSub.use()

  let checkLeap = () => {
    switch Leap.leap {
    | Some(x) => Js.log(x)
    | None => Js.log("no leap")
    }
  }

  let handleClickKeplrAmino = async chainID => {
    await Leap.enable(chainID)
    let account = await Leap.getKey(chainID)
    let bandChainJsAccount = await client->BandChainJS.Client.getAccount(account.bech32Address)
    let sequence = bandChainJsAccount.sequence->Belt.Int.toString

    Js.log2(bandChainJsAccount, sequence)

    let (rawTx, signDoc) =
      await client->createSendTx(
        account.bech32Address,
        "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph",
        account.pubKey->JsBuffer.arrayToHex->BandChainJS.PubKey.fromHex,
      )

    open Leap
    open BandChainJS.SignDoc

    let signResponse = await Leap.signAmino(
      chainID,
      account.bech32Address,
      Leap.getAminoSignDocFromTx(rawTx),
      {
        preferNoSetFee: true,
        preferNoSetMemo: false,
        disableBalanceCheck: false,
      },
    )

    // Js.log(signResponse)

    Js.log2("getAminoSignDocFromTx", Leap.getAminoSignDocFromTx(rawTx))
    Js.log2("BandChainJS.Transaction.getSignMessage", BandChainJS.Transaction.getSignMessage(rawTx))

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
    // <pre> {Js.Json.stringifyAny(Leap.leap)->Belt.Option.getExn->React.string} </pre>
    <Button onClick={_ => checkLeap()}> {"check Leap"->React.string} </Button>
    {switch trackingSub {
    | Data({chainID}) =>
      <div>
        <Text value=chainID />
        <Button onClick={_ => handleClickKeplrAmino(chainID)->ignore}>
          {"send BAND"->React.string}
        </Button>
      </div>
    | Error(err) => <Text value="Invalid Chain ID" />
    | _ => <LoadingCensorBar width=150 height=30 />
    }}
  </Section>
}
