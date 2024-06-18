type t = {}
module Long = {
  type t = {
    high: int,
    low: int,
    unsigned: bool,
  }

  @module("long")
  external fromNumber: int => t = "fromNumber"
}

type key = {
  name: string,
  algo: string,
  pubKey: array<int>,
  address: array<int>,
  bech32Address: string,
  isNanoLedger: bool,
  isKeystone: bool,
}

type signDirectDoc = {
  /** SignDoc bodyBytes */
  bodyBytes?: array<int>,
  /** SignDoc authInfoBytes */
  authInfoBytes?: array<int>,
  /** SignDoc chainId */
  chainId?: string,
  /** SignDoc accountNumber */
  accountNumber?: Long.t,
}

type amount = {
  denom: string,
  amount: string,
}

type fee = {
  amount: array<amount>,
  gas: string,
}

type msg<'a> = {"type": string, "value": 'a}

type signAminoDoc<'a> = {
  chain_id: string,
  sequence: string,
  account_number: string,
  fee: fee,
  memo: string,
  msgs: array<Js.Json.t>,
}

type leapSignOptions = {
  preferNoSetFee?: bool,
  preferNoSetMemo?: bool,
  disableBalanceCheck?: bool,
}
type pubKey = {"type": string, "value": string}

type stdSignature = {
  pub_key: pubKey,
  signature: string,
}

type directSignResponse = {
  signed: signDirectDoc,
  signature: stdSignature,
}

@val @scope(("window", "leap"))
external enable: string => Js.Promise.t<unit> = "enable"

@val @scope(("window", "leap"))
external getKey: string => Js.Promise.t<key> = "getKey"

@val @scope(("window", "leap"))
external signDirect: (
  string,
  string,
  signDirectDoc,
  leapSignOptions,
) => Js.Promise.t<directSignResponse> = "signDirect"

@val @scope(("window", "leap"))
external signAmino: (
  string,
  string,
  signAminoDoc<'a>,
  leapSignOptions,
) => Js.Promise.t<directSignResponse> = "signAmino"

@val @scope("window")
external leap: option<t> = "leap"

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
