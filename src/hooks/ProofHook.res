module Proof = {
  type t = {
    jsonProof: Js.Json.t,
    evmProofBytes: JsBuffer.t,
  }

  let decodeProof = {
    open JsonUtils.Decode
    buildObject(json => {
      jsonProof: json.required(list{"result", "proof"}, id),
      evmProofBytes: json.required(
        list{"result", "evm_proof_bytes"},
        string->map((. a) => JsBuffer.fromHex(a)),
      ),
    })
  }
}

let get = (requestId: ID.Request.t) => {
  let id = ID.Request.toInt(requestId)

  let (json, reload) = AxiosHooks.useWithReload({j`oracle/bandchain/v1/oracle/proof/$id`})

  (json->Belt.Option.map(json => JsonUtils.Decode.mustDecode(json, Proof.decodeProof)), reload)
}
