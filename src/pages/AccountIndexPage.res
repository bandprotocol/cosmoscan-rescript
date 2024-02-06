@react.component
let make = (~address, ~hashtag: Route.account_tab_t) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

  <Section pt=24>
    <div className=CssHelper.container>
      <Row marginBottom=24 marginBottomSm=24>
        <Col>
          <Heading value="Account Details" size=Heading.H1 />
        </Col>
      </Row>
      <Row marginBottom=16 marginBottomSm=24>
        <Col col=Col.Three mbSm=8>
          <Text value="Band Address" size=Body1 />
        </Col>
        <Col col=Col.Nine>
          <AddressRender address position=AddressRender.Subtitle copy=true clickable=false />
        </Col>
      </Row>
      <Row marginBottom=16 marginBottomSm=24>
        <Col col=Col.Three mbSm=8>
          <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
            <Text value="Operator Address" size=Body1 />
            <HSpacing size={#px(4)} />
            <CTooltip tooltipText="The address used to show the validator's entity status">
              <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
            </CTooltip>
          </div>
        </Col>
        <Col col=Col.Nine>
          <AddressRender address position=AddressRender.Subtitle copy=true accountType=#validator />
        </Col>
      </Row>
      // TODO: wire up
      <Row marginBottom=40 marginBottomSm=40>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
            <Text value="Counter Party Address" size=Body1 />
            <HSpacing size={#px(4)} />
            <CTooltip tooltipText="The address used to show the counter party's entity status">
              <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
            </CTooltip>
          </div>
        </Col>
        <Col col=Col.Nine>
          <AddressRender address position=AddressRender.Subtitle copy=true clickable=false />
        </Col>
      </Row>
      <Tab.Route
        tabs=[
          {name: "Portfolio", route: Route.AccountIndexPage(address, AccountPortfolio)},
          {name: "Transaction", route: Route.AccountIndexPage(address, AccountTransaction)},
        ]
        currentRoute=Route.AccountIndexPage(address, hashtag)>
        {switch hashtag {
        | AccountPortfolio => <AccountIndexPortfolio address />
        | AccountTransaction => <AccountIndexTransactions accountAddress=address />
        }}
      </Tab.Route>
    </div>
  </Section>
}
