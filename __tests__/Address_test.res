open Jest
open Address
open Expect

describe("Expect Address to work correctly", () => {
  test("should be able to create address from hex", () =>
    expect("F23391B5DBF982E37FB7DADEA64AAE21CAE4C172"->fromHex)->toEqual(
      Address("f23391b5dbf982e37fb7dadea64aae21cae4c172"),
    )
  )

  test("should be able to create address from hex with 0x prefix", () =>
    expect("0xF23391B5DBF982E37FB7DADEA64AAE21CAE4C172"->fromHex)->toEqual(
      Address("f23391b5dbf982e37fb7dadea64aae21cae4c172"),
    )
  )

  test("should be able to get hexString with 0x prefix", () =>
    expect(fromHex("f23391b5dbf982e37fb7dadea64aae21cae4c172")->toHex(~with0x=true))->toEqual(
      "0xf23391b5dbf982e37fb7dadea64aae21cae4c172",
    )
  )

  test("should be able to get hexString with 0x prefix with Uppercase", () =>
    expect(fromHex("f23391b5dbf982e37fb7dadea64aae21cae4c172")->toHex(~with0x=true, ~upper=true))->toEqual(
      "0XF23391B5DBF982E37FB7DADEA64AAE21CAE4C172",
    )
  )

  test("should be able to create address from fromBech32 with prefix band", () =>
    expect("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->fromBech32)->toEqual(
      Address("3855e27cba57cea3c70bf4063a7e28f11bd149fe"),
    )
  )

  test("should be able to create address from fromBech32 with prefix bandvaloper", () =>
    expect("bandvaloper13zmknvkq2sj920spz90g4r9zjan8g58423y76e"->fromBech32)->toEqual(
      Address("88b769b2c05424553e01115e8a8ca297667450f5"),
    )
  )

  test("should be able to create address from fromBech32 with prefix bandvalconspub", () =>
    expect("bandvalconspub1addwnpepq0grwz83v8g4s06fusnq5s4jkzxnhgvx67qr5g7v8tx39ur5m8tk7rg2nxj"->fromBech32)->toEqual(
      Address("eb5ae9872103d03708f161d1583f49e4260a42b2b08d3ba186d7803a23cc3acd12f074d9d76f"),
    )
  )

  test("should be able to convert self to hex", () =>
    expect(Address("88b769b2c05424553e01115e8a8ca297667450f5")->toHex)->toEqual(
      "88b769b2c05424553e01115e8a8ca297667450f5",
    )
  )

  test("should be able to convert self to toOperatorBech32", () =>
    expect(Address("88b769b2c05424553e01115e8a8ca297667450f5")->toOperatorBech32)->toEqual(
      "bandvaloper13zmknvkq2sj920spz90g4r9zjan8g58423y76e",
    )
  )

  test("should be able to convert self to toBech32", () =>
    expect(Address("88b769b2c05424553e01115e8a8ca297667450f5")->toBech32)->toEqual(
      "band13zmknvkq2sj920spz90g4r9zjan8g584x8qalj",
    )
  )

  test("should be able to convert toBech32 to hex directly", () =>
    expect("band13zmknvkq2sj920spz90g4r9zjan8g584x8qalj"->bech32ToHex)->toEqual(
      "88b769b2c05424553e01115e8a8ca297667450f5",
    )
  )

  test("should be able to convert hex to bech32 directly", () =>
    expect("88b769b2c05424553e01115e8a8ca297667450f5"->hexToBech32)->toEqual(
      "band13zmknvkq2sj920spz90g4r9zjan8g584x8qalj",
    )
  )

  test("should be able to convert hex to hexToOperatorBech32 directly", () =>
    expect("88b769b2c05424553e01115e8a8ca297667450f5"->hexToOperatorBech32)->toEqual(
      "bandvaloper13zmknvkq2sj920spz90g4r9zjan8g58423y76e",
    )
  )

  test("isEqual should work correctly", () =>
    expect({
      let addr1 = "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->fromBech32
      let addr2 = "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->fromBech32
      isEqual(addr1,addr2)
    })->toEqual(
      true
    )
  )
})
