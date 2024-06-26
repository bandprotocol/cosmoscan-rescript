type t = Leap.key

let getAddressAndPubKey = (x: t) => {
  Promise.resolve((
    x.bech32Address->Address.fromBech32,
    x.pubKey->JsBuffer.arrayToHex->PubKey.fromHex,
  ))
}

let sign = async (x: t, rawTx: BandChainJS.Transaction.transaction_t) => {
  let signResponse = await Leap.signAmino(
    rawTx.chainId->Belt.Option.getExn,
    x.bech32Address,
    Leap.getAminoSignDocFromTx(rawTx),
    {
      preferNoSetFee: true,
      preferNoSetMemo: false,
      disableBalanceCheck: false,
    },
  )

  signResponse.signature.signature->JsBuffer.fromBase64
}

let connect = async chainID => {
  await Leap.enable(chainID)
  let account = await Leap.getKey(chainID)

  account
}
