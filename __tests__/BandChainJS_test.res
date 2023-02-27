open Jest
open BandChainJS
open Expect

let mnemonic = "mule way gather advance quote endorse boat liquid kite mad cart"

describe("Expect BandChainJS Client Module binding work correctly", () => {
  testPromise("getReferenceData", async () => {
    let client = Client.create("https://laozi-testnet6.bandchain.org/grpc-web")
    let prom = client->Client.getReferenceData(["BTC/USD"], 3, 4)
    ->Promise.then(_ => Promise.resolve(pass))
    ->Promise.catch(_ => Promise.resolve(fail("")))

    await prom
  })
})

describe("Expect BandChainJS PrivateKey Module binding work correctly", () => {
  test("fromMnemonic then toPubkey", () =>
    expect(
      mnemonic
      -> PrivateKey.fromMnemonic("m/44'/494'/0'/0/0")
      -> PrivateKey.toPubkey
      -> PubKey.toAddress 
      -> Address.toAccBech32
    )->toEqual("band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj"))
})

describe("Expect BandChainJS Address Module binding work correctly", () => {
  test("create Address fromhex and call toHex", () =>
    expect(
      "0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66"->Address.fromHex->Address.toHex
    )->toEqual("0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66"))
})

describe("Expect BandChainJS PubKey Module binding work correctly", () => {
  test("create PubKey fromhex and call toHex", () =>
    expect(
      "0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66"->PubKey.fromHex->PubKey.toHex
    )->toEqual("0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66"))

  test("toBech32", () =>
    expect(
      mnemonic
      -> PrivateKey.fromMnemonic("m/44'/494'/0'/0/0")
      -> PrivateKey.toPubkey
      -> PubKey.toBech32("band")
    )->toEqual("band1addwnpepqvzkxlgphmkh4z0wg5lrpsrrgfl7hymwtfz5kzgmmdvwqk70hq67vyrctrw"))

  test("toAddress", () =>
    expect(
      mnemonic
      -> PrivateKey.fromMnemonic("m/44'/494'/0'/0/0")
      -> PrivateKey.toPubkey
      ->PubKey.toAddress
      ->Address.toAccBech32
    )
    ->toEqual("band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj")
  )
})

describe("Expect BandChainJS Coin Module binding work correctly", () => {
  test("create Coin setDenom getDenom", () =>
    expect({
      let coin = Coin.create()
      coin->Coin.setDenom("uband")
      coin->Coin.getDenom
    })->toEqual("uband")
  )

  test("create Coin setAmount getAmount", () =>
    expect({
      let coin = Coin.create()
      coin->Coin.setAmount("100000")
      coin->Coin.getAmount
    })->toEqual("100000")
  )
})

describe("Expect BandChainJS Fee Module binding work correctly", () => {
  test("setAmountList getAmountList", () =>
    expect({
      let feeCoin = Coin.create()
      feeCoin -> Coin.setDenom("uband")
      feeCoin -> Coin.setAmount("10000")

      let fee = Fee.create()
      fee->Fee.setAmountList([feeCoin])
      fee->Fee.getAmountList->(coins => coins[0]->Coin.getAmount)
    })->toEqual("10000")
  )

  test("setGasLimit getGasLimit", () =>
    expect({
      let fee = Fee.create()
      fee->Fee.setGasLimit(1000000)
      fee->Fee.getGasLimit
    })->toEqual(1000000)
  )

  test("setPayer getPayer", () =>
    expect({
      let fee = Fee.create()
      fee->Fee.setPayer("band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj")
      fee->Fee.getPayer
    })->toEqual("band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj")
  )

  test("setGranter getGranter", () =>
    expect({
      let fee = Fee.create()
      fee->Fee.setGranter("band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj")
      fee->Fee.getGranter
    })->toEqual("band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj")
  )
})
