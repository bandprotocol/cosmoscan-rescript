module Styles = {
  open CssJs

  let greenDot = style(. [
    width(#px(8)),
    height(#px(8)),
    borderRadius(#percent(50.)),
    background(#hex("5FD3C8")),
    marginRight(#px(8)),
  ])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module ConnectionListDesktop = {
  module Styles = {
    open CssJs

    let listContainer = (theme: Theme.t) =>
      style(. [
        padding2(~v=#px(20), ~h=#px(32)),
        background(theme.neutral_100),
        borderRadius(#px(12)),
        marginBottom(#px(8)),
        overflow(#hidden),
      ])

    let toggleButton = {
      style(. [
        display(#flex),
        alignItems(#center),
        cursor(#pointer),
        padding2(~v=#px(10), ~h=#zero),
      ])
    }

    let portChannelWrapper = style(. [
      display(#flex),
      flexDirection(#row),
      justifyContent(#spaceBetween),
      alignItems(#center),
      marginBottom(#px(8)),
      selector(":last-child", [marginBottom(#zero)]),
    ])

    let channelSource = style(. [textAlign(#left)])
    let channelDest = style(. [
      textAlign(#right),
      //   marginLeft(#px(8)),
      Media.mobile([textAlign(#left)]),
    ])
  }

  @react.component
  let make = (~connectionSub: Sub.variant<ConnectionSub.internal_t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (show, setShow) = React.useState(_ => false)

    let toggle = () => setShow(prev => !prev)

    <div className={Styles.listContainer(theme)}>
      <Row alignItems=Row.Center>
        <Col col=Col.Two>
          {switch connectionSub {
          | Data({connectionID}) =>
            <div className={CssHelper.flexBox()}>
              <Text value=connectionID color={theme.neutral_900} />
            </div>
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </Col>
        <Col col=Col.Ten>
          <Row alignItems=Row.Center>
            <Col col=Col.Twelve>
              {switch connectionSub {
              | Data({channels, clientID, counterpartyClientID}) =>
                channels
                ->Belt.Array.mapWithIndex((i, channel) =>
                  <Row alignItems=Row.Center marginBottom=8>
                    <Col col=Col.Four>
                      <div
                        className={Css.merge(list{Styles.portChannelWrapper})}
                        key={i->Belt.Int.toString}>
                        <div
                          className={
                            open CssJs
                            Css.merge(list{Styles.channelSource, style(. [width(#px(80))])})
                          }>
                          <Text value={channel.port} color={theme.neutral_900} />
                          <Text
                            value={channel.channelID}
                            color={theme.primary_600}
                            weight={Text.Semibold}
                          />
                        </div>
                        <div
                          className={
                            open CssJs
                            Css.merge(list{style(. [width(#px(42))])})
                          }>
                          <img
                            alt="arrow"
                            src={isDarkMode
                              ? Images.connectionArrowLight
                              : Images.connectionArrowDark}
                            className="img-fluid"
                          />
                        </div>
                        <div
                          className={
                            open CssJs
                            Css.merge(list{Styles.channelDest, style(. [width(#px(100))])})
                          }>
                          <Text
                            value={channel.counterpartyPort}
                            nowrap=true
                            ellipsis=true
                            block=true
                            color={theme.neutral_900}
                          />
                          <Text
                            value={channel.counterpartyChannelID}
                            color={theme.primary_600}
                            weight={Text.Semibold}
                          />
                        </div>
                      </div>
                    </Col>
                    <Col col=Col.Two>
                      <div className={CssHelper.flexBox()}>
                        <Text value=clientID color={theme.neutral_900} />
                      </div>
                    </Col>
                    <Col col=Col.Three>
                      <div className={CssHelper.flexBox()}>
                        <Text value=counterpartyClientID color={theme.neutral_900} />
                      </div>
                    </Col>
                    <Col col=Col.One>
                      <div className={CssHelper.flexBox()}>
                        <Text value=channel.order color={theme.neutral_900} />
                      </div>
                    </Col>
                    <Col col=Col.Two>
                      <div className={CssHelper.flexBox(~justify=#center, ())}>
                        {switch channel.state {
                        | Open => <img alt="Success Icon" src=Images.success />
                        | _ => <img alt="Fail Icon" src=Images.fail />
                        }}
                      </div>
                    </Col>
                  </Row>
                )
                ->React.array
              | _ => <LoadingCensorBar width=80 height=15 />
              }}
            </Col>
            // <Col col=Col.Two>
            //   {switch connectionSub {
            //   | Data({clientID, channels}) =>
            //     channels
            //     ->Belt.Array.mapWithIndex((i, _) => {
            //       <div className={CssHelper.flexBox()} key={i->Belt.Int.toString}>
            //         <Text value=clientID color={theme.neutral_900} />
            //       </div>
            //     })
            //     ->React.array
            //   // <div className={CssHelper.flexBox()}>
            //   //   <Text value=clientID color={theme.neutral_900} />
            //   // </div>
            //   | _ => <LoadingCensorBar width=80 height=15 />
            //   }}
            // </Col>
            // <Col col=Col.Two>
            //   {switch connectionSub {
            //   | Data({channels, counterpartyClientID}) =>
            //     // <div className={CssHelper.flexBox()}>
            //     //   <Text value=counterpartyClientID color={theme.neutral_900} />
            //     // </div>
            //     channels
            //     ->Belt.Array.mapWithIndex((i, _) => {
            //       <div className={CssHelper.flexBox()} key={i->Belt.Int.toString}>
            //         <Text value=counterpartyClientID color={theme.neutral_900} />
            //       </div>
            //     })
            //     ->React.array
            //   | _ => <LoadingCensorBar width=80 height=15 />
            //   }}
            // </Col>
            // <Col col=Col.One>
            //   {switch connectionSub {
            //   | Data({channels}) =>
            //     channels
            //     ->Belt.Array.mapWithIndex((i, channel) => {
            //       <div className={CssHelper.flexBox()} key={i->Belt.Int.toString}>
            //         <Text value=channel.order color={theme.neutral_900} />
            //       </div>
            //     })
            //     ->React.array
            //   | _ => <LoadingCensorBar width=80 height=15 />
            //   }}
            // </Col>
          </Row>
        </Col>
        // <Col col=Col.Three>
        //   <div className={CssHelper.flexBox(~justify=#flexEnd, ())} onClick={_ => toggle()}>
        //     <div className=Styles.toggleButton>
        //       <Text value={show ? "Hide Channels" : "Show Channels"} color={theme.neutral_900} />
        //       <HSpacing size=Spacing.sm />
        //       <Icon
        //         name={show ? "fas fa-caret-up" : "fas fa-caret-down"} color={theme.neutral_600}
        //       />
        //     </div>
        //   </div>
        // </Col>
      </Row>
      //   {switch connectionSub {
      //   | Data({channels}) => <ChannelTable channels show />
      //   | _ => React.null
      //   }}
    </div>
  }
}

module ConnectionListMobile = {
  module Styles = {
    open CssJs

    let root = style(. [
      marginBottom(#px(8)),
      Media.mobile([padding4(~top=#px(22), ~left=#px(16), ~right=#px(16), ~bottom=#px(5))]),
    ])

    let cardContainer = style(. [
      position(#relative),
      selector("> div + div", [marginTop(#px(12))]),
    ])

    let labelWrapper = style(. [
      display(#flex),
      flexDirection(#column),
      flexGrow(0.),
      flexShrink(0.),
      flexBasis(#percent(30.)),
      paddingRight(#px(10)),
    ])

    let valueWrapper = style(. [
      display(#flex),
      flexDirection(#column),
      flexGrow(0.),
      flexShrink(0.),
      flexBasis(#percent(70.)),
      selector("i", [margin2(~v=#zero, ~h=#px(8))]),
    ])

    let toggleButton = {
      style(. [
        display(#flex),
        width(#percent(100.)),
        justifyContent(#center),
        alignItems(#center),
        cursor(#pointer),
        padding2(~v=#px(10), ~h=#zero),
        marginTop(#px(11)),
      ])
    }
  }

  @react.component
  let make = (~connectionSub: Sub.variant<ConnectionSub.internal_t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (show, setShow) = React.useState(_ => false)

    let toggle = () => setShow(prev => !prev)

    <InfoContainer style=Styles.root>
      <div className=Styles.cardContainer>
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <div className=Styles.labelWrapper>
            <Text
              value="Connection" size=Text.Body2 transform=Text.Uppercase weight=Text.Semibold
            />
          </div>
          <div className=Styles.valueWrapper>
            {switch connectionSub {
            | Data({connectionID}) => <Text value=connectionID color={theme.neutral_900} />
            | _ => <LoadingCensorBar width=60 height=15 />
            }}
          </div>
        </div>
        <div className={CssHelper.flexBox(~align=#flexStart, ())}>
          <div className=Styles.labelWrapper>
            <Text
              value="Counterparty Chain ID"
              size=Text.Body2
              transform=Text.Uppercase
              weight=Text.Semibold
            />
          </div>
          <div className=Styles.valueWrapper>
            {switch connectionSub {
            | Data({counterpartyChainID}) =>
              <Text value=counterpartyChainID color={theme.neutral_600} />
            | _ => <LoadingCensorBar width=60 height=15 />
            }}
          </div>
        </div>
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <div className=Styles.labelWrapper>
            <Text value="Client ID" size=Text.Body2 transform=Text.Uppercase weight=Text.Semibold />
          </div>
          <div className=Styles.valueWrapper>
            {switch connectionSub {
            | Data({clientID}) => <Text value=clientID color={theme.neutral_600} />
            | _ => <LoadingCensorBar width=60 height=15 />
            }}
          </div>
        </div>
        <div className={CssHelper.flexBox(~align=#flexStart, ())}>
          <div className=Styles.labelWrapper>
            <Text
              value="Counterparty Client ID"
              size=Text.Body2
              transform=Text.Uppercase
              weight=Text.Semibold
            />
          </div>
          <div className=Styles.valueWrapper>
            {switch connectionSub {
            | Data({counterpartyClientID}) =>
              <Text value=counterpartyClientID color={theme.neutral_600} />
            | _ => <LoadingCensorBar width=60 height=15 />
            }}
          </div>
        </div>
      </div>
      //   {switch connectionSub {
      //   | Data({channels}) => <ChannelTable channels show />
      //   | _ => React.null
      //   }}
      //   <div className=Styles.toggleButton onClick={_ => toggle()}>
      //     <Text value={show ? "Hide Channels" : "Show Channels"} color={theme.neutral_900} />
      //     <HSpacing size=Spacing.sm />
      //     <Icon name={show ? "fas fa-caret-up" : "fas fa-caret-down"} color={theme.neutral_600} />
      //   </div>
    </InfoContainer>
  }
}

@react.component
let make = (~counterpartyChainID) => {
  let (searchTerm, setSearchTerm) = React.useState(_ => "")
  let isMobile = Media.isMobile()
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 10
  //   let connectionCountSub = ConnectionSub.getCount(
  //     ~counterpartyChainID,
  //     ~connectionID=searchTerm,
  //     (),
  //   )
  let conntectionsSub = ConnectionSub.getList(
    ~counterpartyChainID,
    ~connectionID=searchTerm,
    ~pageSize,
    ~page,
    (),
  )
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  React.useEffect1(() => {
    setPage(_ => 1)
    None
  }, [searchTerm, counterpartyChainID])

  <>
    // <Row alignItems=Row.Center marginTop=80 marginTopSm=36>
    //   <Col col=Col.Twelve>
    //     <div className={CssHelper.flexBox()}>
    //       <div className=Styles.greenDot />
    //       <Heading value="Live Connection" size=Heading.H2 />
    //     </div>
    //   </Col>
    // </Row>
    // <Row marginTop=32 marginBottom=32>
    //   <Col col=Col.Twelve>
    //     <SearchInput placeholder="Search Connection ID" onChange=setSearchTerm maxWidth=370 />
    //   </Col>
    // </Row>
    // Table Head
    {!isMobile
      ? <div className={CssHelper.px(~size=32, ())}>
          <Row alignItems=Row.Center minHeight={#px(32)}>
            <Col col=Col.Two>
              <div className={CssHelper.flexBox()}>
                <Text value="Connection ID" size=Text.Body2 />
              </div>
            </Col>
            <Col col=Col.Ten>
              <Row>
                <Col col=Col.Four>
                  <div className={CssHelper.flexBox()}>
                    <Text value="Port & Channel" size=Text.Body2 />
                  </div>
                </Col>
                <Col col=Col.Two>
                  <div className={CssHelper.flexBox()}>
                    <Text value="Client ID" size=Text.Body2 />
                  </div>
                </Col>
                <Col col=Col.Three>
                  <div className={CssHelper.flexBox()}>
                    <Text value="Counterparty Client ID" size=Text.Body2 />
                  </div>
                </Col>
                <Col col=Col.One>
                  <div className={CssHelper.flexBox()}>
                    <Text value="Order" size=Text.Body2 />
                  </div>
                </Col>
                <Col col=Col.Two>
                  <div className={CssHelper.flexBox(~justify=#center, ())}>
                    <Text value="State" size=Text.Body2 />
                  </div>
                </Col>
              </Row>
            </Col>
          </Row>
        </div>
      : React.null}
    // Table List
    {switch conntectionsSub {
    | Data(connections) if connections->Belt.Array.length == 0 =>
      <EmptyContainer>
        <img
          alt="No Connections"
          src={isDarkMode ? Images.noDataDark : Images.noDataLight}
          className=Styles.noDataImage
        />
        <Heading
          size=Heading.H4
          value="No Connections"
          align=Heading.Center
          weight=Heading.Regular
          color={theme.neutral_600}
        />
      </EmptyContainer>
    | Data(connections) =>
      connections
      ->Belt.Array.map(connection =>
        isMobile
          ? <ConnectionListMobile
              key={connection.connectionID} connectionSub={Sub.resolve(connection)}
            />
          : <ConnectionListDesktop
              key={connection.connectionID} connectionSub={Sub.resolve(connection)}
            />
      )
      ->React.array
    | _ =>
      Belt.Array.makeBy(pageSize, i =>
        isMobile
          ? <ConnectionListMobile key={i->Belt.Int.toString} connectionSub=NoData />
          : <ConnectionListDesktop key={i->Belt.Int.toString} connectionSub=NoData />
      )->React.array
    }}
    // {switch connectionCountSub {
    // | Data(connectionCount) =>
    //   let pageCount = Page.getPageCount(connectionCount, pageSize)
    //   <Pagination currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)} />
    // | _ => React.null
    // }}
  </>
}
