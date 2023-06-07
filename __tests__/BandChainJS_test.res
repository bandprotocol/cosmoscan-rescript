open Jest
open BandChainJS
open Expect

let mnemonic = "test"

describe("Expect BandChainJS Client Module binding work correctly", () => {
  testPromise("getReferenceData", async () => {
    let client = Client.create("https://laozi-testnet6.bandchain.org/grpc-web")
    let prom =
      client
      ->Client.getReferenceData(["BTC/USD"], 3, 4)
      ->Promise.then(_ => Promise.resolve(pass))
      ->Promise.catch(_ => Promise.resolve(fail("")))

    await prom
  })
})

describe("Expect BandChainJS PrivateKey Module binding work correctly", () => {
  test("fromMnemonic then toPubkey", () =>
    expect(
      mnemonic
      ->PrivateKey.fromMnemonic("m/44'/494'/0'/0/0")
      ->PrivateKey.toPubkey
      ->PubKey.toAddress
      ->Address.toAccBech32,
    )->toEqual("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph")
  )
})

describe("Expect BandChainJS Address Module binding work correctly", () => {
  test("create Address fromhex and call toHex", () =>
    expect(
      "0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66"
      ->Address.fromHex
      ->Address.toHex,
    )->toEqual("0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66")
  )
})

