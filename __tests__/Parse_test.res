open Jest
open Expect
open Parse

describe("Expect parse from string to band amount", () => {
  test("should be able to parse correctly", () => {
    expect(Result.Ok(1000000.)) |> toEqual(getBandAmount(2000000., "1"))
  })

  test("shouldn't send when insufficient amount", () => {
    expect(Result.Err("Insufficient amount")) |> toEqual(getBandAmount(2000., "1"))
  })

  test("shouldn't use amount less than 0", () => {
    expect(Result.Err("Amount must be more than 0")) |> toEqual(getBandAmount(2000., "-3"))
  })

  test("shouldn't use invalid value", () => {
    expect(Result.Err("Invalid value")) |> toEqual(getBandAmount(2000., "hello"))
  })
})

describe("Expect parse from string to Address", () => {
  test("should be able to parse correctly", () => {
    expect(Result.Ok(Address.fromBech32("band13zmknvkq2sj920spz90g4r9zjan8g584x8qalj"))) |> toEqual(
      address("band13zmknvkq2sj920spz90g4r9zjan8g584x8qalj"),
    )
  })

  test("shouldn't use invalid address", () => {
    expect(Result.Err("Invalid address")) |> toEqual(address("2"))
  })
})
