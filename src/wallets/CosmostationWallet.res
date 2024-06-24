type t = CosmostationClient.Cosmos.account

let getAddressAndPubKey = (x: t) => {
  Promise.resolve((x.address->Address.fromBech32, x.publicKey->JsBuffer.arrayToHex->PubKey.fromHex))
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
  let provider = await CosmostationClient.cosmos()
  let account = await provider.getAccount(chainID)

  account
}
