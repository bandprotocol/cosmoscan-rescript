open Jest
open Expect

describe("Expect Date Module to work correctly", () => {
  open GraphQLParserModule.Date

  test("parse", () => expect({
    let json = `"2022-10-09T18:12:23.378Z"`->Js.Json.parseExn

    json->parse
  })->toEqual("2022-10-09T18:12:23.378Z"->MomentRe.momentUtc))

  test("serialize", () => expect({
    let json = `"2022-10-09T18:12:23.378Z"`->Js.Json.parseExn
    let instance = json->parse

    instance->serialize
  })->toEqual("2022-10-09T18:12:23.378Z"->Js.Json.string))
})

describe("Expect Hash Module to work correctly", () => {
  open GraphQLParserModule.Hash

  test("parse", () => expect({
    let json = `"0x28913c89fa628136fffce7ded99d65a4e3f5c211f82639fed4adca30d53b8dff"`->Js.Json.parseExn

    json->parse
  })->toEqual("0x28913c89fa628136fffce7ded99d65a4e3f5c211f82639fed4adca30d53b8dff"->Hash.fromHex))

  test("serialize", () => expect({
    let json = `"0x28913c89fa628136fffce7ded99d65a4e3f5c211f82639fed4adca30d53b8dff"`->Js.Json.parseExn
    let instance = json->parse

    instance->serialize
  })->toEqual("28913c89fa628136fffce7ded99d65a4e3f5c211f82639fed4adca30d53b8dff"->Js.Json.string))
})

describe("Expect String Module to work correctly", () => {
  open GraphQLParserModule.String

  test("parse", () => expect({
    let json = `"test"`->Js.Json.parseExn

    json->parse
  })->toBe("test"))

  test("serialize", () => expect({
    let json = `"test"`->Js.Json.parseExn
    let instance = json->parse

    instance->serialize
  })->toEqual("test"->Js.Json.string))
})

describe("Expect FromUnixSecond Module to work correctly", () => {
  open GraphQLParserModule.FromUnixSecond

  test("parse", () => expect({
    1684230308->parse
  })->toEqual(1684230308->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc))

  test("serialize", () => expect({
    let instance = 1684230308->parse

    instance->serialize
  })->toBe(1684230308))
})

describe("Expect FloatExn Module to work correctly", () => {
  open GraphQLParserModule.FloatExn

  test("parse", () => expect({
    let json = `123.456`->Js.Json.parseExn

    json->parse
  })->toBe(123.456))

  test("parse not a Number", () => expect(() => {
    let json = `test`->Js.Json.parseExn

    json->parse
  })->toThrow)

  test("serialize", () => expect({
    let json = `123.456`->Js.Json.parseExn
    let instance = json->parse

    instance->serialize
  })->toEqual(`123.456`->Js.Json.parseExn))
})

describe("Expect FloatString Module to work correctly", () => {
  open GraphQLParserModule.FloatString

  test("parse", () => expect({
    let json = `"123.456"`->Js.Json.parseExn

    json->parse
  })->toBe(123.456))

  test("parse not a Number", () => expect(() => {
    let json = `test`->Js.Json.parseExn

    json->parse
  })->toThrow)


  test("serialize", () => expect({
    let json = `"123.456"`->Js.Json.parseExn
    let instance = json->parse

    instance->serialize
  })->toEqual("123.456"->Js.Json.string))
})

describe("Expect FloatWithDefault Module to work correctly", () => {
  open GraphQLParserModule.FloatWithDefault

  test("parse", () => expect({
    let json = `"123.456"`->Js.Json.parseExn

    Some(json)->parse
  })->toBe(123.456))

  test("parse default", () => expect(None->parse)->toEqual(0.))

  test("serialize", () => expect({
    let json = `"123.456"`->Js.Json.parseExn
    let instance = Some(json)->parse

    instance->serialize
  })->toEqual(Some("123.456"->Js.Json.parseExn)))
})

describe("Expect FloatStringExn Module to work correctly", () => {
  open GraphQLParserModule.FloatStringExn

  test("parse", () => expect("123.456"->parse)->toBe(123.456))
  test("parse not a number", () => expect(() => "test"->parse)->toThrow)

  test("serialize", () => expect({"123.456"->parse->serialize})->toBe("123.456"))
})

