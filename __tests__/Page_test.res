open Jest
open Page
open Expect

describe("Expect Page module getPageCount function to work correctly", () => {
  test("page evenly divided", () => {
    expect(getPageCount(100,20))->toBe(5)
  })

  test("page not evenly divided", () => {
    expect(getPageCount(101,20))->toBe(6)
  })
})

