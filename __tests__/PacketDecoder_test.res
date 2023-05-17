open Jest
open PacketDecoder
open Expect

describe("Expect getPacketTypeText function work correctly", () => {
  test("oracle_request", () =>expect("oracle_request"->getPacketTypeText)->toEqual("Oracle Request"))
  test("oracle_response", () =>expect("oracle_response"->getPacketTypeText)->toEqual("Oracle Response"))
  test("fungible_token", () =>expect("fungible_token"->getPacketTypeText)->toEqual("Fungible Token"))
  test("Unknown", () =>expect("test"->getPacketTypeText)->toEqual("Unknown"))
})

// describe("Expect decodeAction function to work correctly", () => {
//   test("MsgSend decodeMsg", () => expect({
//     let json = `{
//   {
//   "msg": {
//     "decoded_data": {
//       "ask_count": 4,
//       "calldata": "AAAAFgAAAARBVE9NAAAABENNRFgAAAAEQ01TVAAAAARPU01PAAAAB0FYTFVTREMAAAAHQVhMV0VUSAAAAAZTVEFUT00AAAAESlVOTwAAAAdBWExXQlRDAAAABkFYTERBSQAAAAZXTUFUSUMAAAAFR1VTREMAAAAHQVhMV0JOQgAAAAVFVk1PUwAAAAVDQU5UTwAAAARMVU5BAAAABFhQUlQAAAADQUtUAAAABlNUT1NNTwAAAAdBWExXRlRNAAAABE1OVEwAAAAER0RBSQAAAAAAD0JA",
//       "client_id": "fetch_price_id",
//       "execute_gas": 600000,
//       "fee_limit": "250000uband",
//       "min_count": 3,
//       "oracle_script_id": 372,
//       "oracle_script_name": "Get Cosmos Prices",
//       "oracle_script_schema": "{symbols:[string],multiplier:u64}/{rates:[u64]}",
//       "prepare_gas": 600000
//     },
//     "id": 1448951,
//     "name": "Get Cosmos Prices",
//     "packet": {
//       "data": "eyJhc2tfY291bnQiOiI0IiwiY2FsbGRhdGEiOiJBQUFBRmdBQUFBUkJWRTlOQUFBQUJFTk5SRmdBQUFBRVEwMVRWQUFBQUFSUFUwMVBBQUFBQjBGWVRGVlRSRU1BQUFBSFFWaE1WMFZVU0FBQUFBWlRWRUZVVDAwQUFBQUVTbFZPVHdBQUFBZEJXRXhYUWxSREFBQUFCa0ZZVEVSQlNRQUFBQVpYVFVGVVNVTUFBQUFGUjFWVFJFTUFBQUFIUVZoTVYwSk9RZ0FBQUFWRlZrMVBVd0FBQUFWRFFVNVVUd0FBQUFSTVZVNUJBQUFBQkZoUVVsUUFBQUFEUVV0VUFBQUFCbE5VVDFOTlR3QUFBQWRCV0V4WFJsUk5BQUFBQkUxT1ZFd0FBQUFFUjBSQlNRQUFBQUFBRDBKQSIsImNsaWVudF9pZCI6ImZldGNoX3ByaWNlX2lkIiwiZXhlY3V0ZV9nYXMiOiI2MDAwMDAiLCJmZWVfbGltaXQiOlt7ImFtb3VudCI6IjI1MDAwMCIsImRlbm9tIjoidWJhbmQifV0sIm1pbl9jb3VudCI6IjMiLCJvcmFjbGVfc2NyaXB0X2lkIjoiMzcyIiwicHJlcGFyZV9nYXMiOiI2MDAwMDAifQ==",
//       "destination_channel": "channel-376",
//       "destination_port": "oracle",
//       "sequence": 16503,
//       "source_channel": "channel-12",
//       "source_port": "bandoracleV1",
//       "timeout_height": {
//         "revision_height": 0,
//         "revision_number": 0
//       },
//       "timeout_timestamp": 1684310003890922200
//     },
//     "packet_type": "oracle_request",
//     "proof_commitment": "CoEICv4HCkJjb21taXRtZW50cy9wb3J0cy9iYW5kb3JhY2xlVjEvY2hhbm5lbHMvY2hhbm5lbC0xMi9zZXF1ZW5jZXMvMTY1MDMSICrPNlae0KrVA7hzLUt9W1OKT0Q3JcAfr+B+9clgI7toGg4IARgBIAEqBgACyN+9AiIuCAESBwIEyN+9AiAaISBQ7Omcw3Ry5FC59zl+Trt//dKdglEenBr2r3+LBnjDTSIsCAESKAQIyN+9AiBtc9mydBtN5fo0ZQPJgXUaEkXRygaMij0OV0WwbN2HaSAiLAgBEigGEMjfvQIg36UCRFLJeZrOGZm934PyIucezRChHz45yQl0WPR5DHwgIiwIARIoCBjI370CIG5cfltiBAkYvrYOOJgECfFTL0lQ3Zqyz8xsJjvCQxUpICIsCAESKAooyN+9AiChPewyCSFKChvzJqHbJhd7Q1/ikO6k6L9Q6I43qJzx/iAiLAgBEigMaMjfvQIgxLPWUYuiazgSQdbbNzOZwpUkmoyPMYPwskizvc4t1ZUgIi0IARIpDqgByN+9AiComZ0vNA85JwE88Siz5WPdhC4d4x4gpr7OkRoeg12LMiAiLQgBEikQqAPI370CIKxoU+NhlsiUErqDs7MbYv9R0V23WofRhclZpHaA+zGPICIvCAESCBKYBsjfvQIgGiEgFloInLFKNxZGGe496kSIqKT54er1qrl7RK4V3wYUJqYiLQgBEikUrArI370CIJXajurFSl5h+kNDacpxbuMmym7oh5hykAjE89oLgKFwICItCAESKRasEMjfvQIg10yvN0tOKYAZxsrv0JdURodvKQFYJfzoRxg8c0wyLlkgIi0IARIpGOgXyN+9AiAKJp4tPpdU68zISvXx0VAiNxnAdWU3+qiKIeXxRrsm2SAiLQgBEikazi/I370CIDzuZed8xdq91wonF1LLnepsgtpUBv3NS9T1yTsJ5boRICIvCAESCBzeXsjfvQIgGiEgh1eCQOEjSPP4muZJGCJSoHH9q1Psv4zwST7fIt9ysdAiMAgBEgke7JgByN+9AiAaISDlRNzomHR06BIe5uCUJr2DluWVjPu3KvWC8TIhrSxcdCIuCAESKiKK6wPI370CIAXIGApEf5UiXllcc2xoWJJPl5v3gdXvqMI+P+AqEWMOICIwCAESCSSovQfI370CIBohIKUUXAQBcXpwdEV6WXxfd+Lj+nI2Qo7FMrNT9s/6pCtqIjAIARIJJpLKDMjfvQIgGiEgseP3vT4ez4eH+Z+bOBuyoAPgYfpNK1BTzXWgMc54/kUiLggBEioortAVyN+9AiBrdt/AJ4kBN3++RA0klrV2lnC7T0SRCwNPAZQxit/Z1yAKpQIKogIKA2liYxIg4ulgyTgQ2ZLTlUn0EkBpwOJYD37VzFVLp1yaMvpbviUaCQgBGAEgASoBACInCAESAQEaIO9bePqZqABBFXmtZmhz6+Ycy5cg/3MbJPlPPkrEHWsAIiUIARIhARLDaBW/nzGiJ/4tJDUGPzTrpZReRO8x4cEamX0BZ20PIiUIARIhAT9a5wVaS6TK4sQjPJcCLcJjBTbUi4i7gq4500nqEMZBIiUIARIhAXhNazVvknooyuKqsQy8OYF1ZlepQv3S4BqAeCA7tbhaIicIARIBARogwBOjf0vXgnjT7qBpJlbkQnUFVt4u/t11V5bOoFUxnNciJwgBEgEBGiD8et6RIj+Pnzf/AN7ajp47RKoxhNBMafZtLbSktMoaMw==",
//     "proof_height": {
//       "revision_height": 2602981,
//       "revision_number": 0
//     },
//     "schema": "{symbols:[string],multiplier:u64}/{rates:[u64]}",
//     "signer": "band1rj6z0f6c9j2lg0zq53dsxt9m2v97tluw0l9rvx",
//     "skip": false
//   },
//   "type": "/ibc.core.channel.v1.MsgRecvPacket"
// }`->Js.Json.parseExn

//     json->decodeMsg(true)
//   })->toEqual({
//     raw: `{
//       "msg": {
//         "amount": [
//           {
//             "denom": "uband",
//             "amount": "90000"
//           }
//         ],
//         "from_address": "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch",
//         "to_address": "band12c774t64ldcmpg3mzw5kx98jqwm2ae5ehgv7r8"
//       },
//       "type": "/cosmos.bank.v1beta1.MsgSend"
//     }`->Js.Json.parseExn,
//     decoded: SendMsg({
//       fromAddress: "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch"->Address.fromBech32,
//       toAddress: "band12c774t64ldcmpg3mzw5kx98jqwm2ae5ehgv7r8"->Address.fromBech32,
//       amount: list{Coin.newCoin("uband", 90000.)},
//     }),
//     sender: "band1d66jea56s0e2gxp8epesx6tgasq982c5jtehch"->Address.fromBech32,
//     isIBC: false,
//   }))
// })

