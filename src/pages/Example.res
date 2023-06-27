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

  let handleClickCosmostation = async () => {
    open Cosmostation.Cosmos

    let provider = await Cosmostation.cosmos()
    let account = await provider.getAccount("bandtestnet")

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

    // type signAminoDoc<'a> = {
    //   chain_id: string,
    //   sequence: string,
    //   account_number: string,
    //   fee: fee,
    //   memo: string,
    //   msgs: array<msg<'a>>,
    // }

    let msg = BandChainJS.Message.MsgSend.create(
      account.bech32Address,
      account.bech32Address,
      [200000.->Coin.newUBANDFromAmount->Coin.toBandChainJsCoin],
    )

    Js.log(msg)

    let keplrAminoSignDoc = {
      chain_id: chainID,
      account_number: bandChainJsAccount.accountNumber->Belt.Int.toString,
      sequence,
      fee: {
        amount: [
          {
            denom: "uband",
            amount: "5000",
          },
        ],
        gas: "2000000",
      },
      memo: "",
      msgs: [msg->BandChainJS.Message.MsgSend.toJSON],
    }

    let getSignDoc = (tx: BandChainJS.Transaction.transaction_t) => {
      account_number: tx.accountNum->Belt.Option.getExn->Belt.Int.toString,
      chain_id: tx.chainId->Belt.Option.getExn,
      fee: {
        amount: tx.fee
        ->BandChainJS.Fee.getAmountList
        ->Belt.Array.map(coin => {
          amount: coin->BandChainJS.Coin.getAmount,
          denom: coin->BandChainJS.Coin.getDenom,
        }),
        gas: tx.fee->BandChainJS.Fee.getGasLimit->Belt.Int.toString,
      },
      memo: tx.memo,
      msgs: tx.msgs->Belt.Array.map(msg => msg->BandChainJS.Message.MsgSend.toJSON),
      sequence: tx.sequence->Belt.Option.getExn->Belt.Int.toString,
    }

    let signResponse = await Keplr.signAmino(
      chainID,
      account.bech32Address,
      getSignDoc(rawTx),
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
    <div>
      <button onClick={_ => handleClickCosmostation()->ignore}>
        {"connect cosmostation"->React.string}
      </button>
      <button onClick={_ => handleClickKeplr()->ignore}> {"connect keplr"->React.string} </button>
    </div>
    <div>
      <button onClick={_ => handleClickCosmostation()->ignore}>
        {"sign cosmostation amino"->React.string}
      </button>
      <button onClick={_ => handleClickKeplrAmino()->ignore}>
        {"sign keplr amino"->React.string}
      </button>
    </div>
  </Section>
}
