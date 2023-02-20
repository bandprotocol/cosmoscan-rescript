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
}

module Obi = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: string => t = "Obi"
  @send external encodeInput: (t, 'a) => JsBuffer.t = "encodeInput"
  @send external encodeOutput: (t, 'a) => JsBuffer.t = "encodeOutput"
  @send external decodeInput: (t, JsBuffer.t) => 'a = "decodeInput"
  @send external decodeOutput: (t, JsBuffer.t) => 'a = "decodeOutput"
}
