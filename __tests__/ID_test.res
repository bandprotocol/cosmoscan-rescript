open Jest
open ID
open Expect

describe("Expect IDCreator Module to works correctly", () => {

  module RawTestMockID = {
    type tab_t = unit
    let prefix = "#Mock"
    let route = (id, tab) => Route.HomePage
    let defaultTab = ()
  }

  module TestMock = IDCreator(RawTestMockID)

  let testMockID = 31425->TestMock.fromInt

  test("getRoute", () =>
    expect(testMockID->TestMock.getRoute)->toEqual(HomePage)
  )

  test("getRouteWithTab", () =>
    expect(testMockID->TestMock.getRouteWithTab(()))
    ->toEqual(HomePage)
  )

  test("toString", () => expect(testMockID->TestMock.toString)->toBe("#Mock31425"))
  
  test("toInt", () => expect(testMockID->TestMock.toInt)->toBe(31425))

  test("decoder", () => expect({
    let json = `31425`->Js.Json.parseExn

    json->JsonUtils.Decode.mustDecode(TestMock.decoder)
  })->toEqual(testMockID))

  test("fromJson", () => expect({
    let json = `31425`->Js.Json.parseExn

    json->TestMock.fromJson
  })->toEqual(testMockID))

  test("Expect fromJson to throw Exception", () => expect({
    let json = `null`->Js.Json.parseExn

    () => json->TestMock.fromJson
  })->toThrow)

  test("fromIntExn", () => expect(Some(31425)->TestMock.fromIntExn)->toEqual(testMockID))
  test("Expect fromIntExn to throw Exception", () => expect(() => None->TestMock.fromIntExn)->toThrow)

  test("toJson", () => expect(testMockID->TestMock.toJson)->toBe(`31425`->Js.Json.parseExn))
})

describe("Expect DataSource Module to works correctly", () => {

  let dataSourceID = 236->DataSource.fromInt

  test("route", () =>
    expect(DataSource.route(236, Route.DataSourceCode))
    ->toEqual(Route.DataSourceDetailsPage(236, Route.DataSourceCode))
  )

  test("getRoute", () =>
    expect(dataSourceID->DataSource.getRoute)->toEqual(DataSourceDetailsPage(236, Route.DataSourceRequests))
  )

  test("getRouteWithTab", () =>
    expect(dataSourceID->DataSource.getRouteWithTab(Route.DataSourceExecute))
    ->toEqual(DataSourceDetailsPage(236, Route.DataSourceExecute))
  )

  test("toString", () => expect(dataSourceID->DataSource.toString)->toBe("#D236"))
  
  test("toInt", () => expect(dataSourceID->DataSource.toInt)->toBe(236))

  test("decoder", () => expect({
    let json = `236`->Js.Json.parseExn

    json->JsonUtils.Decode.mustDecode(DataSource.decoder)
  })->toEqual(dataSourceID))

  test("fromJson", () => expect({
    let json = `236`->Js.Json.parseExn

    json->DataSource.fromJson
  })->toEqual(dataSourceID))

  test("Expect fromJson to throw Exception", () => expect({
    let json = `null`->Js.Json.parseExn

    () => json->DataSource.fromJson
  })->toThrow)

  test("fromIntExn", () => expect(Some(236)->DataSource.fromIntExn)->toEqual(dataSourceID))
  test("Expect fromIntExn to throw Exception", () => expect(() => None->DataSource.fromIntExn)->toThrow)

  test("toJson", () => expect(dataSourceID->DataSource.toJson)->toBe(`236`->Js.Json.parseExn))
})

describe("Expect OracleScript Module to works correctly", () => {

  let oracleScriptID = 111->OracleScript.fromInt

  test("route", () =>
    expect(OracleScript.route(111, Route.OracleScriptCode))
    ->toEqual(Route.OracleScriptDetailsPage(111, Route.OracleScriptCode))
  )

  test("getRoute", () =>
    expect(oracleScriptID->OracleScript.getRoute)->toEqual(OracleScriptDetailsPage(111, Route.OracleScriptRequests))
  )

  test("getRouteWithTab", () =>
    expect(oracleScriptID->OracleScript.getRouteWithTab(Route.OracleScriptExecute))
    ->toEqual(OracleScriptDetailsPage(111, Route.OracleScriptExecute))
  )

  test("toString", () => expect(oracleScriptID->OracleScript.toString)->toBe("#O111"))
  
  test("toInt", () => expect(oracleScriptID->OracleScript.toInt)->toBe(111))

  test("decoder", () => expect({
    let json = `111`->Js.Json.parseExn

    json->JsonUtils.Decode.mustDecode(OracleScript.decoder)
  })->toEqual(oracleScriptID))

  test("fromJson", () => expect({
    let json = `111`->Js.Json.parseExn

    json->OracleScript.fromJson
  })->toEqual(oracleScriptID))

  test("Expect fromJson to throw Exception", () => expect({
    let json = `null`->Js.Json.parseExn

    () => json->OracleScript.fromJson
  })->toThrow)

  test("fromIntExn", () => expect(Some(111)->OracleScript.fromIntExn)->toEqual(oracleScriptID))
  test("Expect fromIntExn to throw Exception", () => expect(() => None->OracleScript.fromIntExn)->toThrow)

  test("toJson", () => expect(oracleScriptID->OracleScript.toJson)->toBe(`111`->Js.Json.parseExn))
})

