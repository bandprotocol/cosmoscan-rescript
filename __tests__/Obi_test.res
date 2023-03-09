// open Jest
// open Obi
// open Expect

// describe("Expect Obi to extract fields correctly", () => {
//   test("should be able to extract fields from bytes correctly", () => {
//     expect(extractFields("{symbol:string,multiplier:u64}/{volume:u64}", "input"))->toEqual(
//       Some([
//         {fieldName: "symbol", fieldType: "string"},
//         {fieldName: "multiplier", fieldType: "u64"},
//       ]),
//     )
//   })

//   test("should return None on invalid type", () => {
//     expect(extractFields("{symbol:string,multiplier:u64}/{volume:u64}", "Input"))->toEqual(None)
//   })
// })

// describe("Expect Obi encode correctly", () => {
//   test("should be able to encode input (string, int) correctly", () => {
//     expect(
//       encode(
//         "{symbol: string,multiplier: u64}/{price: u64,sources: [{ name: string, time: u64 }]}",
//         "input",
//         [
//           {fieldName: "symbol", fieldValue: "BTC"},
//           {fieldName: "multiplier", fieldValue: "1000000000"},
//         ],
//       ),
//     )->toEqual(Some("0x00000003425443000000003b9aca00"->JsBuffer.fromHex))
//   })

//   test("should be able to encode input (bytes) correctly", () => {
//     expect(
//       encode(
//         "{symbol: bytes}/{price: u64}",
//         "input",
//         [{fieldName: "symbol", fieldValue: "0x55555555"}],
//       ),
//     )->toEqual(Some("0x0000000455555555"->JsBuffer.fromHex))
//   })

//   test("should be able to encode nested input correctly", () => {
//     expect(
//       encode(
//         "{list: [{symbol: {name: [string]}}]}/{price: u64}",
//         "input",
//         [{fieldName: "list", fieldValue: `[{"symbol": {"name": ["XXX", "YYY"]}}]`}],
//       ),
//     )->toEqual(Some("0x00000001000000020000000358585800000003595959"->JsBuffer.fromHex))
//   })

//   test("should be able to encode output correctly", () => {
//     expect(
//       encode(
//         "{list: [{symbol: {name: [string]}}]}/{price: [u64]}",
//         "output",
//         [{fieldName: "price", fieldValue: `[120, 323]`}],
//       ),
//     )->toEqual(Some("0x0000000200000000000000780000000000000143"->JsBuffer.fromHex))
//   })

//   test("should return None if invalid type", () => {
//     expect(
//       encode(
//         "{symbol: string,multiplier: u64}/{price: u64,sources: [{ name: string, time: u64 }]}",
//         "nothing",
//         [
//           {fieldName: "symbol", fieldValue: "BTC"},
//           {fieldName: "multiplier", fieldValue: "1000000000"},
//         ],
//       ),
//     )->toEqual(None)
//   })

//   test("should return None if invalid data", () => {
//     expect(
//       encode(
//         "{symbol: string,multiplier: u64}/{price: u64,sources: [{ name: string, time: u64 }]}",
//         "nothing",
//         [{fieldName: "symbol", fieldValue: "BTC"}],
//       ),
//     )->toEqual(None)
//   })

//   test("should return None if invalid input schema", () => {
//     expect(
//       encode(
//         "{symbol: string}/{price: u64,sources: [{ name: string, time: u64 }]}",
//         "nothing",
//         [
//           {fieldName: "symbol", fieldValue: "BTC"},
//           {fieldName: "multiplier", fieldValue: "1000000000"},
//         ],
//       ),
//     )->toEqual(None)
//   })

//   test("should return None if invalid output schema", () => {
//     expect(
//       encode("{symbol: string}", "nothing", [{fieldName: "symbol", fieldValue: "BTC"}]),
//     )->toEqual(None)
//   })
// })

