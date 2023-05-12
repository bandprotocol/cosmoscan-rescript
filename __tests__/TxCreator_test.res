open Jest
open TxCreator
open Expect

describe("Expect createMsg Functionality to work correctly", () => {
  test("SendMsg", () => expect({
    let coin = Coin.newCoin("uband", 1000000.)

    createMsg(Msg.Input.SendMsg({
      fromAddress: "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj"->Address.fromBech32, 
      toAddress: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32, 
      amount: list{coin}
    }))
  })->toEqual({
    open BandChainJS
    let coin = Coin.create()
    coin->Coin.setDenom("uband")
    coin->Coin.setAmount("1000000")

    Message.MsgSend.create(
      "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
      "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu",
      [coin],
    )
  }))

  test("RequestMsg", () => expect({
      let privKey = BandChainJS.PrivateKey.fromMnemonic("test", "m/44'/494'/0'/0/0")
      let pub = privKey->BandChainJS.PrivateKey.toPubkey

      let obi = BandChainJS.Obi.create("{symbols:[string],multiplier:u64}/{rates:[u64]}")
      let calldata = BandChainJS.Obi.encodeInput(
        obi,
        `{ "symbols": ["ETH"], "multiplier": 100 }`->Js.Json.parseExn,
      )

      let feeCoin = Coin.newCoin("uband", 10000.)

    createMsg(
      Msg.Input.RequestMsg({
        oracleScriptID: 37->ID.OracleScript.fromInt,
        calldata,
        askCount: 4,
        minCount: 3,
        sender: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
        clientID: "BandProtocol",
        feeLimit: list{feeCoin},
        prepareGas: 50000,
        executeGas: 200000,
        id: (),
        oracleScriptName: (),
        schema: (),
      }),
    )
  })->toEqual({
    open BandChainJS
    let obi = Obi.create("{symbols:[string],multiplier:u64}/{rates:[u64]}")
    let calldata = Obi.encodeInput(
      obi,
      `{ "symbols": ["ETH"], "multiplier": 100 }`->Js.Json.parseExn,
    )

    let coin = Coin.create()
    coin->Coin.setDenom("uband")
    coin->Coin.setAmount("10000")

    Message.MsgRequest.create(
      37,
      calldata,
      4,
      3,
      "BandProtocol",
      "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu",
      [coin],
      Some(50000),
      Some(200000),
    )
  }))

  test("DelegateMsg", () => expect({
    let coin = Coin.newCoin("uband", 1000000.)

    createMsg(Msg.Input.DelegateMsg({
      delegatorAddress: "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj"->Address.fromBech32,
      validatorAddress: "band18aqvecak05emvl3hjff40swq0m6t9n4m42rcj8"->Address.fromBech32,
      amount: coin,
      moniker: (),
      identity: (),
    }))
  })->toEqual({
    open BandChainJS
    let coin = Coin.create()
    coin->Coin.setDenom("uband")
    coin->Coin.setAmount("1000000")

    Message.MsgDelegate.create(
      "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
      "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
      coin,
    )
  }))

  test("UndelegateMsg", () => expect({
    let coin = Coin.newCoin("uband", 1000000.)

    createMsg(Msg.Input.UndelegateMsg({
      delegatorAddress: "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj"->Address.fromBech32,
      validatorAddress: "band18aqvecak05emvl3hjff40swq0m6t9n4m42rcj8"->Address.fromBech32,
      amount: coin,
      moniker: (),
      identity: (),
    }))
  })->toEqual({
    open BandChainJS
    let coin = Coin.create()
    coin->Coin.setDenom("uband")
    coin->Coin.setAmount("1000000")

    Message.MsgUndelegate.create(
      "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
      "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
      coin,
    )
  }))

  test("RedelegateMsg", () => expect({
    let coin = Coin.newCoin("uband", 1000000.)

    createMsg(Msg.Input.RedelegateMsg({
      delegatorAddress: "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj"->Address.fromBech32,
      validatorSourceAddress: "band18aqvecak05emvl3hjff40swq0m6t9n4m42rcj8"->Address.fromBech32,
      validatorDestinationAddress: "band1kfj48adjsnrgu83lau6wc646q2uf65rftr0pem"->Address.fromBech32,
      amount: coin,
      monikerSource: (),
      monikerDestination: (),
      identitySource: (),
      identityDestination: (),
    }))
  })->toEqual({
    open BandChainJS
    let coin = Coin.create()
    coin->Coin.setDenom("uband")
    coin->Coin.setAmount("1000000")

    Message.MsgRedelegate.create(
      "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
      "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
      "bandvaloper1kfj48adjsnrgu83lau6wc646q2uf65rf84tzus",
      coin,
    )
  }))

  test("WithdrawRewardMsg", () => expect({
    createMsg(Msg.Input.WithdrawRewardMsg({
      delegatorAddress: "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj"->Address.fromBech32,
      validatorAddress: "band18aqvecak05emvl3hjff40swq0m6t9n4m42rcj8"->Address.fromBech32,
      amount: (),
      moniker: (),
      identity: (),
    }))
  })->toEqual({
    open BandChainJS
    let coin = Coin.create()
    coin->Coin.setDenom("uband")
    coin->Coin.setAmount("1000000")

    Message.MsgWithdrawReward.create(
      "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj",
      "bandvaloper18aqvecak05emvl3hjff40swq0m6t9n4meu8mhv",
    )
  }))

  test("VoteMsg", () => expect({
    createMsg(Msg.Input.VoteMsg({
      proposalID: 10->ID.Proposal.fromInt,
      voterAddress: "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj"->Address.fromBech32,
      option: 1,
    }))
  })->toEqual({
    BandChainJS.Message.MsgVote.create(10, "band1dgstnw0m2cshvh4ymnlcxdj0wr3x797efzrexj", 1)
  }))

  test("IBCTransfer", () => expect({
    createMsg(Msg.Input.IBCTransfer({
      sourcePort: "transfer",
      sourceChannel: "channel-25",
      receiver: "cosmos15d4apf20449ajvwycq8ruaypt7v6d34522frnd", // Hack: use text instead
      token: 1000000.->Coin.newUBANDFromAmount,
      timeoutTimestamp: 1677512323000.,
      sender: "band13eznuehmqzd3r84fkxu8wklxl22r2qfmtlth8c"->Address.fromBech32,
    }))
  })->toEqual({
    open BandChainJS
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
  }))
})

describe("Expect stringifyWithSpaces Functionality to work correctly", () => {
  test("stringifyWithSpaces", () => expect({
    let dict = Js.Dict.empty()
    Js.Dict.set(dict, "name", Js.Json.string("John Doe"))
    Js.Dict.set(dict, "age", Js.Json.number(30.0))
    Js.Dict.set(dict, "likes", Js.Json.stringArray(["bucklescript", "ocaml", "js"]))
    stringifyWithSpaces(Js.Json.object_(dict))
  })->toEqual(`{
    "name": "John Doe",
    "age": 30,
    "likes": [
        "bucklescript",
        "ocaml",
        "js"
    ]
}`))
})
