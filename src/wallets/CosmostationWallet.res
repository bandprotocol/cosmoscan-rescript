type t = Cosmostation.request_account_response_t
let getAddressAndPubKey = (account: t) => {
  Promise.resolve((
    account.address->Address.fromBech32,
    account.publicKey->JsBuffer.arrayToHex->PubKey.fromHex,
  ))
}

let sign = async (x: t, rawTx: BandChainJS.Transaction.transaction_t) => {
  let signResponse = await Cosmostation.signAmino(
    rawTx.chainId->Belt.Option.getExn,
    Cosmostation.getAminoSignDocFromTx(rawTx),
  )

  signResponse.signature->JsBuffer.fromBase64
}

let connect = async chainID => {
  let account = await Cosmostation.requestAccount(chainID)

  account
}
