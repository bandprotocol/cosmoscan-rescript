type t = Cosmostation.request_account_response_t
let getAddressAndPubKey = (account: t) => {
  Promise.resolve((
    account.address->Address.fromBech32,
    account.publicKey->JsBuffer.arrayToHex->PubKey.fromHex,
  ))
}

let sign = async (x: t, rawTx: BandChainJS.Transaction.transaction_t) => {
  let provider = await CosmostationClient.cosmos()
  let signResponse = await provider.signAmino(
    rawTx.chainId->Belt.Option.getExn,
    CosmostationClient.Cosmos.getAminoSignDocFromTx(rawTx),
    None,
  )

  signResponse.signature->JsBuffer.fromBase64
}

let connect = async chainID => {
  let account = await Cosmostation.requestAccount(chainID)

  account
}
