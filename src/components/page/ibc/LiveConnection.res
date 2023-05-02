module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let divider = (theme: Theme.t) =>
    style(. [
      height(#px(1)),
      background(theme.neutral_400),
      width(#percent(100.)),
      marginTop(#px(16)),
      marginBottom(#px(16)),
    ])

  let listContainer = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(20), ~h=#px(32)),
      background(isDarkMode ? theme.neutral_200 : theme.neutral_100),
      borderRadius(#px(12)),
      marginBottom(#px(8)),
      overflow(#hidden),
      Media.mobile([padding2(~v=#px(16), ~h=#px(16)), borderRadius(#px(8))]),
    ])

  let channelWrapper = style(. [selector("> div:last-child:after", [background(#none)])])
}

module ConnectionListDesktop = {
  module ChannelItem = {
    module Styles = {
      open CssJs

      let channelSource = style(. [textAlign(#left)])
      let channelDest = style(. [textAlign(#right), Media.mobile([textAlign(#left)])])
      let channelItem = (theme: Theme.t) =>
        style(. [
          padding2(~v=#px(16), ~h=#zero),
          cursor(#pointer),
          borderRadius(#px(4)),
          position(#relative),
          hover([background(theme.neutral_200)]),
          after([
            contentRule(#text("")),
            display(#block),
            width(#percent(100.)),
            height(#px(1)),
            background(theme.neutral_200),
            position(#absolute),
            bottom(#zero),
            left(#zero),
            // borderTop(#px(1), solid, theme.neutral_200),
          ]),
        ])
    }
    @react.component
    let make = (~chain, ~channel: ConnectionSub.external_channel_t, ~index: int) => {
      let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

      <div className={Styles.channelItem(theme)}>
        <Link
          className="channel-link"
          route={Route.ChannelDetailsPage(chain, channel.port, channel.channelID)}>
          <Row alignItems=Row.Center>
            <Col col=Col.One>
              <div className={CssHelper.flexBox(~justify=#flexStart, ())}>
                <Text value={"#" ++ string_of_int(index + 1)} />
              </div>
            </Col>
            <Col col=Col.Four>
              <Row alignItems=Row.Center>
                <Col col=Col.Four>
                  {
                    let port = Ellipsis.format(~text=channel.port, ~limit=25, ())
                    <Text
                      value={port} nowrap=true ellipsis=true block=true color={theme.neutral_900}
                    />
                  }
                  <Text
                    value={channel.channelID} color={theme.primary_600} weight={Text.Semibold}
                  />
                </Col>
                <Col col=Col.Four>
                  <div className={CssHelper.flexBox(~justify=#center, ())}>
                    <img
                      alt="arrow"
                      src={isDarkMode ? Images.connectionArrowLight : Images.connectionArrowDark}
                      className="img-fluid"
                    />
                  </div>
                </Col>
                <Col col=Col.Four>
                  {
                    let port = Ellipsis.format(~text=channel.counterpartyPort, ~limit=25, ())
                    <Text
                      value={port} nowrap=true ellipsis=true block=true color={theme.neutral_900}
                    />
                  }
                  <Text
                    value={channel.counterpartyChannelID}
                    color={theme.primary_600}
                    weight={Text.Semibold}
                  />
                </Col>
              </Row>
            </Col>
            <Col col=Col.One offset=Col.One>
              <div className={CssHelper.flexBox(~justify=#center, ~align=#center, ())}>
                <Text
                  value={channel.totalPacketsCount->Format.iPretty}
                  color={theme.neutral_900}
                  code=true
                />
              </div>
            </Col>
            <Col col=Col.Two>
              <div className={CssHelper.flexBox(~justify=#center, ~align=#center, ())}>
                {channel.lastUpdate->MomentRe.Moment.year == 1970
                  ? <Text value={"N/A"} code=true color={theme.neutral_900} size=Text.Body2 />
                  : <TimeAgos
                      time={channel.lastUpdate} size=Text.Body2 color={theme.neutral_900} code=true
                    />}
              </div>
            </Col>
            <Col col=Col.Two>
              <div className={CssHelper.flexBox(~justify=#center, ~align=#center, ())}>
                <Text value=channel.order color={theme.neutral_900} />
              </div>
            </Col>
            <Col col=Col.One>
              <div className={CssHelper.flexBox(~justify=#center, ())}>
                {switch channel.state {
                | Open => <img alt="Success Icon" src=Images.success />
                | _ => <img alt="Fail Icon" src=Images.fail />
                }}
              </div>
            </Col>
          </Row>
        </Link>
      </div>
    }
  }

  @react.component
  let make = (~connectionSub: Sub.variant<ConnectionSub.t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.listContainer(theme, isDarkMode)}>
      <Row alignItems=Row.Center>
        <Col col=Col.Four>
          {switch connectionSub {
          | Data({connectionID}) =>
            <div className={CssHelper.flexBox()}>
              <Text value="Connection ID:" />
              <HSpacing size=Spacing.sm />
              <Text value=connectionID color={theme.neutral_900} code=true weight={Semibold} />
            </div>
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </Col>
        <Col col=Col.Four>
          {switch connectionSub {
          | Data({clientID}) =>
            <div className={CssHelper.flexBox()}>
              <Text value="Client ID:" />
              <HSpacing size=Spacing.sm />
              <Text value=clientID color={theme.neutral_900} code=true weight={Semibold} />
            </div>
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </Col>
        <Col col=Col.Four>
          {switch connectionSub {
          | Data({counterpartyClientID}) =>
            <div className={CssHelper.flexBox()}>
              <Text value="Counterparty Client ID:" />
              <HSpacing size=Spacing.sm />
              <Text
                value=counterpartyClientID color={theme.neutral_900} code=true weight={Semibold}
              />
            </div>
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </Col>
      </Row>
      <Row>
        <Col col=Col.Twelve>
          <div className={Styles.divider(theme)} />
        </Col>
      </Row>
      <Row alignItems=Row.Center>
        <Col col=Col.Twelve>
          <Row alignItems=Row.Center>
            <Col col=Col.Twelve>
              {switch connectionSub {
              | Data({counterpartyChainID, channels}) =>
                channels->Belt.Array.length > 0
                  ? <>
                      <Row alignItems=Row.Center marginBottom=8>
                        <Col col=Col.One>
                          <Text value="No." color=theme.neutral_600 />
                        </Col>
                        <Col col=Col.Four>
                          <Text value="Port & Channel" color=theme.neutral_600 align={Center} />
                        </Col>
                        <Col col=Col.One offset=Col.One>
                          <Text value="Transactions" color=theme.neutral_600 align={Center} />
                        </Col>
                        <Col col=Col.Two>
                          <Text value="Last Update" color=theme.neutral_600 align={Center} />
                        </Col>
                        <Col col=Col.Two>
                          <Text value="Order" color=theme.neutral_600 align={Center} />
                        </Col>
                        <Col col=Col.One>
                          <Text value="State" color=theme.neutral_600 align={Center} />
                        </Col>
                      </Row>
                      <div className={Styles.channelWrapper}>
                        {channels
                        ->Belt.Array.mapWithIndex((i, channel) =>
                          <ChannelItem
                            chain=counterpartyChainID
                            channel={channel}
                            index={i}
                            key={i->Belt.Int.toString}
                          />
                        )
                        ->React.array}
                      </div>
                    </>
                  : React.null
              | _ => <LoadingCensorBar width=80 height=15 />
              }}
            </Col>
          </Row>
        </Col>
      </Row>
    </div>
  }
}

module ChannelItemMobile = {
  @react.component
  let make = (~chain, ~channel: ConnectionSub.external_channel_t, ~index: int, ()) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <Link
      className="channel-link"
      route={Route.ChannelDetailsPage(chain, channel.port, channel.channelID)}>
      <Row alignItems=Row.Center>
        <Col colSm=Col.Five>
          {
            let port = Ellipsis.format(~text=channel.port, ~limit=25, ())
            <Text
              value={port}
              nowrap=true
              ellipsis=true
              block=true
              color={theme.neutral_900}
              size=Text.Xl
            />
          }
          <VSpacing size=Spacing.xs />
          <Text
            size=Text.Xxl value={channel.channelID} color={theme.primary_600} weight={Text.Semibold}
          />
        </Col>
        <Col colSm=Col.Two>
          <div className={CssHelper.flexBox(~justify=#center, ())}>
            <img
              alt="arrow"
              src={isDarkMode ? Images.connectionArrowSmallLight : Images.connectionArrowSmallDark}
              className="img-fluid"
            />
          </div>
        </Col>
        <Col colSm=Col.Five>
          {
            let port = Ellipsis.format(~text=channel.counterpartyPort, ~limit=25, ())
            <Text
              value={port}
              nowrap=true
              ellipsis=true
              block=true
              color={theme.neutral_900}
              size=Text.Xl
            />
          }
          <VSpacing size=Spacing.xs />
          <Text
            value={channel.counterpartyChannelID}
            color={theme.primary_600}
            weight={Text.Semibold}
            size=Text.Xxl
          />
        </Col>
      </Row>
      <Row marginTopSm=10>
        <Col colSm=Col.Six mbSm=10>
          <Text value="Transactions" color=theme.neutral_600 size={Body1} />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          <Text
            size={Body1}
            value={channel.totalPacketsCount->Format.iPretty}
            color={theme.neutral_900}
            code=true
          />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          <Text size={Body1} value="Last Update" color=theme.neutral_600 />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          {channel.lastUpdate->MomentRe.Moment.year == 1970
            ? <Text
                value={"N/A"} code=true color={theme.neutral_900} weight={Bold} size=Text.Xxxl
              />
            : <TimeAgos
                time={channel.lastUpdate} size=Text.Body1 color={theme.neutral_900} code=true
              />}
        </Col>
        <Col colSm=Col.Six mbSm=10>
          <Text size={Body1} value="Order" color=theme.neutral_600 />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          <Text size={Body1} value={channel.order} color={theme.neutral_900} code=true />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          <Text size={Body1} value="State" color=theme.neutral_600 />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          {switch channel.state {
          | Open => <img alt="Success Icon" src=Images.success width="16" height="16" />
          | _ => <img alt="Fail Icon" src=Images.fail width="16" height="16" />
          }}
        </Col>
      </Row>
    </Link>
  }
}
module ConnectionListMobile = {
  @react.component
  let make = (~connectionSub: Sub.variant<ConnectionSub.t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.listContainer(theme, isDarkMode)}>
      <Row alignItems=Row.Center>
        <Col colSm=Col.Six mbSm=10>
          <Text value="Connection ID:" size=Text.Body1 />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          {switch connectionSub {
          | Data({connectionID}) =>
            <Text
              size=Text.Body1
              value=connectionID
              color={theme.neutral_900}
              code=true
              weight={Semibold}
            />
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </Col>
      </Row>
      <Row alignItems=Row.Center>
        <Col colSm=Col.Six mbSm=10>
          <Text size=Text.Body1 value="Client ID:" />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          {switch connectionSub {
          | Data({clientID}) =>
            <Text
              size=Text.Body1 value=clientID color={theme.neutral_900} code=true weight={Semibold}
            />
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </Col>
      </Row>
      <Row alignItems=Row.Center>
        <Col colSm=Col.Six mbSm=10>
          <Text size=Text.Body1 value="Counterparty Client ID:" />
        </Col>
        <Col colSm=Col.Six mbSm=10>
          {switch connectionSub {
          | Data({counterpartyClientID}) =>
            <Text
              size=Text.Body1
              value=counterpartyClientID
              color={theme.neutral_900}
              code=true
              weight={Semibold}
            />
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </Col>
      </Row>
      <Row>
        <Col col=Col.Twelve>
          <div className={Styles.divider(theme)} />
        </Col>
      </Row>
      <Row alignItems=Row.Center>
        <Col col=Col.Twelve>
          <Row alignItems=Row.Center>
            <Col col=Col.Twelve>
              {switch connectionSub {
              | Data({counterpartyChainID, channels}) =>
                channels->Belt.Array.length > 0
                  ? <>
                      <div className={Styles.channelWrapper}>
                        {channels
                        ->Belt.Array.mapWithIndex((i, channel) => <>
                          <ChannelItemMobile
                            chain=counterpartyChainID
                            channel={channel}
                            index={i}
                            key={i->Belt.Int.toString}
                          />
                          {i === channels->Belt.Array.length - 1
                            ? React.null
                            : <div className={Styles.divider(theme)} />}
                        </>)
                        ->React.array}
                      </div>
                    </>
                  : React.null
              | _ => <LoadingCensorBar width=80 height=15 />
              }}
            </Col>
          </Row>
        </Col>
      </Row>
    </div>
  }
}

@react.component
let make = (~counterpartyChainID, ~state) => {
  let (searchTerm, setSearchTerm) = React.useState(_ => "")
  let isMobile = Media.isMobile()
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 2

  let connectionCountSub = ConnectionSub.getCount(
    ~counterpartyChainID,
    ~connectionID=searchTerm,
    (),
  )

  let conntectionsSub = ConnectionSub.getList(
    ~counterpartyChainID,
    ~connectionID=searchTerm,
    ~pageSize,
    ~page,
    ~state,
    (),
  )
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  React.useEffect1(() => {
    setPage(_ => 1)
    None
  }, [searchTerm, counterpartyChainID])

  <>
    {switch conntectionsSub {
    | Data(connections) if connections->Belt.Array.length === 0 =>
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
      <>
        {connections
        ->Belt.Array.map(connection => {
          connection.channels->Belt.Array.length > 0
            ? isMobile
                ? <ConnectionListMobile
                    key={connection.connectionID} connectionSub={Sub.resolve(connection)}
                  />
                : <ConnectionListDesktop
                    key={connection.connectionID} connectionSub={Sub.resolve(connection)}
                  />
            : React.null
        })
        ->React.array}
        {switch connectionCountSub {
        | Data(connectionCount) =>
          let pageCount = Page.getPageCount(connectionCount, pageSize)
          <Pagination2
            currentPage=page
            pageCount
            onPageChange={newPage => setPage(_ => newPage)}
            onChangeCurrentPage={newPage => setPage(_ => newPage)}
          />
        | _ => React.null
        }}
      </>
    | _ =>
      Belt.Array.makeBy(pageSize, i =>
        isMobile
          ? <ConnectionListMobile key={i->Belt.Int.toString} connectionSub=NoData />
          : <ConnectionListDesktop key={i->Belt.Int.toString} connectionSub=NoData />
      )->React.array
    }}
  </>
}
