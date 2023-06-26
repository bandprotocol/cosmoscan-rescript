module Cosmos = {
  type requestAccountResponse = {
    address: string,
    publicKey: array<int>,
    name: string,
    isLedger: bool,
  }

  type signDirectDoc = {
    chain_id: string,
    body_bytes: array<int>,
    auth_info_bytes: array<int>,
    account_number: string,
  }

  type signDirectResponse = {
    signature: string,
    pub_key: {"type": string, "value": string},
    signed_doc: signDirectDoc,
  }

  type gasRateType = {
    tiny: string,
    low: string,
    average: string,
  }

  type signOptions = {
    memo?: bool,
    fee?: bool,
    gasRate?: gasRateType,
  }

  type supportedChainNamesResponse = {
    official: array<string>,
    unofficial: array<string>,
  }

  type addChainParams = {
    chainId: string,
    chainName: string,
    restURL: string,
    imageURL?: string,
    baseDenom: string,
    displayDenom: string,
    decimals?: float,
    coinType?: string,
    addressPrefix: string,
    coinGeckoId?: string,
    gasRate?: gasRateType,
    sendGas?: string,
  }

  type t = {
    getAccount: string => Js.Promise.t<requestAccountResponse>,
    signDirect: (string, signDirectDoc, option<signOptions>) => Js.Promise.t<signDirectResponse>,
  }

  @module("@cosmostation/extension-client/cosmos")
  external getSupportedChains: string => Js.Promise.t<supportedChainNamesResponse> =
    "getSupportedChains"

  @module("@cosmostation/extension-client/cosmos")
  external getActivatedChains: string => Js.Promise.t<array<string>> = "getActivatedChains"

  @module("@cosmostation/extension-client/cosmos")
  external addChain: addChainParams => Js.Promise.t<array<string>> = "addChain"

  @module("@cosmostation/extension-client/cosmos")
  external getAccount: string => Js.Promise.t<requestAccountResponse> = "getAccount"

  @module("@cosmostation/extension-client/cosmos")
  external signDirect: (
    string,
    signDirectDoc,
    option<signOptions>,
  ) => Js.Promise.t<signDirectResponse> = "signDirect"

  @module("@cosmostation/extension-client/cosmos")
  external disconnect: unit => Js.Promise.t<unit> = "disconnect"
}

@module("@cosmostation/extension-client")
external cosmos: unit => Js.Promise.t<Cosmos.t> = "cosmos"
