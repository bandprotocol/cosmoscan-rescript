open Jest
open GraphQLParser
open Expect

describe("Expect GraphQLParser to work correctly", () => {
  test("int64", () =>
    expect({
      let json = `"123"`->Js.Json.parseExn

      json->int64
    })->toBe(123)
  )

  test("string", () =>
    expect({
      let json = `"test"`->Js.Json.parseExn

      json->string
    })->toBe("test")
  )

  test("jsonToStringExn", () =>
    expect({
      let jsonOpt = Some(`"test"`->Js.Json.parseExn)

      jsonOpt->jsonToStringExn
    })->toBe("test")
  )

  test("buffer", () =>
    expect({
      let json =
        `"0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"`->Js.Json.parseExn

      json->buffer
    })->toEqual(
      "0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"->JsBuffer.fromHex,
    )
  )

  test("timeS", () =>
    expect({
      let json = `1683785808`->Js.Json.parseExn

      json->timeS
    })->toEqual(1683785808->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc)
  )

  test("fromUnixSecondOpt", () =>
    expect({
      Some(1683785808)->fromUnixSecondOpt
    })->toEqual(Some(1683785808->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc))
  )

  test("fromUnixSecondOpt None", () => expect(None->fromUnixSecondOpt)->toEqual(None))

  test("fromUnixSecond", () =>
    expect({
      1683785808->fromUnixSecond
    })->toEqual(1683785808->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc)
  )

  test("timeMS", () =>
    expect({
      let json = `1683785808000`->Js.Json.parseExn

      json->timeMS
    })->toEqual(1683785808->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc)
  )

  test("timestamp", () =>
    expect({
      let json = `"2023-05-11T06:24:46.511Z"`->Js.Json.parseExn

      json->timestamp
    })->toEqual("2023-05-11T06:24:46.511Z"->MomentRe.momentUtcDefaultFormat)
  )

  test("timestampOpt", () =>
    expect({
      let json = `"2023-05-11T06:24:46.511Z"`->Js.Json.parseExn

      Some(json)->timestampOpt
    })->toEqual(Some("2023-05-11T06:24:46.511Z"->MomentRe.momentUtcDefaultFormat))
  )

  test("timestampOpt None", () => expect(None->timestampOpt)->toEqual(None))

  test("timestampWithDefault", () =>
    expect({
      let json = `"2023-05-11T06:24:46.511Z"`->Js.Json.parseExn

      Some(json)->timestampWithDefault
    })->toEqual("2023-05-11T06:24:46.511Z"->MomentRe.momentUtcDefaultFormat)
  )

  // Compare with the second level to prevent potential failures from executing MomentRe.momentNow().
  test("timestampWithDefault Default case", () =>
    expect(None->timestampWithDefault->MomentRe.Moment.toUnix)->toEqual(
      MomentRe.momentNow()->MomentRe.Moment.toUnix,
    )
  )

  test("stringExn", () => expect({Some("test")->stringExn})->toEqual("test"))

  test("optionBuffer", () =>
    expect({
      let json =
        `"0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"`->Js.Json.parseExn

      Some(json)->optionBuffer
    })->toEqual(
      Some(
        "0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58"->JsBuffer.fromHex,
      ),
    )
  )

  test("optionBuffer None", () => expect(None->optionBuffer)->toEqual(None))

  test("optionTimeS", () =>
    expect({
      let json = `1683785808`->Js.Json.parseExn

      Some(json)->optionTimeS
    })->toEqual(Some(1683785808->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc))
  )

  test("optionTimeS None", () => expect(None->optionTimeS)->toEqual(None))

  test("optionTimeMS", () =>
    expect({
      let json = `1683785808000`->Js.Json.parseExn

      Some(json)->optionTimeMS
    })->toEqual(Some(1683785808->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc))
  )

  test("optionTimeMS None", () => expect(None->optionTimeMS)->toEqual(None))

  test("optionTimeSExn", () =>
    expect({
      let json = `1683785808`->Js.Json.parseExn

      Some(json)->optionTimeSExn
    })->toEqual(1683785808->MomentRe.momentWithUnix->MomentRe.Moment.defaultUtc)
  )

  test("bool", () =>
    expect({
      let json = `false`->Js.Json.parseExn

      json->bool
    })->toBe(false)
  )

  test("hash", () =>
    expect({
      let json =
        `"0x1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51"`->Js.Json.parseExn

      json->hash
    })->toEqual("1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51"->Hash.fromHex)
  )

  test("intToCoin", () =>
    expect({
      12345678->intToCoin
    })->toEqual(12345678.->Coin.newUBANDFromAmount)
  )

  test("coin", () =>
    expect({
      let json = `"123.00"`->Js.Json.parseExn

      json->coin
    })->toEqual(123.00->Coin.newUBANDFromAmount)
  )

  test("coinExn", () =>
    expect({
      let json = `"123.00"`->Js.Json.parseExn

      Some(json)->coinExn
    })->toEqual(123.00->Coin.newUBANDFromAmount)
  )

  test("coinWithDefault", () =>
    expect({
      let json = `"123.00"`->Js.Json.parseExn

      Some(json)->coinWithDefault
    })->toEqual(123.00->Coin.newUBANDFromAmount)
  )

  test("coinWithDefault Default case", () =>
    expect(None->coinWithDefault)->toEqual(0.->Coin.newUBANDFromAmount)
  )

  test("coinStr", () => expect("1674740"->coinStr)->toEqual(1674740.->Coin.newUBANDFromAmount))

  test("coins", () => expect("123uband"->coins)->toEqual(list{123.->Coin.newUBANDFromAmount}))

  test("coins not in the right format", () => expect({"uband123"->coins})->toEqual(list{}))

  test("coins empty", () => expect({""->coins})->toEqual(list{}))

  test("addressExn", () =>
    expect({
      Some("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph")->addressExn
    })->toEqual("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32)
  )

  test("addressOpt", () =>
    expect({
      Some("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph")->addressOpt
    })->toEqual(Some("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32))
  )

  test("addressOpt None", () => expect(None->addressOpt)->toEqual(None))

  test("numberWithDefault", () =>
    expect({
      let json = `123.00`->Js.Json.parseExn

      Some(json)->numberWithDefault
    })->toEqual(123.00)
  )

  test("numberWithDefault not a number", () =>
    expect({
      let json = `"test"`->Js.Json.parseExn

      Some(json)->numberWithDefault
    })->toEqual(0.)
  )

  test("numberWithDefault None", () => expect(None->numberWithDefault)->toEqual(0.))

  test("floatWithDefault", () =>
    expect({
      let json = `"123.0"`->Js.Json.parseExn

      Some(json)->floatWithDefault
    })->toEqual(123.0)
  )

  test("floatWithDefault Default case", () => expect(None->floatWithDefault)->toEqual(0.0))

  test("floatString", () =>
    expect({
      let json = `"123.0"`->Js.Json.parseExn

      json->floatString
    })->toEqual(123.0)
  )

  test("floatExn", () =>
    expect({
      let json = `123.0`->Js.Json.parseExn

      json->floatExn
    })->toEqual(123.0)
  )
})
