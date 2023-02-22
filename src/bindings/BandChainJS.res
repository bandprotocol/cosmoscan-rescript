module Client = {
  type t
  type reference_data_t = {
    pair: string,
    rate: float,
  }

  @module("@bandprotocol/bandchain.js") @new external create: string => t = "Client"
  @send
  external getReferenceData: (t, array<string>) => promise<array<reference_data_t>> =
    "getReferenceData"
  @send external sendTxBlockMode: (t, JsBuffer.t) => Js.Promise.t<'a> = "sendTxBlockMode"
  @send external sendTxSyncMode: (t, JsBuffer.t) => Js.Promise.t<'a> = "sendTxSyncMode"
}

module Address = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "Address"))
  @val external fromHex: string => t = "fromHex";

  @send external toAccBech32: t => string = "toAccBech32";
}

module PubKey = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "PublicKey"))
  @val external fromHex: string => t = "fromHex";

  @send external toHex: t => string = "toHex";
  @send external toBech32: string => string = "toBech32";
  @send external toAddress: (t) => Address.t = "toAddress";
}

module PrivateKey = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "PrivateKey"))
  @val external fromMnemonic: (string, string) => t = "fromMnemonic";

  @send external sign: (t, array<int>) => JsBuffer.t = "sign";
  @send external toHex: (t) => string = "toHex";
  @send external toPubkey: (t) => PubKey.t = "toPubkey";
}

module Coin = {
  type t;

  @module("@bandprotocol/bandchain.js") @new external create: () => t = "Coin"
  @send external setDenom: (t, string) => unit = "setDenom";
  @send external setAmount: (t, string) => unit = "setAmount";
};

module Fee = {
  type t;

  @module("@bandprotocol/bandchain.js") @new external create: () => t = "Fee"
  @send external setAmountList: (t, array<Coin.t>) => unit = "setAmountList";
  @send external setGasLimit: (t, int) => unit = "setGasLimit";
}

module Message = {

  type t
  module MsgSend = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (string, string, array<Coin.t>) => t = "MsgSend"
  }

  module MsgDelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (string, string, Coin.t) => t = "MsgDelegate"
  }

  module MsgUndelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (string, string, Coin.t) => t = "MsgUndelegate"
  }

  module MsgRedelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (string, string, string, Coin.t) => t = "MsgBeginRedelegate"
  }

  module MsgWithdrawReward = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (string, string) => t = "MsgWithdrawDelegatorReward"
  }

  module MsgVote = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (int, string, int) => t = "MsgVote"
  }

  module MsgRequest = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (int, JsBuffer.t, int, int, string, string, array<Coin.t>, option<int>, option<int>) =>
    t = "MsgRequestData"
  }

  module MsgTransfer = {
    @module("@bandprotocol/bandchain.js") @scope("Message") 
    @new external create: (string, string, string, string, Coin.t, float) => t = "MsgTransfer"
  }
}

module Transaction = {
  type transaction_t

  @module("@bandprotocol/bandchain.js") @new external create: () => transaction_t = "Transaction"
  @send external withMessages: (transaction_t, Message.t) => unit = "withMessages"
  @send external withChainId: (transaction_t, string) => unit = "withChainId"
  @send external withSender: (transaction_t, Client.t, string) => Js.Promise.t<transaction_t> = "withSender"
  @send external withAccountNum: (transaction_t, int) => unit = "withAccountNum"
  @send external withSequence: (transaction_t, int) => unit = "withSequence"
  @send external withFee: (transaction_t, Fee.t) => unit = "withFee"
  @send external withMemo: (transaction_t, string) => unit = "withMemo"
  @send external getSignDoc: (transaction_t, PubKey.t) => array<int> = "getSignDoc"
  @send external getTxData: (transaction_t, JsBuffer.t, PubKey.t, int) => JsBuffer.t = "getTxData"
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
