type t = {}

type amount = {
  denom: string,
  amount: string,
}

type fee = {
  amount: array<amount>,
  gas: string,
}

type signAminoDoc = {
  chain_id: string,
  sequence: string,
  account_number: string,
  fee: fee,
  memo: string,
  msgs: array<Js.Json.t>,
}

type request_param_t = {
  chainName: string,
  doc: signAminoDoc,
  isEditFee: bool,
  isEditMemo: bool,
}

type request_t = {
  method: string,
  params: request_param_t,
}

type direct_sign_response_t = {signature: string}

@val @scope("window")
external cosmostation: option<t> = "cosmostation"

@val @scope(("window", "cosmostation", "cosmos"))
external request: request_t => Js.Promise.t<direct_sign_response_t> = "request"

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
