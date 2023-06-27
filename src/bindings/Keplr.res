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

type keplrSignOptions = {
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

@val @scope(("window", "keplr"))
external enable: string => Js.Promise.t<unit> = "enable"

@val @scope(("window", "keplr"))
external getKey: string => Js.Promise.t<key> = "getKey"

@val @scope(("window", "keplr"))
external signDirect: (
  string,
  string,
  signDirectDoc,
  keplrSignOptions,
) => Js.Promise.t<directSignResponse> = "signDirect"

@val @scope(("window", "keplr"))
external signAmino: (
  string,
  string,
  signAminoDoc<'a>,
  keplrSignOptions,
) => Js.Promise.t<directSignResponse> = "signAmino"

let msgFromJson = (msgSend: Msg.Bank.Send.internal_t): msg<'a> =>
  {
    "type": "cosmos-sdk/MsgSend",
    "value": msgSend,
  }
