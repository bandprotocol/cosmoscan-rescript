open Jest
open Route
open Expect

describe("Expect Search Functionality to work correctly", () => {
  test("test NotFound search case", () => expect("123"->search)->toEqual(NotFound))
  test("test transaction route", () =>
    expect("22638794cb5f306ef929b90c58b27d26cb35a77ca5c5c624cf2025a98528c323"->search)->toEqual(
      TxIndexPage("22638794cb5f306ef929b90c58b27d26cb35a77ca5c5c624cf2025a98528c323"->Hash.fromHex),
    )
  )
  test("test transaction route prefix is 0x", () =>
    expect("22638794cb5f306ef929b90c58b27d26cb35a77ca5c5c624cf2025a98528c323"->search)->toEqual(
      TxIndexPage(
        "0x22638794cb5f306ef929b90c58b27d26cb35a77ca5c5c624cf2025a98528c323"->Hash.fromHex,
      ),
    )
  )
  test("test block prefix is B", () => expect("B123"->search)->toEqual(BlockDetailsPage(123)))
  test("test block prefix is b", () => expect("b123"->search)->toEqual(BlockDetailsPage(123)))
  test("test data soure route prefix is D", () =>
    expect("D123"->search)->toEqual(DataSourceDetailsPage(123, DataSourceRequests))
  )
  test("test data soure route prefix is d", () =>
    expect("d123"->search)->toEqual(DataSourceDetailsPage(123, DataSourceRequests))
  )
  test("test request route prefix is R", () =>
    expect("R123"->search)->toEqual(RequestDetailsPage(123))
  )
  test("test request route prefix is r", () =>
    expect("r123"->search)->toEqual(RequestDetailsPage(123))
  )
  test("test oracle script route prefix is O", () =>
    expect("O123"->search)->toEqual(OracleScriptDetailsPage(123, OracleScriptRequests))
  )
  test("test oracle script route prefix is o", () =>
    expect("O123"->search)->toEqual(OracleScriptDetailsPage(123, OracleScriptRequests))
  )
  test("test validator route", () =>
    expect("bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"->search)->toEqual(
      ValidatorDetailsPage(
        "bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"->Address.fromBech32,
        Reports,
      ),
    )
  )
  test("test account route", () =>
    expect("band1p40yh3zkmhcv0ecqp3mcazy83sa57rgjp07dun"->search)->toEqual(
      AccountIndexPage(
        "band1p40yh3zkmhcv0ecqp3mcazy83sa57rgjp07dun"->Address.fromBech32,
        AccountPortfolio,
      ),
    )
  )
  test("test page not found", () => expect("asdasd"->search)->toEqual(NotFound))
})