describe("Expect BandChainJS PubKey Module binding work correctly", () => {
  test("create PubKey fromhex and call toHex", () =>
    expect(
      "0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66"
      ->PubKey.fromHex
      ->PubKey.toHex,
    )->toEqual("0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66")
  )

  test("toBech32", () =>
    expect(
      mnemonic
      ->PrivateKey.fromMnemonic("m/44'/494'/0'/0/0")
      ->PrivateKey.toPubkey
      ->PubKey.toBech32("band"),
    )->toEqual("band1addwnpepqt79xhl2m49qfpre5jf9td3q64y8r9cxwm26fmzaug2vsrfcwsg0v70ls97")
  )

  test("toAddress", () =>
    expect(
      mnemonic
      ->PrivateKey.fromMnemonic("m/44'/494'/0'/0/0")
      ->PrivateKey.toPubkey
      ->PubKey.toAddress
      ->Address.toAccBech32,
    )->toEqual("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph")
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
      feeCoin->Coin.setDenom("uband")
      feeCoin->Coin.setAmount("10000")

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

describe("Expect BandChainJS Message Module binding work correctly", () => {
  test("MsgSend", () =>
    expect({
      let coin = Coin.create()
      coin->Coin.setDenom("uband")
      coin->Coin.setAmount("1000000")

      Message.MsgSend.create(
        "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
        "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu",
        [coin],
      )
      ->Message.MsgSend.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"cosmos-sdk/MsgSend","value":{"from_address":"band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj","to_address":"band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu","amount":[{"denom":"uband","amount":"1000000"}]}}`),
    )
  )

  test("MsgDelegate", () =>
    expect({
      let coin = Coin.create()
      coin->Coin.setDenom("uband")
      coin->Coin.setAmount("1000000")

      Message.MsgDelegate.create(
        "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
        "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
        coin,
      )
      ->Message.MsgDelegate.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"cosmos-sdk/MsgDelegate","value":{"delegator_address":"band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj","validator_address":"bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv","amount":{"denom":"uband","amount":"1000000"}}}`),
    )
  )

  test("MsgUndelegate", () =>
    expect({
      let coin = Coin.create()
      coin->Coin.setDenom("uband")
      coin->Coin.setAmount("1000000")

      Message.MsgUndelegate.create(
        "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
        "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
        coin,
      )
      ->Message.MsgUndelegate.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"cosmos-sdk/MsgUndelegate","value":{"delegator_address":"band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj","validator_address":"bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv","amount":{"denom":"uband","amount":"1000000"}}}`),
    )
  )

  test("MsgRedelegate", () =>
    expect({
      let coin = Coin.create()
      coin->Coin.setDenom("uband")
      coin->Coin.setAmount("1000000")

      Message.MsgRedelegate.create(
        "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
        "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
        "bandvaloper1kfj48adjsnrgu83lau6wc646q2uf65rf84tzus",
        coin,
      )
      ->Message.MsgRedelegate.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"cosmos-sdk/MsgBeginRedelegate","value":{"delegator_address":"band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj","validator_src_address":"bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv","validator_dst_address":"bandvaloper1kfj48adjsnrgu83lau6wc646q2uf65rf84tzus","amount":{"denom":"uband","amount":"1000000"}}}`),
    )
  )

  test("MsgWithdrawReward", () =>
    expect({
      Message.MsgWithdrawReward.create(
        "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
        "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
      )
      ->Message.MsgWithdrawReward.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"cosmos-sdk/MsgWithdrawDelegationReward","value":{"delegator_address":"band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj","validator_address":"bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv"}}`),
    )
  )

  test("MsgVote", () =>
    expect({
      Message.MsgVote.create(2, "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj", 1)
      ->Message.MsgVote.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"cosmos-sdk/MsgVote","value":{"proposal_id":"2","voter":"band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj","option":1}}`),
    )
  )

  test("MsgRequest", () =>
    expect({
      let privKey = PrivateKey.fromMnemonic(mnemonic, "m/44'/494'/0'/0/0")
      let pub = privKey->PrivateKey.toPubkey
      let address = pub->PubKey.toAddress->Address.toAccBech32

      let obi = Obi.create("{symbols:[string],multiplier:u64}/{rates:[u64]}")
      let calldata = Obi.encodeInput(
        obi,
        `{ "symbols": ["ETH"], "multiplier": 100 }`->Js.Json.parseExn,
      )

      let coin = Coin.create()
      coin->Coin.setDenom("uband")
      coin->Coin.setAmount("1000000")

      let feeCoin = Coin.create()
      feeCoin->Coin.setDenom("uband")
      feeCoin->Coin.setAmount("10000")

      Message.MsgRequest.create(
        37,
        calldata,
        4,
        3,
        "BandProtocol",
        address,
        [coin],
        Some(50000),
        Some(200000),
      )
      ->Message.MsgRequest.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"oracle/Request","value":{"ask_count":"4","calldata":"AAAAAQAAAANFVEgAAAAAAAAAZA==","oracle_script_id":"37","min_count":"3","client_id":"BandProtocol","sender":"band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph","fee_limit":[{"denom":"uband","amount":"1000000"}],"prepare_gas":"50000","execute_gas":"200000"}}`),
    )
  )

  test("MsgTransfer", () =>
    expect({
      let coin = Coin.create()
      coin->Coin.setDenom("uband")
      coin->Coin.setAmount("1000000")

      Message.MsgTransfer.create(
        "transfer",
        "channel-25",
        "band13eznuehmqzd3r84fkxu8wklxl22r2qfmtlth8c",
        "cosmos15d4apf20449ajvwycq8ruaypt7v6d34522frnd",
        coin,
        1677512323000., // mock timeoutTimestamp
      )
      ->Message.MsgTransfer.toJSON
      ->Js.Json.stringifyAny
    })->toEqual(
      Some(`{"type":"cosmos-sdk/MsgTransfer","value":{"source_port":"transfer","source_channel":"channel-25","sender":"band13eznuehmqzd3r84fkxu8wklxl22r2qfmtlth8c","receiver":"cosmos15d4apf20449ajvwycq8ruaypt7v6d34522frnd","token":{"denom":"uband","amount":"1000000"},"timeout_height":{},"timeout_timestamp":"1677512323000"}}`),
    )
  )
})

describe("Expect BandChainJS Transaction Module binding work correctly", () => {
  testPromise("create Address fromhex and call toHex", async () => {
    let privKey = PrivateKey.fromMnemonic(mnemonic, "m/44'/494'/0'/0/0")
    let pub = privKey->PrivateKey.toPubkey
    let address = pub->PubKey.toAddress->Address.toAccBech32

    let coin = Coin.create()
    coin->Coin.setDenom("uband")
    coin->Coin.setAmount("1000000")

    let feeCoin = Coin.create()
    feeCoin->Coin.setDenom("uband")
    feeCoin->Coin.setAmount("10000")

    let fee = Fee.create()
    fee->Fee.setAmountList([feeCoin])
    fee->Fee.setGasLimit(1000000)

    let sendMsg = Message.MsgSend.create(
      address,
      "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu",
      [coin],
    )

    let client = Client.create("https://laozi-testnet6.bandchain.org/grpc-web")
    let account = await client->Client.getAccount(address)
    let chainID = await client->Client.getChainId

    let txn = Transaction.create()
    txn->Transaction.withMessages(sendMsg)
    txn->Transaction.withAccountNum(account.accountNumber)
    txn->Transaction.withSequence(account.sequence)
    txn->Transaction.withChainId(chainID)
    txn->Transaction.withFee(fee)

    let signDoc = txn->Transaction.getSignDoc(pub)
    let signature = privKey->PrivateKey.sign(signDoc)

    let signedTx = txn->Transaction.getTxData(signature, pub, 1)
    let prom =
      client
      ->Client.sendTxBlockMode(signedTx)
      ->Promise.then(_ => Promise.resolve(pass))
      ->Promise.catch(_ => Promise.resolve(fail("")))

    await prom
  })
})
