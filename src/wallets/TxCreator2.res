type request_params_t = {
  msg: Msg.Oracle.Request.t<unit, unit, unit>,
  clientID: string,
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
  | Request({msg, clientID}) =>
    MsgRequest.create(
      msg.oracleScriptID->ID.OracleScript.toInt,
      msg.calldata,
      msg.askCount,
      msg.minCount,
      clientID,
      msg.sender->Address.toBech32,
      msg.feeLimit->Coin.toBandChainJsCoins,
      {
        switch msg.prepareGas {
        | 0 => None
        | _ => Some(msg.prepareGas)
        }
      },
      {
        switch msg.executeGas {
        | 0 => None
        | _ => Some(msg.executeGas)
        }
      },
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

let createRawTx = async (~sender, ~msgs, ~chainID, ~feeAmount, ~gas, ~memo, ~client) => {
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

// let broadcast = async (client, txRawBytes) => {
//   open JsonUtils.Decode
//   let response = await client->BandChainJS.Client.sendTxBlockMode(txRawBytes)

//   Tx({
//     txHash: response->mustAt(list{"txhash"}, string)->Hash.fromHex,
//     code: response->mustAt(list{"code"}, int),
//     success: response->mustAt(list{"code"}, int) == 0,
//   })
// }
