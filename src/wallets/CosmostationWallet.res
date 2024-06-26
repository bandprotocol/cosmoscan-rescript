type t = CosmosProvider.cosmos_request_account_t

let getAddressAndPubKey = (account: t) => {
  Promise.resolve((
    account.address->Address.fromBech32,
    account.public_key.value->PubKey.fromBase64,
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
