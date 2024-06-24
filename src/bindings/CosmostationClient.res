type t = {}

module Cosmos = {
  type account = {
    address: string,
    publicKey: array<int>,
    name: string,
    isLedger: bool,
  }

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

  type signAminoResponse = {
    signature: string,
    pub_key: {"type": string, "value": string},
    signed_doc: signAminoDoc,
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
    getAccount: string => Js.Promise.t<account>,
    signDirect: (string, signDirectDoc, option<signOptions>) => Js.Promise.t<signDirectResponse>,
    signAmino: (string, signAminoDoc, option<signOptions>) => Js.Promise.t<signAminoResponse>,
  }

  @module("@cosmostation/extension-client/cosmos")
  external getSupportedChains: string => Js.Promise.t<supportedChainNamesResponse> =
    "getSupportedChains"

  @module("@cosmostation/extension-client/cosmos")
  external getActivatedChains: string => Js.Promise.t<array<string>> = "getActivatedChains"

  @module("@cosmostation/extension-client/cosmos")
  external addChain: addChainParams => Js.Promise.t<array<string>> = "addChain"

  @module("@cosmostation/extension-client/cosmos")
  external getAccount: string => Js.Promise.t<account> = "getAccount"

  @module("@cosmostation/extension-client/cosmos")
  external signDirect: (
    string,
    signDirectDoc,
    option<signOptions>,
  ) => Js.Promise.t<signDirectResponse> = "signDirect"

  @module("@cosmostation/extension-client/cosmos")
  external signAmino: (
    string,
    signAminoDoc,
    option<signOptions>,
  ) => Js.Promise.t<signAminoResponse> = "signAmino"

  @module("@cosmostation/extension-client/cosmos")
  external disconnect: unit => Js.Promise.t<unit> = "disconnect"

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
}

@module("@cosmostation/extension-client")
external cosmos: unit => Js.Promise.t<Cosmos.t> = "cosmos"
