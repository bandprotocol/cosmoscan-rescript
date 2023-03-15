type tx_response_t = {
  txHash: Hash.t,
  success: bool,
  code: int,
}

type broadcast_response_t =
  | Tx(tx_response_t)
  | Error(string)

let createMsg = (sender, msg: Msg.Input.t) => {
  open BandChainJS.Message
  switch msg {
  | SendMsg({fromAddress, toAddress, amount}) =>
    MsgSend.create(
      fromAddress->Address.toBech32,
      toAddress->Address.toBech32,
      amount->Coin.toBandChainCoins,
    )
  | RequestMsg({
      oracleScriptID,
      calldata,
      askCount,
      minCount,
      clientID,
      sender,
      feeLimit,
      prepareGas,
      executeGas,
    }) =>
    MsgRequest.create(
      oracleScriptID->ID.OracleScript.toInt,
      calldata,
      askCount,
      minCount,
      clientID,
      sender->Address.toBech32,
      feeLimit->Coin.toBandChainCoins,
      prepareGas == 0 ? None : Some(prepareGas),
      executeGas == 0 ? None : Some(executeGas),
    )
  | DelegateMsg({delegatorAddress, validatorAddress, amount}) =>
    MsgDelegate.create(
      delegatorAddress->Address.toBech32,
      validatorAddress->Address.toOperatorBech32,
      amount->Coin.toBandChainCoin,
    )
  | UndelegateMsg({delegatorAddress, validatorAddress, amount}) =>
    MsgUndelegate.create(
      delegatorAddress->Address.toBech32,
      validatorAddress->Address.toOperatorBech32,
      amount->Coin.toBandChainCoin,
    )
  | RedelegateMsg({
      validatorSourceAddress,
      validatorDestinationAddress,
      delegatorAddress,
      amount,
    }) =>
    MsgRedelegate.create(
      delegatorAddress->Address.toBech32,
      validatorSourceAddress->Address.toOperatorBech32,
      validatorDestinationAddress->Address.toOperatorBech32,
      amount->Coin.toBandChainCoin,
    )
  | WithdrawRewardMsg({delegatorAddress, validatorAddress}) =>
    MsgWithdrawReward.create(
      delegatorAddress->Address.toBech32,
      validatorAddress->Address.toOperatorBech32,
    )
  | VoteMsg({proposalID, option, voterAddress}) =>
    MsgVote.create(proposalID->ID.Proposal.toInt, voterAddress->Address.toBech32, option)
  // | _ => failwith("Not implemented")
  }
}

let createRawTx = async (
  ~sender,
  ~msgs: array<Msg.Input.t>,
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
  try {
    let response = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)

    Tx({
      txHash: response.txhash->Hash.fromHex,
      code: response.code,
      success: response.code == 0,
    })
  } catch {
  | Js.Exn.Error(obj) =>
    Js.Console.log(obj)
    Error(Js.Exn.message(obj)->Belt.Option.getWithDefault("Unknown error"))
  }
}
