type t = {}

type amount = {
  denom: string,
  amount: string,
}

type fee = {
  amount: array<amount>,
  gas: string,
}

type sign_amino_doc_t = {
  chain_id: string,
  sequence: string,
  account_number: string,
  fee: fee,
  memo: string,
  msgs: array<Js.Json.t>,
}

type sign_amino_param_t = {
  chainName: string,
  doc: option<sign_amino_doc_t>,
  isEditFee: option<bool>,
  isEditMemo: option<bool>,
}

type request_account_response_t = {
  address: string,
  publicKey: array<int>,
  name: string,
  isLedger: bool,
  isEthermint: bool,
}

type sign_amino_response_t = {
  signature: string,
  pub_key: {"type": string, "value": string},
  signed_doc: sign_amino_doc_t,
}

type request_t = {
  method: string,
  params: sign_amino_param_t,
}

type sign_response_t = {signature: string}

@val @scope("window")
external cosmostation: option<t> = "cosmostation"

@val @scope(("window", "cosmostation", "cosmos"))
external request: 'a => Js.Promise.t<'b> = "request"

let requestAccount = async (chainName: string) => {
  let acc: request_account_response_t = await request({
    method: "cos_requestAccount",
    params: {
      chainName,
      doc: None,
      isEditFee: None,
      isEditMemo: None,
    },
  })

  acc
}

let signAmino = async (chainName: string, doc: sign_amino_doc_t) => {
  let response: sign_amino_response_t = await request({
    method: "cos_signAmino",
    params: {
      chainName,
      doc: Some(doc),
      isEditFee: Some(false),
      isEditMemo: Some(false),
    },
  })

  response
}

let getAminoSignDocFromTx = (tx: BandChainJS.Transaction.transaction_t) => {
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
