module Styles = {
  open CssJs

  let container = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      position(#relative),
      overflow(#auto),
      backgroundColor(theme.mainBg),
    ])

  let routeContainer = style(. [
    minHeight(#calc(#sub, #vh(100.), #px(193))),
    Media.mobile([paddingBottom(#zero)]),
  ])
}

@react.component
let make = () => {
  let currentRoute = RescriptReactRouter.useUrl() |> Route.fromUrl
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className={Styles.container(theme)}>
    <Header />
    {isMobile
      ? <Section pt=16 pb=16 ptSm=24 pbSm=24>
          <div className=CssHelper.container> <SearchBar /> </div>
        </Section>
      : React.null}
    <div className=Styles.routeContainer>
      {switch currentRoute {
      | HomePage => <HomePage />
      | DataSourceHomePage => <DataSourceHomePage />
      | DataSourceIndexPage(dataSourceID, hashtag) =>
        <DataSourceIndexPage dataSourceID=ID.DataSource.ID(dataSourceID) hashtag />
      | OracleScriptPage => <OracleScriptPage />
      | OracleScriptDetailsPage(oracleScriptID, hashtag) =>
        <OracleScriptDetailsPage oracleScriptID=ID.OracleScript.ID(oracleScriptID) hashtag />
      | TxHomePage => <TxHomePage />
      | TxIndexPage(txHash) => <TxIndexPage txHash />
      | BlockHomePage => <BlockHomePage />
      | BlockIndexPage(height) => <BlockIndexPage height=ID.Block.ID(height) />
      | ValidatorHomePage => <ValidatorHomePage />
      | ValidatorIndexPage(address, hashtag) => <ValidatorIndexPage address hashtag />
      | RequestHomePage => <RequestHomePage />
      | RequestIndexPage(reqID) => <RequestIndexPage reqID=ID.Request.ID(reqID) />
      | AccountIndexPage(address, hashtag) => <AccountIndexPage address hashtag />
      | ProposalPage => <ProposalPage />
      | ProposalDetailsPage(proposalID) => <ProposalDetailsPage proposalID=ID.Proposal.ID(proposalID) />
      | IBCHomePage => <IBCHomePage />
      | NotFound => <NotFound />
      }}
    </div>
    <Footer />
    <Modal />
  </div>
}
