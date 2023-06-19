open Jest
open Ellipsis
open Expect

describe("Expect Ellipsis module to work correctly", () => {
  test("text length > limit", () => {
    expect(
      end(~text="EDCD7E7A10F564CCCC50B2E382E1924013CB01728EBAFEC1071D2B1D395F82CC", ~limit=25, ()),
    )->toBe("EDCD7E7A10F564CCCC50B2E38...")
  })

  test("text length < limit", () => {
    expect(
      end(~text="EDCD7E7A10F564CCCC50B2E382E1924013CB01728EBAFEC1071D2B1D395F82CC", ~limit=125, ()),
    )->toBe("EDCD7E7A10F564CCCC50B2E382E1924013CB01728EBAFEC1071D2B1D395F82CC")
  })
})