describe("Expect toString function to work correctly", () => {
  test("DataSourcePage", () => expect(DataSourcePage->toString)->toEqual("/data-sources"))
  test("DataSourceDetailsPage Request", () =>
    expect(DataSourceDetailsPage(123, DataSourceRequests)->toString)->toEqual("/data-source/123")
  )
  test("DataSourceDetailsPage Code", () =>
    expect(DataSourceDetailsPage(123, DataSourceCode)->toString)->toEqual("/data-source/123#code")
  )
  test("DataSourceDetailsPage Execute", () =>
    expect(DataSourceDetailsPage(123, DataSourceExecute)->toString)->toEqual(
      "/data-source/123#execute",
    )
  )

  test("OracleScriptPage", () => expect(OracleScriptPage->toString)->toEqual("/oracle-scripts"))
  test("OracleScriptDetailsPage Request", () =>
    expect(OracleScriptDetailsPage(123, OracleScriptRequests)->toString)->toEqual(
      "/oracle-script/123",
    )
  )
  test("OracleScriptDetailsPage Code", () =>
    expect(OracleScriptDetailsPage(123, OracleScriptCode)->toString)->toEqual(
      "/oracle-script/123#code",
    )
  )
  test("OracleScriptDetailsPage Bridge", () =>
    expect(OracleScriptDetailsPage(123, OracleScriptBridgeCode)->toString)->toEqual(
      "/oracle-script/123#bridge",
    )
  )
  test("OracleScriptDetailsPage Execute", () =>
    expect(OracleScriptDetailsPage(123, OracleScriptExecute)->toString)->toEqual(
      "/oracle-script/123#execute",
    )
  )

  test("TxHomePage", () => expect(TxHomePage->toString)->toEqual("/txs"))
  test("TxIndexPage", () =>
    expect(
      TxIndexPage(
        Hash.fromHex("1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51"),
      )->toString,
    )->toEqual("/tx/1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51")
  )
  test("ValidatorsPage", () => expect(ValidatorsPage->toString)->toEqual("/validators"))
  test("BlockPage", () => expect(BlockPage->toString)->toEqual("/blocks"))
  test("BlockDetailsPage", () => expect(BlockDetailsPage(123)->toString)->toEqual("/block/123"))
  test("RequestHomePage", () => expect(RequestHomePage->toString)->toEqual("/requests"))
  test("RequestDetailsPage", () =>
    expect(RequestDetailsPage(123)->toString)->toEqual("/request/123")
  )

  test("AccountIndexPage portfolio", () =>
    expect(
      AccountIndexPage(
        Address.fromBech32("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"),
        AccountPortfolio,
      )->toString,
    )->toEqual("/account/band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph#portfolio")
  )

  test("AccountIndexPage transaction", () =>
    expect(
      AccountIndexPage(
        Address.fromBech32("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"),
        AccountTransaction,
      )->toString,
    )->toEqual("/account/band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph#txs")
  )

  test("ValidatorDetailsPage reports", () =>
    expect(
      ValidatorDetailsPage(
        Address.fromBech32("band1ntwzz6tlvpy52tf5urr7jz6lvk2402sksntxuw"),
        Reports,
      )->toString,
    )->toEqual("/validator/bandvaloper1ntwzz6tlvpy52tf5urr7jz6lvk2402sku909e9#reports")
  )

  test("ValidatorDetailsPage Delegators", () =>
    expect(
      ValidatorDetailsPage(
        Address.fromBech32("band1ntwzz6tlvpy52tf5urr7jz6lvk2402sksntxuw"),
        Delegators,
      )->toString,
    )->toEqual("/validator/bandvaloper1ntwzz6tlvpy52tf5urr7jz6lvk2402sku909e9#delegators")
  )

  test("ValidatorDetailsPage proposed-blocks", () =>
    expect(
      ValidatorDetailsPage(
        Address.fromBech32("band1ntwzz6tlvpy52tf5urr7jz6lvk2402sksntxuw"),
        ProposedBlocks,
      )->toString,
    )->toEqual("/validator/bandvaloper1ntwzz6tlvpy52tf5urr7jz6lvk2402sku909e9#proposed-blocks")
  )

  test("ProposalPage", () => expect(ProposalPage->toString)->toEqual("/proposals"))
  test("ProposalDetailsPage", () =>
    expect(ProposalDetailsPage(1)->toString)->toEqual("/proposal/1")
  )
  test("RelayersHomepage", () => expect(RelayersHomepage->toString)->toEqual("/relayers"))
  test("ChannelDetailsPage", () =>
    expect(ChannelDetailsPage("beeb-terra", "oracle", "channel-97")->toString)->toEqual(
      "/relayers/beeb-terra/oracle/channel-97",
    )
  )

  test("HomePage", () => expect(HomePage->toString)->toEqual("/"))
  test("NotFound", () => expect(NotFound->toString)->toEqual("/notfound"))
})

