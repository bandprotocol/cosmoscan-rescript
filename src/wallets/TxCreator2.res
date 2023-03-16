type request_params_t = {
  osID: ID.OracleScript.t,
  calldata: JsBuffer.t,
  askCount: int,
  minCount: int,
  clientID: string,
  sender: Address.t,
  feeLimitList: array<BandChainJS.Coin.t>,
  prepareGas: option<int>,
  executeGas: option<int>,
}

type ibc_transfer_t = {
  sourcePort: string,
  sourceChannel: string,
  receiver: string,
  token: BandChainJS.Coin.t,
  timeoutTimestamp: float,
}

type tx_response_t = {
  txHash: Hash.t,
  success: bool,
  code: int,
}

type response_t =
  | Tx(tx_response_t)
  | Unknown

type msg_input_t =
  | Send(Address.t, array<BandChainJS.Coin.t>)
  | Delegate(Address.t, BandChainJS.Coin.t)
  | Undelegate(Address.t, BandChainJS.Coin.t)
  | Redelegate(Address.t, Address.t, BandChainJS.Coin.t)
  | WithdrawReward(Address.t)
  | Request(request_params_t)
  | Vote(ID.Proposal.t, int)
  | IBCTransfer(ibc_transfer_t)

let createMsg = (sender, msg: msg_input_t) => {
  open BandChainJS.Message
  switch msg {
  | Send(toAddress, coins) => MsgSend.create(sender, toAddress->Address.toBech32, coins)
  | Delegate(validator, amount) =>
    MsgDelegate.create(sender, validator->Address.toOperatorBech32, amount)
  | Undelegate(validator, amount) =>
    MsgUndelegate.create(sender, validator->Address.toOperatorBech32, amount)
  | Redelegate(srcValidator, dstValidator, amount) =>
    MsgRedelegate.create(
      sender,
      srcValidator->Address.toOperatorBech32,
      dstValidator->Address.toOperatorBech32,
      amount,
    )
  | WithdrawReward(validator) =>
    MsgWithdrawReward.create(sender, validator->Address.toOperatorBech32)
  | Vote(ID.Proposal.ID(proposalID), answer) => MsgVote.create(proposalID, sender, answer)
  | Request({
      osID: ID.OracleScript.ID(oracleScriptID),
      calldata,
      askCount,
      minCount,
      clientID,
      sender,
      feeLimitList,
      prepareGas,
      executeGas,
    }) =>
    MsgRequest.create(
      oracleScriptID,
      calldata,
      askCount,
      minCount,
      clientID,
      sender->Address.toBech32,
      feeLimitList,
      prepareGas,
      executeGas,
    )
  | IBCTransfer({sourcePort, sourceChannel, receiver, token, timeoutTimestamp}) =>
    MsgTransfer.create(sourcePort, sourceChannel, sender, receiver, token, timeoutTimestamp)
  }
}

let stringifyWithSpaces: Js.Json.t => string = %raw(`
    function stringifyWithSpaces(obj) {
        return JSON.stringify(obj, undefined, 4);
    }
`)

let createRawTx = (~sender, ~msgs, ~chainID, ~feeAmount, ~gas, ~memo, ~client, ()) => {
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
  tx->withSender(client, senderStr)
}

let broadcast = async (client, txRawBytes) => {
  open JsonUtils.Decode
  let response = await client->BandChainJS.Client.sendTxSyncMode(txRawBytes)
  let txHash = response->Belt.Option.getWithDefault("txhash")->Hash.fromHex
  let code = response->Belt.Option.getWithDefault(_, 0)
  let success = code == 0
  Tx({txHash, code, success})
}
