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

type signDoc = {
  /** SignDoc bodyBytes */
  bodyBytes?: array<int>,
  /** SignDoc authInfoBytes */
  authInfoBytes?: array<int>,
  /** SignDoc chainId */
  chainId?: string,
  /** SignDoc accountNumber */
  accountNumber?: Long.t,
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
  signed: signDoc,
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
  signDoc,
  keplrSignOptions,
) => Js.Promise.t<directSignResponse> = "signDirect"
