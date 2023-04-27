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
}

@react.component
let make = () => {
  let currentRoute = RescriptReactRouter.useUrl()->Route.fromUrl
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className={Styles.container(theme)}>
    <Header />
    // {isMobile
    //   ? <Section pt=16 pb=16 ptSm=24 pbSm=24>
    //       <div className=CssHelper.container>
    //         <SearchBarV2 />
    //       </div>
    //     </Section>
    //   : React.null}
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
      }}
    </div>
    <Footer />
    <Modal />
  </div>
}
