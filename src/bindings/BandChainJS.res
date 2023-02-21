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
}

module Transaction = {
  type transaction_t;

  @module("@bandprotocol/bandchain.js") @new external create: () => transaction_t = "Client"
  @send external withMessage: (transaction_t, Message.t) => unit = "withMessages";
  @send external withChainId: (transaction_t, string) => unit = "withChainId";
  @send external withSender: (transaction_t, Client.t, string) => Js.Promise.t<transaction_t> = "withSender";
  @send external withAccountNum: (transaction_t, int) => unit = "withAccountNum";
  @send external withSequence: (transaction_t, int) => unit = "withSequence";
  @send external withFee: (transaction_t, Fee.t) => unit = "withFee";
  @send external withMemo: (transaction_t, string) => unit = "withMemo";
  @send external getSignDoc: (transaction_t, PubKey.t, int) => array<int> = "getSignDoc";
  @send external getTxData: (transaction_t, JsBuffer.t, PubKey.t, int) => JsBuffer.t = "getTxData";
  @send external getSignMessage: transaction_t => JsBuffer.t = "getSignMessage";
};

module Obi = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: string => t = "Obi"
  @send external encodeInput: (t, 'a) => JsBuffer.t = "encodeInput"
  @send external encodeOutput: (t, 'a) => JsBuffer.t = "encodeOutput"
  @send external decodeInput: (t, JsBuffer.t) => 'a = "decodeInput"
  @send external decodeOutput: (t, JsBuffer.t) => 'a = "decodeOutput"
}