// describe("Expect Obi decode correctly", () => {
//   test("should be able to decode from bytes correctly", () => {
//     expect(
//       decode(
//         "{symbol: string,multiplier: u64}/{price: u64,sources: [{ name: string, time: u64 }]}",
//         "input",
//         "0x00000003425443000000003b9aca00"->JsBuffer.fromHex,
//       ),
//     )->toEqual(
//       Some([
//         {fieldName: "symbol", fieldValue: "\"BTC\""},
//         {fieldName: "multiplier", fieldValue: "1000000000"},
//       ]),
//     )
//   })

//   test("should be able to decode from bytes correctly (nested)", () => {
//     expect(
//       decode(
//         "{list: [{symbol: {name: [string]}}]}/{price: u64}",
//         "input",
//         "0x00000001000000020000000358585800000003595959"->JsBuffer.fromHex,
//       ),
//     )->toEqual(
//       Some([{fieldName: "list", fieldValue: "[{\"symbol\":{\"name\":[\"XXX\",\"YYY\"]}}]"}]),
//     )
//   })

//   test("should be able to decode from bytes correctly (bytes)", () => {
//     expect(
//       decode("{symbol: bytes}/{price: u64}", "input", "0x0000000455555555"->JsBuffer.fromHex),
//     )->toEqual(Some([{fieldName: "symbol", fieldValue: "0x55555555"}]))
//   })

//   test("should return None if invalid schema", () => {
//     expect(
//       decode(
//         "{symbol: string}/{price: u64,sources: [{ name: string, time: u64 }]}",
//         "input",
//         "0x00000003425443000000003b9aca00"->JsBuffer.fromHex,
//       ),
//     )->toEqual(None)
//   })
// })

// describe("should be able to generate solidity correctly", () => {
//   test("should be able to generate solidity", () => {
//     expect(generateDecoderSolidity(`{symbol:string,multiplier:u64}/{px:u64}`))->toEqual(
//       Some(`pragma solidity ^0.5.0;

// import "./Obi.sol";

// library ParamsDecoder {
//     using Obi for Obi.Data;

//     struct Params {
//         string symbol;
//         uint64 multiplier;
//     }

//     function decodeParams(bytes memory _data)
//         internal
//         pure
//         returns (Params memory result)
//     {
//         Obi.Data memory data = Obi.from(_data);
//         result.symbol = string(data.decodeBytes());
//         result.multiplier = data.decodeU64();
//     }
// }

// library ResultDecoder {
//     using Obi for Obi.Data;

//     struct Result {
//         uint64 px;
//     }

//     function decodeResult(bytes memory _data)
//         internal
//         pure
//         returns (Result memory result)
//     {
//         Obi.Data memory data = Obi.from(_data);
//         result.px = data.decodeU64();
//     }
// }

// `),
//     )
//   })

//   test("should be able to generate solidity when parameter is array", () => {
//     expect(generateDecoderSolidity(`{symbols:[string],multiplier:u64}/{rates:[u64]}`))->toEqual(
//       Some(`pragma solidity ^0.5.0;

// import "./Obi.sol";

// library ParamsDecoder {
//     using Obi for Obi.Data;

//     struct Params {
//         string[] symbols;
//         uint64 multiplier;
//     }

//     function decodeParams(bytes memory _data)
//         internal
//         pure
//         returns (Params memory result)
//     {
//         Obi.Data memory data = Obi.from(_data);
//         uint32 length = data.decodeU32();
//         string[] memory symbols = new string[](length);
//         for (uint256 i = 0; i < length; i++) {
//           symbols[i] = string(data.decodeBytes());
//         }
//         result.symbols = symbols
//         result.multiplier = data.decodeU64();
//     }
// }

// library ResultDecoder {
//     using Obi for Obi.Data;

//     struct Result {
//         uint64[] rates;
//     }

//     function decodeResult(bytes memory _data)
//         internal
//         pure
//         returns (Result memory result)
//     {
//         Obi.Data memory data = Obi.from(_data);
//         uint32 length = data.decodeU32();
//         uint64[] memory rates = new uint64[](length);
//         for (uint256 i = 0; i < length; i++) {
//           rates[i] = data.decodeU64();
//         }
//         result.rates = rates
//     }
// }

// `),
//     )
//   })
// })
