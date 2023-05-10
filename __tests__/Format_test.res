open Jest
open Format
open Expect

describe("Expect Format module to work correctly", () => {
  test("withCommas", () => {
    expect("10000000"->withCommas)->toBe("10,000,000")
  })

  test("withCommas with decimal digits", () => {
    expect("10000000.1234"->withCommas)->toBe("10,000,000.1234")
  })

  test("fPretty value >= 1000000", () => {
    expect(10000000.->fPretty)->toBe("10,000,000")
  })

  test("fPretty value > 100.", () => {
    expect(1000.123->fPretty)->toBe("1,000.12")
  })

  test("fPretty value > 1.", () => {
    expect(3.14285->fPretty)->toBe("3.1429")
  })

  test("fPretty value < 1", () => {
    expect(0.123->fPretty)->toBe("0.123000")
  })

  test("fPretty with digit", () => {
    expect(10000000.12345678->fPretty(~digits=6))->toBe("10,000,000.123457")
  })

  test("fCurrency value >= 1e9", () => {
    expect(12300000000.->fCurrency)->toBe("12.30B")
  })

  test("fCurrency value >= 1e6", () => {
    expect(12300000.->fCurrency)->toBe("12.30M")
  })

  test("fCurrency value >= 1e3", () => {
    expect(12300.->fCurrency)->toBe("12.30K")
  })

  test("fCurrency else", () => {
    expect(123.->fCurrency)->toBe("123.00")
  })

  test("fPercentChange positive", () => {
    expect(99.99->fPercentChange)->toBe("+99.99%")
  })

  test("fPercentChange negative", () => {
    expect(-99.99->fPercentChange)->toBe("-99.99%")
  })

  test("fPercent", () => {
    expect(123456789.->fPercent)->toBe("123,456,789.00 %")
  })

  test("fPercent < 1", () => {
    expect(0.12345678->fPercent)->toBe("0.123457 %")
  })

  test("fPercent with digits", () => {
    expect(123.45678->fPercent(~digits=4))->toBe("123.4568 %")
  })

  test("iPretty", () => {
    expect(10000000->iPretty)->toBe("10,000,000")
  })
})

