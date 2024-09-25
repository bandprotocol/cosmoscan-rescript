type base_account = {
  address: string,
  accountNumber: int,
  sequence: int,
}

type tx_response = {
  txhash: string,
  code: int,
  rawLog: string,
}

// import { SignDoc } from '@bandprotocol/bandchain.js/proto/cosmos/tx/v1beta1/tx_pb'
module SignDoc = {
  type t

  @send external getChainId: t => string = "getChainId"
  @send external getBodyBytes_asU8: t => array<int> = "getBodyBytes_asU8"
  @send external getBodyBytes_asB64: t => string = "getBodyBytes_asB64"
  @send external getAuthInfoBytes_asU8: t => array<int> = "getAuthInfoBytes_asU8"
  @send external getAuthInfoBytes_asB64: t => string = "getAuthInfoBytes_asB64"
  @send external getAccountNumber: t => int = "getAccountNumber"

  @module("@bandprotocol/bandchain.js/proto/cosmos/tx/v1beta1/tx_pb") @scope("SignDoc") @val
  external deserializeBinary: array<int> => t = "deserializeBinary"
}

module Client = {
  type t
  type reference_data_t = {
    pair: string,
    rate: float,
  }

  @module("@bandprotocol/bandchain.js") @new external create: string => t = "Client"
  @send
  external getReferenceData: (t, array<string>, int, int) => promise<array<reference_data_t>> =
    "getReferenceData"
  @send external getAccount: (t, string) => promise<base_account> = "getAccount"
  @send external getChainId: t => promise<string> = "getChainId"
  @send
  external sendTxBlockMode: (t, array<int>) => promise<tx_response> = "sendTxBlockMode"
  @send external sendTxSyncMode: (t, array<int>) => promise<tx_response> = "sendTxSyncMode"
}

module Address = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "Address")) @val
  external fromHex: string => t = "fromHex"

  @send external toAccBech32: t => string = "toAccBech32"
  @send external toHex: t => string = "toHex"
}

module PubKey = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "PublicKey")) @val
  external fromHex: string => t = "fromHex"

  @send external toHex: t => string = "toHex"
  @send external toBech32: (t, string) => string = "toBech32"
  @send external toAddress: t => Address.t = "toAddress"
  @send external toAccBech32: t => string = "toAccBech32"
}

module PrivateKey = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "PrivateKey")) @val
  external fromMnemonic: (string, string) => t = "fromMnemonic"

  @send external sign: (t, array<int>) => JsBuffer.t = "sign"
  @send external toHex: t => string = "toHex"
  @send external toPubkey: t => PubKey.t = "toPubkey"
}

module Coin = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: unit => t = "Coin"
  @send external getDenom: t => string = "getDenom"
  @send external setDenom: (t, string) => unit = "setDenom"
  @send external getAmount: t => string = "getAmount"
  @send external setAmount: (t, string) => unit = "setAmount"
}

module Fee = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: unit => t = "Fee"
  @send external setAmountList: (t, array<Coin.t>) => unit = "setAmountList"
  @send external getAmountList: t => array<Coin.t> = "getAmountList"

  @send external setGasLimit: (t, int) => unit = "setGasLimit"
  @send external getGasLimit: t => int = "getGasLimit"

  @send external setPayer: (t, string) => unit = "setPayer"
  @send external getPayer: t => string = "getPayer"

  @send external setGranter: (t, string) => unit = "setGranter"
  @send external getGranter: t => string = "getGranter"
}

module Message = {
  type t
  module MsgSend = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, array<Coin.t>) => t = "MsgSend"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgDelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, Coin.t) => t = "MsgDelegate"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgUndelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, Coin.t) => t = "MsgUndelegate"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgRedelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, string, Coin.t) => t = "MsgBeginRedelegate"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgWithdrawReward = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string) => t = "MsgWithdrawDelegatorReward"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgVote = {
    // TODO: make Variant for VoteOptionMap
    // (proposalId: number, voter: string, option: VoteOptionMap[keyof VoteOptionMap],)
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (int, string, int) => t = "MsgVote"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgRequest = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (
      int,
      JsBuffer.t,
      int,
      int,
      string,
      string,
      array<Coin.t>,
      option<int>,
      option<int>,
    ) => t = "MsgRequestData"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgTransfer = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, string, string, Coin.t, float) => t = "MsgTransfer"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }
}

module Transaction = {
  type transaction_t = {
    msgs: array<Message.t>,
    accountNum?: int,
    sequence?: int,
    chainId?: string,
    fee: Fee.t,
    memo: string,
  }

  @module("@bandprotocol/bandchain.js") @new external create: unit => transaction_t = "Transaction"
  @send external withMessages: (transaction_t, Message.t) => unit = "withMessages"
  @send external withChainId: (transaction_t, string) => unit = "withChainId"
  @send external withSender: (transaction_t, Client.t, string) => Js.Promise.t<unit> = "withSender"
  @send external withAccountNum: (transaction_t, int) => unit = "withAccountNum"
  @send external withSequence: (transaction_t, int) => unit = "withSequence"
  @send external withFee: (transaction_t, Fee.t) => unit = "withFee"
  @send external withMemo: (transaction_t, string) => unit = "withMemo"
  @send external getSignDoc: (transaction_t, PubKey.t) => array<int> = "getSignDoc"
  @send external getTxData: (transaction_t, JsBuffer.t, PubKey.t, int) => array<int> = "getTxData"
  @send external getSignMessage: transaction_t => JsBuffer.t = "getSignMessage"
}

module Obi = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: string => t = "Obi"
  @send external encodeInput: (t, 'a) => JsBuffer.t = "encodeInput"
  @send external encodeOutput: (t, 'a) => JsBuffer.t = "encodeOutput"
  @send external decodeInput: (t, JsBuffer.t) => 'a = "decodeInput"
  @send external decodeOutput: (t, JsBuffer.t) => 'a = "decodeOutput"
}

module Signal = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: unit => t = "Signal"
  @send external getId: t => string = "getId"
  @send external setId: (t, string) => unit = "setId"
  @send external getPower: t => string = "getPower"
  @send external setPower: (t, string) => unit = "setPower"
}

module SignalPrice = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: unit => t = "SignalPrice"
  @send external getPriceStatus: t => string = "getPriceStatus"
  @send external setPriceStatus: (t, string) => unit = "setPriceStatus"
  @send external getSignalId: t => string = "getSignalId"
  @send external setSignalId: (t, string) => unit = "setSignalId"
  @send external getPrice: t => int = "getPrice"
  @send external setPrice: (t, int) => unit = "setPrice"
}
