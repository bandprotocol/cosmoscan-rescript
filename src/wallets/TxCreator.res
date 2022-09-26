type amount_t = {
  amount: string,
  denom: string,
}

type fee_t = {
  amount: array<amount_t>,
  gas: string,
}

type msg_send_t = {
  to_address: string,
  from_address: string,
  amount: array<amount_t>,
}

type msg_delegate_t = {
  delegator_address: string,
  validator_address: string,
  amount: amount_t,
}

type msg_redelegate_t = {
  delegator_address: string,
  validator_src_address: string,
  validator_dst_address: string,
  amount: amount_t,
}

type msg_withdraw_reward_t = {
  delegator_address: string,
  validator_address: string,
}

type msg_request_t = {
  oracle_script_id: string,
  calldata: string,
  ask_count: string,
  min_count: string,
  sender: string,
  client_id: string,
  fee_limit: array<amount_t>,
  prepare_gas: string,
  execute_gas: string,
}

type msg_vote_t = {
  proposal_id: string,
  voter: string,
  option: int,
}

type msg_input_t =
  | Send(Address.t, amount_t)
  | Delegate(Address.t, amount_t)
  | Undelegate(Address.t, amount_t)
  | Redelegate(Address.t, Address.t, amount_t)
  | WithdrawReward(Address.t)
  | Request(
      ID.OracleScript.t,
      JsBuffer.t,
      string,
      string,
      Address.t,
      string,
      amount_t,
      string,
      string,
    )
  | Vote(ID.Proposal.t, int)

type msg_payload_t = {
  @as("type")
  type_: string,
  value: Js.Json.t,
}

type account_result_t = {
  accountNumber: int,
  sequence: int,
}

type pub_key_t = {
  @as("type")
  type_: string,
  value: string,
}

type signature_t = {
  pub_key: Js.Json.t,
  public_key: string,
  signature: string,
}

type raw_tx_t = {
  msgs: array<msg_payload_t>,
  chain_id: string,
  fee: fee_t,
  memo: string,
  account_number: string,
  sequence: string,
}

type signed_tx_t = {
  fee: fee_t,
  memo: string,
  msg: array<msg_payload_t>,
  signatures: array<signature_t>,
}

type t = {
  mode: string,
  tx: signed_tx_t,
}

type tx_response_t = {
  txHash: Hash.t,
  code: int,
}

let decode_tx_response = {
  open JsonUtils.Decode
  object(fields => {
    txHash: fields.required(. "txhash", hashFromHex),
    code: fields.optional(. "code", int)->Belt.Option.getWithDefault(0),
  })
}

type response_t =
  | Tx(tx_response_t)
  | Unknown

let decodeAccountInt = {
  // switch {
  //   open JsonUtils.Decode
  //   (decode(json, int), decode(json, intstr))
  // } {
  // | (Ok(x), _) => x
  // | (_, Ok(x)) => x
  // | (_, _) => raise(Not_found)
  open JsonUtils.Decode
  oneOf([int, intstr])
}

let getAccountInfo = address => {
  let url = Env.rpc ++ ("/auth/accounts/" ++ address->Address.toBech32)

  Axios.get(url)->Promise.then(info => {
    let data = info["data"]
    Promise.resolve({
      open JsonUtils.Decode
      {
        accountNumber: data
        ->decode(at(list{"result", "value", "account_number"}, decodeAccountInt))
        ->Belt.Result.getExn,
        sequence: data
        ->decode(at(list{"result", "value", "sequence"}, decodeAccountInt))
        ->Belt.Result.getWithDefault(0),
      }
    })
  })
}

let stringifyWithSpaces: raw_tx_t => string = %raw(`
  function stringifyWithSpaces(obj) {
    return JSON.stringify(obj, undefined, 4);
  }
`)

let sortAndStringify: raw_tx_t => string = %raw(`
  function sortAndStringify(obj) {
    function sortObject(obj) {
      if (obj === null) return null;
      if (typeof obj !== "object") return obj;
      if (Array.isArray(obj)) return obj.map(sortObject);
      const sortedKeys = Object.keys(obj).sort();
      const result = {};
      sortedKeys.forEach(key => {
        result[key] = sortObject(obj[key])
      });
      return result;
    }

    return JSON.stringify(sortObject(obj));
  }
`)

