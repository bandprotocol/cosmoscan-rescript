open Jest
open Mnemonic
open Expect

describe("Expect Mnemonic to work correctly", () => {
  let wallet = create("test")

  test("getAddressAndPubKey", () =>
    expect(wallet->getAddressAndPubKey)->toEqual((
      "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32,
      "AvxTX+rdSgSEeaSSVbYg1UhxlwZ21aTsXeIUyA04dBD2"->PubKey.fromBase64,
    ))
  )

  testPromise("sign", async () => {
    // open BandChainJS
    let (address, pub) = wallet->getAddressAndPubKey

    let coin = BandChainJS.Coin.create()
    coin->BandChainJS.Coin.setDenom("uband")
    coin->BandChainJS.Coin.setAmount("1000000")

    let feeCoin = BandChainJS.Coin.create()
    feeCoin->BandChainJS.Coin.setDenom("uband")
    feeCoin->BandChainJS.Coin.setAmount("10000")

    let fee = BandChainJS.Fee.create()
    fee->BandChainJS.Fee.setAmountList([feeCoin])
    fee->BandChainJS.Fee.setGasLimit(1000000)

    let sendMsg = BandChainJS.Message.MsgSend.create(
      address->Address.toBech32,
      "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu",
      [coin],
    )

    let client = BandChainJS.Client.create("https://laozi-testnet6.bandchain.org/grpc-web")
    let account = await client->BandChainJS.Client.getAccount(address->Address.toBech32)
    let chainID = await client->BandChainJS.Client.getChainId

    let txn = BandChainJS.Transaction.create()
    txn->BandChainJS.Transaction.withMessages(sendMsg)
    txn->BandChainJS.Transaction.withAccountNum(account.accountNumber)
    txn->BandChainJS.Transaction.withSequence(1) // fake sequence for test
    txn->BandChainJS.Transaction.withChainId(chainID)
    txn->BandChainJS.Transaction.withFee(fee)

    expect(wallet->sign(txn)->JsBuffer.toBase64)->toEqual(
      "uaa2v4DdQnpg6FOsR+eSjdsHzRKPNX2oarWcRDqeyyJK3EIwyPTF4uXiJ2tjcs3xpjYnqSZ6EfC6iND391DhSQ==",
    )
  })
})
