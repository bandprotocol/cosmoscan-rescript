open Jest
open Expect
open Msg

describe("Expect getBadge function to work correctly", () => {
  test("getBadge from MsgSend", () =>
    expect(
      SendMsg({
        fromAddress: "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch"->Address.fromBech32,
        toAddress: "band12c774t64ldcmpg3mzw5kx98jqwm2ae5ehgv7r8"->Address.fromBech32,
        amount: list{Coin.newCoin("uband", 90000.)},
      })->getBadge,
    )->toEqual({name: "Send", category: TokenMsg})
  )

  test("getBadge from UnknownMsg", () =>
    expect(UnknownMsg->getBadge)->toEqual({name: "Unknown msg", category: UnknownMsg})
  )
})

describe("Expect MsgSend decodeMsg to work correctly", () => {
  test("MsgSend decodeMsg", () =>
    expect({
      let json = `{
  "msg": {
    "amount": [
      {
        "denom": "uband",
        "amount": "90000"
      }
    ],
    "from_address": "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch",
    "to_address": "band12c774t64ldcmpg3mzw5kx98jqwm2ae5ehgv7r8"
  },
  "type": "/cosmos.bank.v1beta1.MsgSend"
}`->Js.Json.parseExn

      json->decodeMsg(true)
    })->toEqual({
      raw: `{
      "msg": {
        "amount": [
          {
            "denom": "uband",
            "amount": "90000"
          }
        ],
        "from_address": "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch",
        "to_address": "band12c774t64ldcmpg3mzw5kx98jqwm2ae5ehgv7r8"
      },
      "type": "/cosmos.bank.v1beta1.MsgSend"
    }`->Js.Json.parseExn,
      decoded: SendMsg({
        fromAddress: "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch"->Address.fromBech32,
        toAddress: "band12c774t64ldcmpg3mzw5kx98jqwm2ae5ehgv7r8"->Address.fromBech32,
        amount: list{Coin.newCoin("uband", 90000.)},
      }),
      sender: "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch"->Address.fromBech32,
      isIBC: false,
    })
  )
})

describe("Expect MsgVote decodeMsg to work correctly", () => {
  test("Yes option with Success", () =>
    expect({
      let json = `{
  "msg": {
    "option": 1,
    "proposal_id": 5,
    "title": "upgrade",
    "voter": "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"
  },
  "type": "/cosmos.gov.v1beta1.MsgVote"
}`->Js.Json.parseExn

      json->decodeMsg(true)
    })->toEqual({
      raw: `{
  "msg": {
    "option": 1,
    "proposal_id": 5,
    "title": "upgrade",
    "voter": "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"
  },
  "type": "/cosmos.gov.v1beta1.MsgVote"
}`->Js.Json.parseExn,
      decoded: LegacyVoteMsg(
        Success({
          voterAddress: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
          proposalID: 5->ID.Proposal.fromInt,
          option: "Yes",
          title: "upgrade",
        }),
      ),
      sender: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
      isIBC: false,
    })
  )

  test("No option with Success", () =>
    expect({
      let json = `{
  "msg": {
    "option": 3,
    "proposal_id": 5,
    "title": "upgrade",
    "voter": "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"
  },
  "type": "/cosmos.gov.v1beta1.MsgVote"
}`->Js.Json.parseExn

      json->decodeMsg(true)
    })->toEqual({
      raw: `{
  "msg": {
    "option": 3,
    "proposal_id": 5,
    "title": "upgrade",
    "voter": "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"
  },
  "type": "/cosmos.gov.v1beta1.MsgVote"
}`->Js.Json.parseExn,
      decoded: LegacyVoteMsg(
        Success({
          voterAddress: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
          proposalID: 5->ID.Proposal.fromInt,
          option: "No",
          title: "upgrade",
        }),
      ),
      sender: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
      isIBC: false,
    })
  )

  test("Yes option with Failure", () =>
    expect({
      let json = `{
  "msg": {
    "option": 1,
    "proposal_id": 5,
    "title": "upgrade",
    "voter": "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"
  },
  "type": "/cosmos.gov.v1beta1.MsgVote"
}`->Js.Json.parseExn

      json->decodeMsg(false)
    })->toEqual({
      raw: `{
  "msg": {
    "option": 1,
    "proposal_id": 5,
    "title": "upgrade",
    "voter": "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"
  },
  "type": "/cosmos.gov.v1beta1.MsgVote"
}`->Js.Json.parseExn,
      decoded: LegacyVoteMsg(
        Failure({
          voterAddress: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
          proposalID: 5->ID.Proposal.fromInt,
          option: "Yes",
          title: (),
        }),
      ),
      sender: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
      isIBC: false,
    })
  )
})