describe("Expect Request Module to works correctly", () => {

  let requestID = 12345->Request.fromInt

  test("route", () =>
    expect(Request.route(12345, ()))
    ->toEqual(Route.RequestDetailsPage(12345))
  )

  test("getRoute", () =>
    expect(requestID->Request.getRoute)->toEqual(RequestDetailsPage(12345))
  )

  test("getRouteWithTab", () =>
    expect(requestID->Request.getRouteWithTab(()))
    ->toEqual(RequestDetailsPage(12345))
  )

  test("toString", () => expect(requestID->Request.toString)->toBe("#R12345"))
  
  test("toInt", () => expect(requestID->Request.toInt)->toBe(12345))

  test("decoder", () => expect({
    let json = `12345`->Js.Json.parseExn

    json->JsonUtils.Decode.mustDecode(Request.decoder)
  })->toEqual(requestID))

  test("fromJson", () => expect({
    let json = `12345`->Js.Json.parseExn

    json->Request.fromJson
  })->toEqual(requestID))

  test("Expect fromJson to throw Exception", () => expect({
    let json = `null`->Js.Json.parseExn

    () => json->Request.fromJson
  })->toThrow)

  test("fromIntExn", () => expect(Some(12345)->Request.fromIntExn)->toEqual(requestID))
  test("Expect fromIntExn to throw Exception", () => expect(() => None->Request.fromIntExn)->toThrow)

  test("toJson", () => expect(requestID->Request.toJson)->toBe(`12345`->Js.Json.parseExn))
})

describe("Expect Proposal Module to works correctly", () => {

  let proposalID = 5->Proposal.fromInt

  test("route", () =>
    expect(Proposal.route(5, ()))
    ->toEqual(Route.ProposalDetailsPage(5))
  )

  test("getRoute", () =>
    expect(proposalID->Proposal.getRoute)->toEqual(ProposalDetailsPage(5))
  )

  test("getRouteWithTab", () =>
    expect(proposalID->Proposal.getRouteWithTab(()))
    ->toEqual(ProposalDetailsPage(5))
  )

  test("toString", () => expect(proposalID->Proposal.toString)->toBe("#P5"))
  
  test("toInt", () => expect(proposalID->Proposal.toInt)->toBe(5))

  test("decoder", () => expect({
    let json = `5`->Js.Json.parseExn

    json->JsonUtils.Decode.mustDecode(Proposal.decoder)
  })->toEqual(proposalID))

  test("fromJson", () => expect({
    let json = `5`->Js.Json.parseExn

    json->Proposal.fromJson
  })->toEqual(proposalID))

  test("Expect fromJson to throw Exception", () => expect({
    let json = `null`->Js.Json.parseExn

    () => json->Proposal.fromJson
  })->toThrow)

  test("fromIntExn", () => expect(Some(5)->Proposal.fromIntExn)->toEqual(proposalID))
  test("Expect fromIntExn to throw Exception", () => expect(() => None->Proposal.fromIntExn)->toThrow)

  test("toJson", () => expect(proposalID->Proposal.toJson)->toBe(`5`->Js.Json.parseExn))
})

describe("Expect Block Module to works correctly", () => {

  let blockID = 123456->Block.fromInt

  test("route", () =>
    expect(Block.route(123456, ()))
    ->toEqual(Route.BlockDetailsPage(123456))
  )

  test("getRoute", () =>
    expect(blockID->Block.getRoute)->toEqual(BlockDetailsPage(123456))
  )

  test("getRouteWithTab", () =>
    expect(blockID->Block.getRouteWithTab(()))
    ->toEqual(BlockDetailsPage(123456))
  )

  test("toString", () => expect(blockID->Block.toString)->toBe("#B123456"))
  
  test("toInt", () => expect(blockID->Block.toInt)->toBe(123456))

  test("decoder", () => expect({
    let json = `123456`->Js.Json.parseExn

    json->JsonUtils.Decode.mustDecode(Block.decoder)
  })->toEqual(blockID))

  test("fromJson", () => expect({
    let json = `123456`->Js.Json.parseExn

    json->Block.fromJson
  })->toEqual(blockID))

  test("Expect fromJson to throw Exception", () => expect({
    let json = `null`->Js.Json.parseExn

    () => json->Block.fromJson
  })->toThrow)

  test("fromIntExn", () => expect(Some(123456)->Block.fromIntExn)->toEqual(blockID))
  test("Expect fromIntExn to throw Exception", () => expect(() => None->Block.fromIntExn)->toThrow)

  test("toJson", () => expect(blockID->Block.toJson)->toBe(`123456`->Js.Json.parseExn))
})