describe("Expect AddressOpt Module to work correctly", () => {
  open GraphQLParserModule.AddressOpt

  test("parse", () => expect(
    Some("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph")->parse
  )->toEqual(Some("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32)))

  test("parse recieve None", () => expect(None->parse)->toEqual(None))

  test("parse not Address", () => expect(() => Some("test")->parse)->toThrow)

  test("serialize", () => expect(
    Some("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32)->serialize
  )->toEqual(Some("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph")))

  test("serialize recieve None", () => expect(None->serialize)->toEqual(None))
})

describe("Expect Address Module to work correctly", () => {
  open GraphQLParserModule.Address

  test("parse", () => expect(
    "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->parse
  )->toEqual("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32))

  test("parse not Address", () => expect(() => "test"->parse)->toThrow)

  test("serialize", () => expect(
    "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32->serialize
  )->toEqual("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"))
})

describe("Expect Coins Module to work correctly", () => {
  open GraphQLParserModule.Coins

  test("parse", () => expect(
    "1000uband,3000uband"->parse
  )->toEqual(list{Coin.newCoin("uband", 1000.), Coin.newCoin("uband", 3000.)}))

  test("serialize", () => expect(
    list{Coin.newCoin("uband", 1000.), Coin.newCoin("uband", 3000.)}->serialize
  )->toEqual("1000uband, 3000uband"))
})

describe("Expect CoinWithDefault Module to work correctly", () => {
  open GraphQLParserModule.CoinWithDefault

  test("parse", () => expect({
    let json = `"3000uband"`->Js.Json.parseExn

    Some(json)->parse
  })->toEqual(Coin.newCoin("uband", 3000.)))

  test("parse default case", () => expect(None->parse)->toEqual(Coin.newCoin("uband", 0.)))

  test("serialize", () => expect(Coin.newCoin("uband", 3000.)->serialize)->toEqual(Some("3000uband"->Js.Json.string)))
})

describe("Expect Coin Module to work correctly", () => {
  open GraphQLParserModule.Coin

  test("parse", () => expect({
    let json = `"3000uband"`->Js.Json.parseExn

    json->parse
  })->toEqual(Coin.newCoin("uband", 3000.)))

  test("serialize", () => expect(Coin.newCoin("uband", 3000.)->serialize)->toEqual("3000uband"->Js.Json.string))
})

describe("Expect Buffer Module to work correctly", () => {
  open GraphQLParserModule.Buffer

  test("parse", () => expect({
    let json = `"0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"`->Js.Json.parseExn

    json->parse
  })->toEqual("0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"->JsBuffer.fromHex))

  test("serialize", () => expect({
      let json = `"0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"`->Js.Json.parseExn
      json->parse->serialize
    })
    ->toEqual("0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"->Js.Json.string)
  )
})

describe("Expect BufferOpt Module to work correctly", () => {
  open GraphQLParserModule.BufferOpt

  test("parse", () => expect({
    let json = `"0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"`->Js.Json.parseExn

    Some(json)->parse
  })->toEqual(Some("0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"->JsBuffer.fromHex)))

  test("parse recieve None", () => expect(None->parse)->toEqual(None))

  test("serialize", () => expect({
      let json = `"0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"`->Js.Json.parseExn
      Some(json)->parse->serialize
    })
    ->toEqual(Some("0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"->Js.Json.string))
  )

  test("serialize recieve None", () => expect(None->serialize)->toEqual(None))
})

describe("Expect BlockID Module to work correctly", () => {
  open GraphQLParserModule.BlockID

  test("parse", () => expect({
    123->parse
  })->toEqual(123->ID.Block.fromInt))

  test("serialize", () => expect({
    123->ID.Block.fromInt->serialize
  })->toBe(123))
})

describe("Expect ProposalID Module to work correctly", () => {
  open GraphQLParserModule.ProposalID

  test("parse", () => expect({
    123->parse
  })->toEqual(123->ID.Proposal.fromInt))

  test("serialize", () => expect({
    123->ID.Proposal.fromInt->serialize
  })->toBe(123))
})

describe("Expect OracleScriptID Module to work correctly", () => {
  open GraphQLParserModule.OracleScriptID

  test("parse", () => expect({
    123->parse
  })->toEqual(123->ID.OracleScript.fromInt))

  test("serialize", () => expect({
    123->ID.OracleScript.fromInt->serialize
  })->toBe(123))
})

describe("Expect DataSourceID Module to work correctly", () => {
  open GraphQLParserModule.DataSourceID

  test("parse", () => expect({
    123->parse
  })->toEqual(123->ID.DataSource.fromInt))

  test("serialize", () => expect({
    123->ID.DataSource.fromInt->serialize
  })->toBe(123))
})

describe("Expect RequestID Module to work correctly", () => {
  open GraphQLParserModule.RequestID

  test("parse", () => expect({
    123->parse
  })->toEqual(123->ID.Request.fromInt))

  test("serialize", () => expect({
    123->ID.Request.fromInt->serialize
  })->toBe(123))
})
