open Jest
open JsonUtils.Decode
open Expect

describe("Expect Decoder to work correctly", () => {
  test("intstr", () => expect({
    let json = `"123"`->Js.Json.parseExn

    json->mustDecode(intstr)
  })->toBe(123))

  test("hashFromHex", () => expect({
    let json = `"1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51"`->Js.Json.parseExn

    json->mustDecode(hashFromHex)
  })->toEqual(Hash.fromHex("1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51")))

  test("address", () => expect({
    let json = `"band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"`->Js.Json.parseExn

    json->mustDecode(address)
  })->toEqual(Address.fromBech32("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph")))

  test("moment", () => expect({
    let json = `"2023-05-10T07:25:16.058Z"`->Js.Json.parseExn

    json->mustDecode(moment)
  })->toEqual(MomentRe.moment("2023-05-10T07:25:16.058Z")))

  test("floatstr", () => expect({
    let json = `"1.23"`->Js.Json.parseExn

    json->mustDecode(floatstr)
  })->toBe(1.23))

  test("intWithDefault", () => expect({
    let json = `123`->Js.Json.parseExn

    json->mustDecode(intWithDefault(0))
  })->toBe(123))

  test("intWithDefault default case", () => expect({
    let json = `null`->Js.Json.parseExn

    json->mustDecode(intWithDefault(0))
  })->toBe(0))

  test("bufferWithDefault", () => expect({
    let json = `"SGVsbG8gV29ybGQ="`->Js.Json.parseExn

    json->mustDecode(bufferWithDefault)
  })->toEqual(JsBuffer.fromBase64("SGVsbG8gV29ybGQ=")))

  test("bufferWithDefault default case", () => expect({
    let json = `null`->Js.Json.parseExn

    json->mustDecode(bufferWithDefault)
  })->toEqual(JsBuffer.from([])))

  test("strWithDefault", () => expect({
    let json = `"test"`->Js.Json.parseExn

    json->mustDecode(strWithDefault)
  })->toBe("test"))

  test("strWithDefault default case", () => expect({
    let json = `null`->Js.Json.parseExn

    json->mustDecode(strWithDefault)
  })->toBe(""))

  test("bufferFromBase64", () => expect({
    let json = `"SGVsbG8gV29ybGQ="`->Js.Json.parseExn

    json->mustDecode(bufferFromBase64)
  })->toEqual(JsBuffer.fromBase64("SGVsbG8gV29ybGQ=")))

  test("bufferFromHex", () => expect({
    let json = `"0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58="`->Js.Json.parseExn

    json->mustDecode(bufferFromHex)
  })->toEqual(JsBuffer.fromHex("0x0235b618ab0f0e9f48b1af32f56b78d955c432279893714737a937035024b83c58=")))
})

describe("Expect mustGet to work correctly", () => {
  test("mustGet", () => expect({
    let json = `{
        "target": "123",
        "dummy": "test"
    }`->Js.Json.parseExn

    json->mustGet("target", intstr)
  })->toBe(123))
})

describe("Expect mustAt to work correctly", () => {
  test("mustAt", () => expect({
    let json = `{
    "level1": {
      "level2": {
        "target": "123",
        "dummy": "test"
      }
    },
    "dummy": "test"
  }`->Js.Json.parseExn

    json->mustAt(list{"level1", "level2", "target"}, intstr)
  })->toBe(123))
})

type testObj = {
  field_1: int,
  field_2: string,
  field_3: option<int>,
  field_4: option<int>
}

describe("Expect buildObject to work correctly", () => {
  test("buildObject", () => expect({
    let decode = {
      buildObject(json => {
        field_1: json.required(list{"field_1"}, int),
        field_2: json.required(list{"field_2"}, string),
        field_3: json.optional(list{"field_3"}, int),
        field_4: json.optional(list{"field_4"}, int),
      })
    }

    let json = `{
        "field_1": 123,
        "field_2": "test",
        "field_3": 456
    }`->Js.Json.parseExn

    json->mustDecode(decode)
  })->toEqual({
    field_1: 123,
    field_2: "test",
    field_3: Some(456),
    field_4: None
  }))
})
