type tx_response_t = {
  txHash: Hash.t,
  success: bool,
  code: int,
  rawLog: string,
}

let createMsg = (msg: Msg.Input.t) => {
  open BandChainJS.Message
  switch msg {
  | SendMsg({fromAddress, toAddress, amount}) =>
    MsgSend.create(
      fromAddress->Address.toBech32,
      toAddress->Address.toBech32,
      amount->Coin.toBandChainJsCoins,
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
      feeLimit->Coin.toBandChainJsCoins,
      prepareGas == 0 ? None : Some(prepareGas),
      executeGas == 0 ? None : Some(executeGas),
    )
  | DelegateMsg({delegatorAddress, validatorAddress, amount}) =>
    MsgDelegate.create(
      delegatorAddress->Address.toBech32,
      validatorAddress->Address.toOperatorBech32,
      amount->Coin.toBandChainJsCoin,
    )
  | UndelegateMsg({delegatorAddress, validatorAddress, amount}) =>
    MsgUndelegate.create(
      delegatorAddress->Address.toBech32,
      validatorAddress->Address.toOperatorBech32,
      amount->Coin.toBandChainJsCoin,
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
      amount->Coin.toBandChainJsCoin,
    )
  | WithdrawRewardMsg({delegatorAddress, validatorAddress}) =>
    MsgWithdrawReward.create(
      delegatorAddress->Address.toBech32,
      validatorAddress->Address.toOperatorBech32,
    )
  | VoteMsg({proposalID, option, voterAddress}) =>
    MsgVote.create(proposalID->ID.Proposal.toInt, voterAddress->Address.toBech32, option)
  | IBCTransfer({sourcePort, sourceChannel, receiver, token, timeoutTimestamp, sender}) =>
    MsgTransfer.create(
      sourcePort,
      sourceChannel,
      sender->Address.toBech32,
      receiver,
      token->Coin.toBandChainJsCoin,
      timeoutTimestamp,
    )
  }
}

let createRawTx = async (client, sender, msgs, chainID, feeAmount, gas, memo) => {
  open BandChainJS.Transaction
  let senderStr = sender->Address.toBech32

  let feeCoin = BandChainJS.Coin.create()
  feeCoin->BandChainJS.Coin.setDenom("uband")
  feeCoin->BandChainJS.Coin.setAmount(feeAmount->Belt.Int.toString)

  let fee = BandChainJS.Fee.create()
  fee->BandChainJS.Fee.setAmountList([feeCoin])
  fee->BandChainJS.Fee.setGasLimit(gas)

  let tx = create()
  msgs->Belt.Array.forEach(msg => tx->withMessages(createMsg(msg)))
  tx->withChainId(chainID)
  tx->withFee(fee)
  tx->withMemo(memo)
  await tx->withSender(client, senderStr)

  tx
}

let signTx = async (account: AccountContext.t, rawTx) => {
  try {
    let signature = await Wallet.sign(rawTx, account.wallet)
    Belt.Result.Ok(
      rawTx->BandChainJS.Transaction.getTxData(
        signature,
        account.pubKey->PubKey.toHex->BandChainJS.PubKey.fromHex,
        127,
      ),
    )
  } catch {
  | Js.Exn.Error(obj) =>
    Js.Console.log(obj)
    Error(Js.Exn.message(obj)->Belt.Option.getWithDefault("Unknown error on signing"))
  }
}

let broadcastTx = async (client, signedTx) => {
  try {
    let response = await client->BandChainJS.Client.sendTxBlockMode(signedTx)
    Belt.Result.Ok({
      txHash: response.txhash->Hash.fromHex,
      code: response.code,
      success: response.code == 0,
      rawLog: response.rawLog,
    })
  } catch {
  | Js.Exn.Error(obj) =>
    Js.Console.log(obj)
    Error(Js.Exn.message(obj)->Belt.Option.getWithDefault("Unknown error on broadcasting"))
  }
}

let sendTransaction = async (
  client,
  account: AccountContext.t,
  msgs: array<Msg.Input.t>,
  feeAmount,
  gas,
  memo,
) => {
  let rawTx = await createRawTx(
    client,
    account.address,
    msgs,
    account.chainID,
    feeAmount,
    gas,
    memo,
  )
  switch await signTx(account, rawTx) {
  | Ok(signedTx) => await broadcastTx(client, signedTx)
  | Error(err) => Error(err)
  }
}

let stringifyWithSpaces = json => Js.Json.stringifyWithSpace(json, 4)
