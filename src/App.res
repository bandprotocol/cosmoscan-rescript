module Styles = {
  open CssJs

  let container = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      position(#relative),
      overflow(#auto),
      backgroundColor(theme.neutral_000),
    ])

  let routeContainer = style(. [
    minHeight(#calc(#sub, #vh(100.), #px(193))),
    Media.mobile([paddingBottom(#zero)]),
  ])

  let mainContent = style(. [
    width(#percent(100.)),
    position(#relative),
    overflow(#auto),
    paddingBottom(#px(70)),
    paddingTop(#px(70)),
    Media.mobile([paddingBottom(#px(0)), minHeight(#calc(#sub, #vh(100.), #px(193)))]),
  ])

  let backdropContainer = show =>
    style(. [
      display(#none),
      Media.mobile([
        display(#block),
        width(#percent(100.)),
        height(#percent(100.)),
        backgroundColor(#rgba((0, 0, 0, #num(0.5)))),
        position(#fixed),
        opacity(show ? 1. : 0.),
        pointerEvents(show ? #auto : #none),
        left(#zero),
        top(#px(0)),
        transition(~duration=400, "all"),
        zIndex(900),
      ]),
    ])

  let pageWrapper = style(. [display(#flex), height(#vh(100.)), overflow(#hidden)])
}

@react.component
let make = () => {
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let (show, setShow) = React.useState(_ => false)
  let currentPath = RescriptReactRouter.useUrl().path
  let currentRoute = RescriptReactRouter.useUrl()->Route.fromUrl

  React.useEffect1(_ => {
    setShow(_ => false)
    None
  }, [currentPath])

  <div className={Css.merge(list{"page-wrapper", Styles.pageWrapper})}>
    <Sidebar show setShow />
    <div className={Css.merge(list{"main-content", Styles.container(theme), Styles.mainContent})}>
      <Header setShow show />
      <Notibar />
      <div className=Styles.routeContainer>
        {switch currentRoute {
        | HomePage => <HomePage />
        | DataSourcePage => <DataSourcePage />
        | DataSourceDetailsPage(dataSourceID, hashtag) =>
          <DataSourceDetailsPage dataSourceID=ID.DataSource.ID(dataSourceID) hashtag />
        | OracleScriptPage => <OracleScriptPage />
        | OracleScriptDetailsPage(oracleScriptID, hashtag) =>
          <OracleScriptDetailsPage oracleScriptID=ID.OracleScript.ID(oracleScriptID) hashtag />
        | TxHomePage => <TxHomePage />
        | TxIndexPage(txHash) => <TxIndexPage txHash />
        | BlockPage => <BlockPage />
        | BlockDetailsPage(height) => <BlockDetailsPage height=ID.Block.ID(height) />
        | ValidatorsPage => <ValidatorsPage />
        | ValidatorDetailsPage(address, hashtag) => <ValidatorDetailsPage address hashtag />
        | RequestHomePage => <RequestHomePage />
        | RequestDetailsPage(reqID) => <RequestDetailsPage reqID=ID.Request.ID(reqID) />
        | AccountIndexPage(address, hashtag) => <AccountIndexPage address hashtag />
        | ProposalPage => <ProposalPage />
        | ProposalDetailsPage(proposalID) =>
          <ProposalDetailsPage proposalID=ID.Proposal.ID(proposalID) />
        | RelayersHomepage => <RelayersHomepage />
        | ChannelDetailsPage(chainID, port, channel) => <ChannelPage chainID channel port />
        | NotFound => <NotFound />
        | GroupPage(hashtag) => <GroupPage hashtag />
        }}
      </div>
      <Footer />
    </div>
    <Modal />
    <CookieBar />
    <div onClick={_ => setShow(_ => false)} className={Styles.backdropContainer(show)} />
  </div>
}
