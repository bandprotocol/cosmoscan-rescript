module Styles = {
  open CssJs
  let infoHeader = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), #solid, theme.neutral_100), paddingBottom(#px(16))])

  let cardTotalRequest = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(16), ~h=#px(32)),
      borderRadius(#px(16)),
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      border(#px(1), #solid, theme.neutral_100),
      boxShadow(
        Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), ~spread=#px(1), rgba(16, 18, 20, #num(0.15))),
      ),
      maxWidth(#px(270)),
      marginLeft(#auto),
      Media.mobile([maxWidth(#percent(100.)), marginTop(#px(24)), padding(#px(16))]),
    ])

  let buttonStyled = style(. [
    backgroundColor(#transparent),
    border(#zero, #solid, #transparent),
    outlineStyle(#none),
    cursor(#pointer),
    padding2(~v=#zero, ~h=#zero),
    margin4(~top=#zero, ~right=#zero, ~bottom=#px(40), ~left=#zero),
  ])

  let addressWithcopy = style(. [selector(">a", [width(#auto)])])
}

module Content = {
  @react.component
  let make = (~dataSourceSub: Sub.variant<DataSourceSub.t>, ~dataSourceID, ~hashtag) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let isMobile = Media.isMobile()

    <>
      <Section>
        <div className=CssHelper.container>
          <button
            className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
            onClick={_ => Route.redirect(DataSourcePage)}>
            <Icon name="fa fa-angle-left" mr=8 size=16 />
            <Text
              value="Back to All Data Sources"
              weight={Semibold}
              size=Text.Xl
              color=theme.neutral_600
            />
          </button>
          <Row marginBottom=40 marginBottomSm=16 justify=Row.Between>
            <Col col=Col.Eight>
              {switch dataSourceSub {
              | Data({id, name}) =>
                <div className={CssHelper.flexBox()}>
                  // TODO: need to sync the Heading component with PR#101
                  <Text
                    code=true
                    size={Xxxxl}
                    weight={Bold}
                    value={`#D${id->ID.DataSource.toInt->Belt.Int.toString}`}
                    color={theme.neutral_900}
                  />
                  <HSpacing size=Spacing.sm />
                  <Heading size={Heading.H1} weight={Bold} value={name} />
                </div>
              | _ => <LoadingCensorBar width=270 height=15 />
              }}
            </Col>
            <Col col=Col.Four>
              <div className={Styles.cardTotalRequest(theme, isDarkMode)}>
                <Text value="Total Requests" size={Xl} /> // TODO: change to 24 hr request when data is ready
                <VSpacing size=Spacing.xs />
                {switch dataSourceSub {
                | Data({requestCount}) =>
                  <Text
                    size=Text.Xxxxl
                    value={requestCount->Format.iPretty}
                    code=true
                    color=theme.neutral_900
                    weight={Bold}
                  />
                | _ => <LoadingCensorBar width=100 height=15 />
                }}
              </div>
            </Col>
          </Row>
          <Row marginBottom=24>
            <Col>
              <InfoContainer>
                <Row marginBottom=24 alignItems=Row.Center>
                  <Col col=Col.Three mbSm=8>
                    <div className={CssHelper.flexBox()}>
                      <Heading
                        value="Owner" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                      />
                      <HSpacing size=Spacing.xs />
                      <CTooltip tooltipText="The owner of the data source">
                        <Icon name="fal fa-info-circle" size=10 color={theme.neutral_600} />
                      </CTooltip>
                    </div>
                  </Col>
                  <Col col=Col.Nine>
                    {switch dataSourceSub {
                    | Data({owner}) =>
                      <div className={Css.merge(list{CssHelper.flexBox(), Styles.addressWithcopy})}>
                        <AddressRender address=owner position=AddressRender.Subtitle copy=true />
                      </div>
                    | _ => <LoadingCensorBar width=284 height=15 />
                    }}
                  </Col>
                </Row>
                <Row marginBottom=24 alignItems=Row.Center>
                  <Col col=Col.Three mbSm=8>
                    <Heading
                      value="Treasury" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                    />
                  </Col>
                  <Col col=Col.Nine>
                    {switch dataSourceSub {
                    | Data({treasury}) =>
                      <div className={Css.merge(list{CssHelper.flexBox(), Styles.addressWithcopy})}>
                        <AddressRender address=treasury position=AddressRender.Subtitle copy=true />
                      </div>
                    | _ => <LoadingCensorBar width=284 height=15 />
                    }}
                  </Col>
                </Row>
                <Row marginBottom=24 alignItems=Row.Center>
                  <Col col=Col.Three mbSm=8>
                    <Heading
                      value="Fee" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                    />
                  </Col>
                  <Col col=Col.Nine>
                    {switch dataSourceSub {
                    | Data({fee}) =>
                      <AmountRender coins=fee pos=AmountRender.TxIndex color={theme.neutral_900} />
                    | _ => <LoadingCensorBar width=284 height=15 />
                    }}
                  </Col>
                </Row>
                <Row marginBottom=24 alignItems=Row.Center>
                  <Col col=Col.Three mbSm=8>
                    <Heading
                      value="Accumulated Revenue"
                      size=Heading.H4
                      weight=Heading.Thin
                      color={theme.neutral_600}
                    />
                  </Col>
                  <Col col=Col.Nine>
                    {switch dataSourceSub {
                    | Data({accumulatedRevenue}) =>
                      <AmountRender
                        coins=accumulatedRevenue pos=AmountRender.TxIndex color={theme.neutral_900}
                      />
                    | _ => <LoadingCensorBar width=284 height=15 />
                    }}
                  </Col>
                </Row>
                <Row marginBottom=24 alignItems=Row.Center>
                  <Col col=Col.Three mbSm=8>
                    <Heading
                      value="Last Updated"
                      size=Heading.H4
                      weight=Heading.Thin
                      color={theme.neutral_600}
                    />
                  </Col>
                  <Col col=Col.Nine>
                    {switch dataSourceSub {
                    | Data({timestamp}) =>
                      switch timestamp {
                      | Some(time) =>
                        <Timestamp
                          time code=true size={Body1} color={theme.neutral_900} weight={Thin}
                        />
                      | None =>
                        <Text value="N/A" code=true size={Body1} color={theme.neutral_900} />
                      }
                    | _ => <LoadingCensorBar width=284 height=15 />
                    }}
                  </Col>
                </Row>
                <Row alignItems=Row.Center>
                  <Col col=Col.Three mbSm=8>
                    <Heading
                      value="Description"
                      size=Heading.H4
                      weight=Heading.Thin
                      color={theme.neutral_600}
                    />
                  </Col>
                  <Col col=Col.Nine>
                    {switch dataSourceSub {
                    | Data({description}) =>
                      <Text size=Text.Body1 value=description color={theme.neutral_900} />
                    | _ => <LoadingCensorBar width=284 height=15 />
                    }}
                  </Col>
                </Row>
              </InfoContainer>
            </Col>
          </Row>
          <InfoContainer>
            <Tab.Route
              tabs=[
                {
                  name: "Requests",
                  route: dataSourceID->ID.DataSource.getRouteWithTab(_, Route.DataSourceRequests),
                },
                {
                  name: "Code",
                  route: dataSourceID->ID.DataSource.getRouteWithTab(_, Route.DataSourceCode),
                },
                {
                  name: "Test Execution",
                  route: dataSourceID->ID.DataSource.getRouteWithTab(_, Route.DataSourceExecute),
                },
              ]
              currentRoute={dataSourceID->ID.DataSource.getRouteWithTab(_, hashtag)}>
              {switch hashtag {
              | DataSourceExecute =>
                switch dataSourceSub {
                | Data({executable}) => <DataSourceExecute executable />
                | _ => <LoadingCensorBar.CircleSpin height=400 />
                }
              | DataSourceCode =>
                switch dataSourceSub {
                | Data({executable}) => <DataSourceCode executable />
                | _ => <LoadingCensorBar.CircleSpin height=300 />
                }
              | DataSourceRequests => <DataSourceRequestTable dataSourceID />
              }}
            </Tab.Route>
          </InfoContainer>
        </div>
      </Section>
    </>
  }
}

@react.component
let make = (~dataSourceID, ~hashtag) => {
  let dataSourceSub = DataSourceSub.get(dataSourceID)

  switch dataSourceSub {
  | NoData => <NotFound />
  | _ => <Content dataSourceSub dataSourceID hashtag />
  }
}
