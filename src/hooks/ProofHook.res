module Proof = {
  type t = {
    jsonProof: Js.Json.t,
    evmProofBytes: JsBuffer.t,
  }

  let decodeProof = {
    open JsonUtils.Decode
    buildObject(json => {
      jsonProof: json.at(list{"result", "proof"}, id),
      evmProofBytes: json.at(
        list{"result", "evm_proof_bytes"},
        string->map((. a) => JsBuffer.fromHex(a)),
      ),
    })
  }
}

let get = (requestId: ID.Request.t) => {
  let stringId =  requestId->ID.Request.toInt
  let (json, reload) = AxiosHooks.useWithReload({j`oracle/proof/$stringId`})
  (json->Belt.Option.map(json => JsonUtils.Decode.mustDecode(json, Proof.decodeProof)), reload)
}
