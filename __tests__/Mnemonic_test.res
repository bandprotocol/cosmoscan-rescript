open Jest
open Mnemonic
open Expect

describe("Expect Mnemonic to work correctly", () => {
  let wallet = create("test")

  test("getAddressAndPubKey", () =>
    expect(wallet->getAddressAndPubKey)->toEqual((
      "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"->Address.fromBech32,
      "AvxTX+rdSgSEeaSSVbYg1UhxlwZ21aTsXeIUyA04dBD2"->PubKey.fromBase64,
    ))
  )

  test("sign", () =>
    expect(wallet->sign("msg"))->toEqual(
      "rFJYA0BOYfuVn4+MBkn5n9D6YAMgGfXJbQytx4T2ePtXDnpaU8pEV+6t8XK0BhVhQYWX7Kdhx2x3iXiFYBfj2Q=="->JsBuffer.fromBase64,
    )
  )
})
