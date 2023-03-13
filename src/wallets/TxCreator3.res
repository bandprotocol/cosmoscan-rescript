type tx_response_t = {
  txHash: Hash.t,
  success: bool,
  code: int,
}

type response_t =
  | Tx(tx_response_t)
  | Unknown

let createMsg = (sender, msg: Msg.msg_t) => {
  open BandChainJS.Message
  switch msg {
  | SendMsg({fromAddress, toAddress, amount}) =>
    MsgSend.create(
      fromAddress->Address.toBech32,
      toAddress->Address.toBech32,
      amount->Coin.toBandChainCoins,
    )
  | DelegateMsg(Failure({delegatorAddress, validatorAddress, amount})) =>
    MsgDelegate.create(
      delegatorAddress->Address.toBech32,
      validatorAddress->Address.toOperatorBech32,
      amount->Coin.toBandChainCoin,
    )
  | _ => failwith("Not implemented")
  }
}

let createRawTx = async (
  ~sender,
  ~msgs: array<Msg.msg_t>,
  ~chainID,
  ~feeAmount,
  ~gas,
  ~memo,
  ~client,
) => {
  open BandChainJS.Transaction
  let senderStr = sender->Address.toBech32

  let feeCoin = BandChainJS.Coin.create()
  feeCoin->BandChainJS.Coin.setDenom("uband")
  feeCoin->BandChainJS.Coin.setAmount(feeAmount)

  let fee = BandChainJS.Fee.create()
  fee->BandChainJS.Fee.setAmountList([feeCoin])
  fee->BandChainJS.Fee.setGasLimit(gas)

  let tx = create()
  msgs->Belt.Array.forEach(msg => tx->withMessages(createMsg(senderStr, msg)))
  tx->withChainId(chainID)
  tx->withFee(fee)
  tx->withMemo(memo)
  await tx->withSender(client, senderStr)

  tx
}

let broadcast = async (client, txRawBytes) => {
  open JsonUtils.Decode
  let response = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)

  Tx({
    txHash: response->mustAt(list{"txhash"}, string)->Hash.fromHex,
    code: response->mustAt(list{"code"}, int),
    success: response->mustAt(list{"code"}, int) == 0,
  })
}