describe("Expect toAbsoluteString function to work correctly", () => {
  test("DataSourcePage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"data-sources"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(DataSourcePage)
  )

  test("DataSourceDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"data-source", "123"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(DataSourceDetailsPage(123, DataSourceRequests))
  )

  test("DataSourceDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"data-source", "123"},
        hash: "code",
        search: "",
      }
      url->fromUrl
    })->toEqual(DataSourceDetailsPage(123, DataSourceCode))
  )

  test("DataSourceDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"data-source", "123"},
        hash: "execute",
        search: "",
      }
      url->fromUrl
    })->toEqual(DataSourceDetailsPage(123, DataSourceExecute))
  )

  test("DataSourceDetailsPage NotFound", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"data-source", "test"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(NotFound)
  )

  test("OracleScriptPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"oracle-scripts"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(OracleScriptPage)
  )

  test("OracleScriptDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"oracle-script", "123"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(OracleScriptDetailsPage(123, OracleScriptRequests))
  )

  test("OracleScriptDetailsPage code", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"oracle-script", "123"},
        hash: "code",
        search: "",
      }
      url->fromUrl
    })->toEqual(OracleScriptDetailsPage(123, OracleScriptCode))
  )

  test("OracleScriptDetailsPage bridge", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"oracle-script", "123"},
        hash: "bridge",
        search: "",
      }
      url->fromUrl
    })->toEqual(OracleScriptDetailsPage(123, OracleScriptBridgeCode))
  )

  test("OracleScriptDetailsPage execute", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"oracle-script", "123"},
        hash: "execute",
        search: "",
      }
      url->fromUrl
    })->toEqual(OracleScriptDetailsPage(123, OracleScriptExecute))
  )

  test("OracleScriptDetailsPage revisions", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"oracle-script", "123"},
        hash: "revisions",
        search: "",
      }
      url->fromUrl
    })->toEqual(OracleScriptDetailsPage(123, OracleScriptRequests))
  )

  test("TxHomePage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"txs"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(TxHomePage)
  )

  test("TxIndexPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"tx", "1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(
      TxIndexPage(Hash.fromHex("1a4ef77bacf1634c08f1ab519c255f2abbf34742f18e91436b3d44190753ac51")),
    )
  )

  test("ValidatorsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"validators"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(ValidatorsPage)
  )

  test("BlockPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"blocks"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(BlockPage)
  )

  test("BlockDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"block", "123"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(BlockDetailsPage(123))
  )

  test("BlockDetailsPage NotFound", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"block", "test"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(NotFound)
  )

  test("RequestHomePage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"requests"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(RequestHomePage)
  )

  test("RequestDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"request", "123"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(RequestDetailsPage(123))
  )

  test("RequestDetailsPage NotFound", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"request", "test"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(NotFound)
  )

  test("AccountIndexPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"account", "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(
      AccountIndexPage(
        Address.fromBech32("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"),
        AccountPortfolio,
      ),
    )
  )

  test("AccountIndexPage transaction", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"account", "band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"},
        hash: "txs",
        search: "",
      }
      url->fromUrl
    })->toEqual(
      AccountIndexPage(
        Address.fromBech32("band18p27yl962l8283ct7srr5l3g7ydazj07dqrwph"),
        AccountTransaction,
      ),
    )
  )

  test("AccountIndexPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"account", "test"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(NotFound)
  )

  test("ValidatorDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"validator", "bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(
      ValidatorDetailsPage(
        Address.fromBech32("bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"),
        Reports,
      ),
    )
  )

  test("ValidatorDetailsPage delegators", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"validator", "bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"},
        hash: "delegators",
        search: "",
      }
      url->fromUrl
    })->toEqual(
      ValidatorDetailsPage(
        Address.fromBech32("bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"),
        Delegators,
      ),
    )
  )
  test("ValidatorDetailsPage reporters", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"validator", "bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"},
        hash: "reporters",
        search: "",
      }
      url->fromUrl
    })->toEqual(
      ValidatorDetailsPage(
        Address.fromBech32("bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"),
        Reporters,
      ),
    )
  )

  test("ValidatorDetailsPage proposed-blocks", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"validator", "bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"},
        hash: "proposed-blocks",
        search: "",
      }
      url->fromUrl
    })->toEqual(
      ValidatorDetailsPage(
        Address.fromBech32("bandvaloper1p40yh3zkmhcv0ecqp3mcazy83sa57rgjde6wec"),
        ProposedBlocks,
      ),
    )
  )

  test("ValidatorDetailsPage NotFound", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"validator", "test"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(NotFound)
  )

  test("ProposalPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"proposals"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(ProposalPage)
  )

  test("ProposalDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"proposal", "1"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(ProposalDetailsPage(1))
  )

  test("ProposalDetailsPage NotFound", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"proposal", "test"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(NotFound)
  )

  test("RelayersHomepage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"relayers"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(RelayersHomepage)
  )

  test("ChannelDetailsPage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"relayers", "beeb-terra", "oracle", "channel-97"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(ChannelDetailsPage("beeb-terra", "oracle", "channel-97"))
  )

  test("Homepage", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(HomePage)
  )

  test("NotFound", () =>
    expect({
      let url: RescriptReactRouter.url = {
        path: list{"test1234"},
        hash: "",
        search: "",
      }
      url->fromUrl
    })->toEqual(NotFound)
  )
})
