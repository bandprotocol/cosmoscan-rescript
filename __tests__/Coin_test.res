open Jest
open Coin
open Expect

describe("Expect Coin to work correctly", () => {
  test("should be able to decode Js.Json to Coin", () => {
    let dict = Js.Dict.empty()
    Js.Dict.set(dict, "denom", Js.Json.string("uband"))
    Js.Dict.set(dict, "amount", Js.Json.string("1000000"))
    let coin = Js.Json.object_(dict)

    expect(coin->JsonUtils.Decode.mustDecode(decodeCoin))->toEqual({
      denom: "uband",
      amount: 1000000.,
    })
  })

  test("should be able to create Coin by uband amount", () =>
    expect(newUBANDFromAmount(1000.))->toEqual({denom: "uband", amount: 1000.})
  )

  test("should be able to create Coin by newCoin", () =>
    expect(newCoin("ustake", 999.))->toEqual({denom: "ustake", amount: 999.})
  )

  test("should be able to getBandAmountFromCoin", () =>
    expect({amount: 1000000., denom: "uband"}->getBandAmountFromCoin)->toEqual(1.)
  )

  test("should be able to getBandAmountFromCoins", () =>
    expect(
      list{
        {amount: 2000000., denom: "ustake"},
        {amount: 3000000., denom: "uband"},
      }->getBandAmountFromCoins,
    )->toEqual(3.)
  )

  test("should be able to getUBandAmountFromCoin", () =>
    expect({amount: 5000000., denom: "uband"}->getUBandAmountFromCoin)->toEqual(5000000.)
  )

  test("should be able to getUBandAmountFromCoins", () =>
    expect(
      list{
        {amount: 1000000., denom: "ustake"},
        {amount: 2000000., denom: "uband"},
      }->getUBandAmountFromCoins,
    )->toEqual(2000000.)
  )
})
