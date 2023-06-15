module Styles = {
  open CssJs
  let titleSpacing = style(. [marginBottom(#px(4))])
  let idCointainer = style(. [marginBottom(#px(16))])
  let containerSpacingSm = style(. [Media.mobile([marginTop(#px(16))])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let noPadding = style(. [padding(#zero)])
  let info = style(. [borderRadius(#px(16))])
  let monoFont = style(. [fontFamilies([#custom("Roboto Mono"), #monospace])])

  let buttonStyled = style(. [
    backgroundColor(#transparent),
    border(#zero, #solid, #transparent),
    outlineStyle(#none),
    cursor(#pointer),
    padding2(~v=#zero, ~h=#zero),
    margin4(~top=#zero, ~right=#zero, ~bottom=#px(40), ~left=#zero),
  ])

  let relatedDSContainer = style(. [
    selector("> div + div", [marginTop(#px(16))]),
    selector("> div > a", [marginRight(#px(8))]),
  ])
}

module Content = {
  @react.component
  let make = (~oracleScriptSub: Sub.variant<OracleScriptSub.t>, ~oracleScriptID, ~hashtag) => {
    let statSub = OracleScriptSub.getResponseTime(oracleScriptID)

    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <Section>
      <div className=CssHelper.container>
        <button
          className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
          onClick={_ => Route.redirect(OracleScriptPage)}>
          <Icon name="fa fa-angle-left" mr=8 size=14 />
          <Text value="Back to all oracle scripts" size=Text.Xl color=theme.neutral_600 />
        </button>
        <Row marginBottom=24 marginBottomSm=24 alignItems=Row.Center>
          <Col col=Col.Six>
            <div className={Css.merge(list{CssHelper.flexBox(), Styles.idCointainer})}>
              {switch oracleScriptSub {
              | Data({id, name}) =>
                <Heading size=Heading.H1 weight=Heading.Bold>
                  <span className=Styles.monoFont>
                    {`#O${id->ID.OracleScript.toInt->Belt.Int.toString} `->React.string}
                  </span>
                  <span> {name->React.string} </span>
                </Heading>
              | _ => <LoadingCensorBar width=270 height=15 />
              }}
            </div>
          </Col>
          <Col col=Col.Three colSm=Col.Six>
            <InfoContainer py=16 style=Styles.info>
              <Heading
                value="24 hr Requests"
                size=Heading.H4
                weight=Heading.Thin
                color={theme.neutral_600}
                marginBottom=4
              />
              {switch oracleScriptSub {
              | Data({requestCount}) =>
                <Text
                  // TODO: change to 24 hours when graphql database is ready
                  value={requestCount->Format.iPretty}
                  size=Text.Xxxxl
                  block=true
                  weight=Text.Bold
                  color={theme.neutral_900}
                  code=true
                />
              | _ => <LoadingCensorBar width=100 height=15 />
              }}
            </InfoContainer>
          </Col>
          <Col col=Col.Three colSm=Col.Six>
            <InfoContainer py=16 style=Styles.info>
              <div className={Css.merge(list{CssHelper.flexBox(), Styles.titleSpacing})}>
                <Heading
                  value="Response Time"
                  size=Heading.H4
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                <HSpacing size=Spacing.xs />
                <CTooltip
                  tooltipPlacementSm=CTooltip.BottomRight
                  tooltipText="The average time requests to this oracle script takes to resolve">
                  <Icon name="fal fa-info-circle" size=12 color={theme.neutral_600} />
                </CTooltip>
              </div>
              {switch statSub {
              | Data(statOpt) =>
                <Text
                  value={switch statOpt {
                  | Some({responseTime}) =>
                    responseTime->Belt.Option.getExn->Format.fPretty(~digits=2)
                  | None => "TBD"
                  }}
                  size=Text.Xxxxl
                  weight=Text.Bold
                  block=true
                  code=true
                  color={theme.neutral_900}
                />
              | Error(_) | Loading | NoData => <LoadingCensorBar width=100 height=15 />
              }}
            </InfoContainer>
          </Col>
        </Row>
        <Row marginBottom=24 marginLeft=0 marginRight=0>
          <Col style=Styles.noPadding>
            <InfoContainer py=24 pySm=24>
              <Row marginBottom=16 alignItems=Row.Center>
                <Col col=Col.Two mbSm=8>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Owner" size=Heading.H5 weight=Heading.Thin color={theme.neutral_600}
                    />
                    <HSpacing size=Spacing.xs />
                    <CTooltip tooltipText="The owner of the oracle script">
                      <Icon name="fal fa-info-circle" size=10 color={theme.neutral_600} />
                    </CTooltip>
                  </div>
                </Col>
                <Col col=Col.Ten>
                  {switch oracleScriptSub {
                  | Data({owner}) =>
                    <AddressRender address=owner position=AddressRender.Subtitle copy=true />
                  | Error(_) | Loading | NoData => <LoadingCensorBar width=284 height=15 />
                  }}
                </Col>
              </Row>
              <Row marginBottom=16>
                <Col col=Col.Two mbSm=8>
                  <div className={Css.merge(list{CssHelper.flexBox(), Styles.containerSpacingSm})}>
                    <Heading
                      value="Data Sources"
                      size=Heading.H5
                      weight=Heading.Thin
                      color={theme.neutral_600}
                    />
                    <HSpacing size=Spacing.xs />
                    <CTooltip tooltipText="The data sources used in this oracle script">
                      <Icon name="fal fa-info-circle" size=10 color={theme.neutral_600} />
                    </CTooltip>
                  </div>
                </Col>
                <Col col=Col.Ten>
                  <Row marginLeft=0 marginRight=0>
                    {switch oracleScriptSub {
                    | Data({relatedDataSources}) =>
                      relatedDataSources->Belt.List.size > 0
                        ? relatedDataSources
                          ->Belt.List.sort((a, b) =>
                            a.dataSourceID->ID.DataSource.toInt -
                              b.dataSourceID->ID.DataSource.toInt
                          )
                          ->Belt.List.map(({dataSourceName, dataSourceID}) =>
                            <Col
                              col={relatedDataSources->Belt.List.size > 10 ? Col.Six : Col.Twelve}
                              key={dataSourceID->ID.DataSource.toString}
                              style={Styles.noPadding}
                              mb=12>
                              <div className={CssHelper.flexBox()}>
                                <TypeID.DataSource id=dataSourceID position=TypeID.Subtitle />
                                <HSpacing size=Spacing.sm />
                                <Text
                                  value=dataSourceName
                                  size=Text.Body1
                                  block=true
                                  color={theme.neutral_900}
                                />
                              </div>
                            </Col>
                          )
                          ->Belt.List.toArray
                          ->React.array
                        : <Text value="TBD" size=Text.Body1 block=true />

                    | Error(_) | Loading | NoData => <LoadingCensorBar width=284 height=15 />
                    }}
                  </Row>
                </Col>
              </Row>
              <Row marginBottom=16>
                <Col col=Col.Two mbSm=8>
                  <Heading
                    value="Created / Last Updated"
                    size=Heading.H5
                    weight=Heading.Thin
                    color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Ten>
                  {switch oracleScriptSub {
                  | Data({timestampOpt}) =>
                    <Text
                      value={switch timestampOpt {
                      | Some(timestamp) =>
                        timestamp->MomentRe.Moment.format("YYYY-MM-DD HH:mm:ss", _)
                      | None => "N/A"
                      }}
                      size=Text.Body1
                      block=true
                    />
                  | Error(_) | Loading | NoData => <LoadingCensorBar width=284 height=15 />
                  }}
                </Col>
              </Row>
              <Row marginBottom=16>
                <Col col=Col.Two mbSm=8>
                  <Heading
                    value="Version" size=Heading.H5 weight=Heading.Thin color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Ten>
                  <div className={CssHelper.flexBox()}>
                    {switch oracleScriptSub {
                    | Data({version}) =>
                      switch version {
                      | Ok => <Chip value="Upgraded" color=theme.upgraded />
                      | Redeploy => <Chip value="Redeployment Needed" color=theme.warning_600 />
                      | _ => <Chip value="Unknown" color=theme.neutral_600 />
                      }
                    | _ => <LoadingCensorBar width=284 height=15 />
                    }}
                  </div>
                </Col>
              </Row>
              <Row>
                <Col col=Col.Two mbSm=8>
                  <Heading
                    value="Description"
                    size=Heading.H5
                    weight=Heading.Thin
                    color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Ten>
                  {switch oracleScriptSub {
                  | Data({description}) => <Text value=description size=Text.Body1 block=true />
                  | Error(_) | Loading | NoData => <LoadingCensorBar width=284 height=15 />
                  }}
                </Col>
              </Row>
            </InfoContainer>
          </Col>
        </Row>
        <Table>
          <Tab.Route
            tabs=[
              {
                name: "Requests",
                route: oracleScriptID->ID.OracleScript.getRouteWithTab(Route.OracleScriptRequests),
              },
              {
                name: "OWASM Code",
                route: oracleScriptID->ID.OracleScript.getRouteWithTab(Route.OracleScriptCode),
              },
              {
                name: "Bridge Code",
                route: oracleScriptID->ID.OracleScript.getRouteWithTab(
                  Route.OracleScriptBridgeCode,
                ),
              },
              {
                name: "Make New Request",
                route: oracleScriptID->ID.OracleScript.getRouteWithTab(Route.OracleScriptExecute),
              },
            ]
            currentRoute={oracleScriptID->ID.OracleScript.getRouteWithTab(hashtag)}>
            {switch hashtag {
            | OracleScriptExecute =>
              switch oracleScriptSub {
              | Data({schema}) => <OracleScriptExecute id=oracleScriptID schema />
              | Error(_) | Loading | NoData => <LoadingCensorBar.CircleSpin height=400 />
              }
            | OracleScriptCode =>
              switch oracleScriptSub {
              | Data({sourceCodeURL}) if sourceCodeURL !== "" =>
                <OracleScriptCode url=sourceCodeURL />
              | Loading => <LoadingCensorBar.CircleSpin height=400 />
              | Data(_) | Error(_) | NoData =>
                <EmptyContainer>
                  <img
                    src={isDarkMode ? Images.noOracleDark : Images.noOracleLight}
                    className=Styles.noDataImage
                    alt="Unable to access OWASM Code"
                  />
                  <Heading
                    size=Heading.H4
                    value="Unable to access OWASM Code"
                    align=Heading.Center
                    weight=Heading.Regular
                    color={theme.neutral_600}
                  />
                </EmptyContainer>
              }
            | OracleScriptBridgeCode =>
              switch oracleScriptSub {
              | Data({schema}) => <OracleScriptBridgeCode schema />
              | Error(_) | Loading | NoData => <LoadingCensorBar.CircleSpin height=400 />
              }
            | OracleScriptRequests => <OracleScriptRequestTable oracleScriptID />
            }}
          </Tab.Route>
        </Table>
      </div>
    </Section>
  }
}

@react.component
let make = (~oracleScriptID, ~hashtag) => {
  let oracleScriptSub = OracleScriptSub.get(oracleScriptID)

  switch oracleScriptSub {
  | NoData => <NotFound />
  | Data(_) | Error(_) | Loading => <Content oracleScriptSub oracleScriptID hashtag />
  }
}