let createMsg = (sender, msg: msg_input_t): msg_payload_t => {
  let msgType = switch msg {
  | Send(_) => "cosmos-sdk/MsgSend"
  | Delegate(_) => "cosmos-sdk/MsgDelegate"
  | Undelegate(_) => "cosmos-sdk/MsgUndelegate"
  | Redelegate(_) => "cosmos-sdk/MsgBeginRedelegate"
  | WithdrawReward(_) => "cosmos-sdk/MsgWithdrawDelegationReward"
  | Request(_) => "oracle/Request"
  | Vote(_) => "cosmos-sdk/MsgVote"
  }

  let msgValue = switch msg {
  | Send(toAddress, coins) =>
    Js.Json.stringifyAny({
      from_address: sender->Address.toBech32,
      to_address: toAddress->Address.toBech32,
      amount: [coins],
    })
    ->Belt.Option.getExn
    ->Js.Json.parseExn
  | Delegate(validator, amount) =>
    Js.Json.stringifyAny({
      delegator_address: sender->Address.toBech32,
      validator_address: validator->Address.toOperatorBech32,
      amount,
    })
    ->Belt.Option.getExn
    ->Js.Json.parseExn
  | Undelegate(validator, amount) =>
    Js.Json.stringifyAny({
      delegator_address: sender->Address.toBech32,
      validator_address: validator->Address.toOperatorBech32,
      amount,
    })
    ->Belt.Option.getExn
    ->Js.Json.parseExn
  | Redelegate(fromValidator, toValidator, amount) =>
    Js.Json.stringifyAny({
      delegator_address: sender->Address.toBech32,
      validator_src_address: fromValidator->Address.toOperatorBech32,
      validator_dst_address: toValidator->Address.toOperatorBech32,
      amount,
    })
    ->Belt.Option.getExn
    ->Js.Json.parseExn
  | WithdrawReward(validator) =>
    Js.Json.stringifyAny({
      delegator_address: sender->Address.toBech32,
      validator_address: validator->Address.toOperatorBech32,
    })
    ->Belt.Option.getExn
    ->Js.Json.parseExn
  | Request(
      ID.OracleScript.ID(oracleScriptID),
      calldata,
      askCount,
      minCount,
      sender,
      clientID,
      feeLimit,
      prepareGas,
      executeGas,
    ) =>
    Js.Json.stringifyAny({
      oracle_script_id: oracleScriptID->Belt.Int.toString,
      calldata: calldata->JsBuffer.toBase64,
      ask_count: askCount,
      min_count: minCount,
      sender: sender->Address.toBech32,
      client_id: clientID,
      fee_limit: [feeLimit],
      prepare_gas: prepareGas,
      execute_gas: executeGas,
    })
    ->Belt.Option.getExn
    ->Js.Json.parseExn
  | Vote(ID.Proposal.ID(proposalID), answer) =>
    Js.Json.stringifyAny({
      proposal_id: proposalID->Belt.Int.toString,
      voter: sender->Address.toBech32,
      option: answer,
    })
    ->Belt.Option.getExn
    ->Js.Json.parseExn
  }
  {type_: msgType, value: msgValue}
}

let createRawTx = (~address, ~msgs, ~chainID, ~feeAmount, ~gas, ~memo, ()) =>
  getAccountInfo(address)->Promise.then(accountInfo => {
    Promise.resolve({
      msgs: msgs->Belt.Array.map(createMsg(address)),
      chain_id: chainID,
      fee: {
        amount: [{amount: feeAmount, denom: "uband"}],
        gas,
      },
      memo,
      account_number: accountInfo.accountNumber->Belt.Int.toString,
      sequence: accountInfo.sequence->Belt.Int.toString,
    })
  })

let createSignedTx = (~signature, ~pubKey, ~tx: raw_tx_t, ~mode, ()) => {
  let newPubKey = "eb5ae98721" ++ pubKey->PubKey.toHex->JsBuffer.hexToBase64
  let signedTx = {
    fee: tx.fee,
    memo: tx.memo,
    msg: tx.msgs,
    signatures: [
      {
        pub_key: Js.Json.object_(
          Js.Dict.fromList(list{
            ("type", Js.Json.string("tendermint/PubKeySecp256k1")),
            ("value", Js.Json.string(pubKey->PubKey.toBase64)),
          }),
        ),
        public_key: newPubKey,
        signature,
      },
    ],
  }
  {mode, tx: signedTx}
}

let broadcast = signedTx => {
  /* TODO: FIX THIS MESS */
  let convert: t => 'a = %raw(`
    function(data) {return {...data};}
  `)

  Axios.post(Env.rpc ++ "/txs", convert(signedTx))->Promise.then(rawResponse => {
    let response = rawResponse["data"]
    Promise.resolve(Tx(response->JsonUtils.Decode.mustDecode(decode_tx_response)))
  })
}
