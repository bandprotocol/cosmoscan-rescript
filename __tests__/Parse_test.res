open Jest
open Expect
open Parse

describe("Expect parse from string to band amount", () => {
  test("should be able to parse correctly", () => {
    expect(Result.Ok(1000000.))->toEqual(getBandAmount(2000000., "1"))
  })

  test("shouldn't send when insufficient amount", () => {
    expect(Result.Err("Insufficient amount"))->toEqual(getBandAmount(2000., "1"))
  })

  test("shouldn't use amount less than 0", () => {
    expect(Result.Err("Amount must be more than 0"))->toEqual(getBandAmount(2000., "-3"))
  })

  test("shouldn't use invalid value", () => {
    expect(Result.Err("Invalid value"))->toEqual(getBandAmount(2000., "hello"))
  })

  test("band amount shouldn't grater than 4", () => {
    expect(Result.Err("Maximum precision is 6"))->toEqual(getBandAmount(2000000., "1.1234567"))
  })
})

describe("Expect parse from string to Address", () => {
  test("should be able to parse correctly", () => {
    expect(Result.Ok(Address.fromBech32("band13zmknvkq2sj920spz90g4r9zjan8g584x8qalj")))->toEqual(
      address("band13zmknvkq2sj920spz90g4r9zjan8g584x8qalj"),
    )
  })

  test("shouldn't use invalid address", () => {
    expect(Result.Err("Invalid address"))->toEqual(address("2"))
  })

  test("notBandAddress should parse correctly", () => {
    expect(
      Result.Ok(
        Address.fromBech32OptNotBandPrefix(
          "cosmos1pdvm6paaenlelmga2qkr50thpkrzwxy33lrh7c",
        )->Belt.Option.getExn,
      ),
    )->toEqual(notBandAddress("cosmos1pdvm6paaenlelmga2qkr50thpkrzwxy33lrh7c"))
  })

  test("notBandAddress shouldn't parse invalid address", () => {
    expect(Result.Err("Invalid address"))->toEqual(notBandAddress("1"))
  })
})

describe("Expect parse from string to Int", () => {
  test("mustParseInt should parse correctly", () => {
    expect(123)->toEqual(mustParseInt("123"))
  })
})
