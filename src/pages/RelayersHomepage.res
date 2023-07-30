module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let relayerItem = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      border(#px(1), solid, isDarkMode ? theme.neutral_200 : theme.neutral_100),
      boxShadow(
        Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), ~spread=#px(1), rgba(16, 18, 20, #num(0.15))),
      ),
      borderRadius(#px(10)),
      marginBottom(#px(24)),
    ])

  let relayerTitleWrapper = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding(#px(24)),
      Media.mobile([padding(#px(16))]),
      selector(
        "> div:nth-child(1)",
        [width(#percent(50.)), display(#flex), justifyContent(#flexStart), alignItems(#center)],
      ),
      selector(
        "> div:nth-child(2)",
        [width(#percent(25.)), display(#flex), justifyContent(#center), alignItems(#center)],
      ),
      selector(
        "> div:last-child",
        [width(#percent(25.)), display(#flex), justifyContent(#flexEnd), alignItems(#center)],
      ),
    ])

  let relayerTableHead = style(. [padding2(~h=#px(24), ~v=#px(8)), Media.mobile([display(#none)])])
  let chainLogo = style(. [width(#px(24)), height(#px(24)), objectFit(#cover)])
  let relayerDetailsWrapper = (theme: Theme.t, isDarkMode, isOpen) =>
    style(. [
      overflowY(isOpen ? #auto : #hidden),
      transition(~duration=200, "all"),
      maxHeight(isOpen ? #px(4000) : #zero),
      padding2(~v=#px(isOpen ? 24 : 0), ~h=#px(24)),
      Media.mobile([padding2(~v=#px(isOpen ? 2 : 0), ~h=#px(16))]),
    ])

  let toggleButton = {
    style(. [
      display(#flex),
      width(#percent(100.)),
      justifyContent(#flexEnd),
      alignItems(#center),
      cursor(#pointer),
      padding2(~v=#px(10), ~h=#zero),
    ])
  }

  let toggleChannelButton = style(. [display(#inlineBlock)])
}

module RelayerCard = {
  @react.component
  let make = (~relayer: RelayerSub.t) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let (show, setShow) = React.useState(_ => false)

    let {chainID, connections} = relayer

    let toggle = () => setShow(prev => !prev)

    <div className={Styles.relayerItem(theme, isDarkMode)}>
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~justify=#spaceBetween, ~align=#center, ()),
          Styles.relayerTitleWrapper(theme, isDarkMode),
          "chain",
        })}>
        <div>
          <Avatar moniker={chainID} identity={chainID} width=40 />
          <HSpacing size=Spacing.lg />
          <Heading size={H3} value={chainID} weight={Semibold} />
        </div>
        <div>
          <Text
            value={connections
            ->Belt.Array.map(connection => connection.channels->Belt.Array.length)
            ->Belt.Array.reduce(0, (acc, x) => acc + x)
            ->Belt.Int.toString}
            weight={Semibold}
          />
        </div>
        <div>
          <div className=Styles.toggleButton onClick={_ => toggle()}>
            <Text
              value={show ? "Hide Channels" : "Show Channels"}
              color={theme.neutral_600}
              weight={Semibold}
            />
            <HSpacing size=Spacing.sm />
            <Icon name={show ? "fas fa-angle-up" : "fas fa-angle-down"} color={theme.neutral_600} />
          </div>
        </div>
      </div>
      <div className={Styles.relayerDetailsWrapper(theme, isDarkMode, show)}>
        <LiveConnection connections={relayer.connections} />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let (showActive, setShowActive) = React.useState(() => true)

  let (searchTerm, setSearchTerm) = React.useState(_ => "")

  let relayersSub = RelayerSub.getList()

  <Section ptSm=32 pbSm=32>
    <div className=CssHelper.container id="ibcSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          <Heading value="IBC Relayers" size=Heading.H2 marginBottom=16 marginBottomSm=8 />
          <Text
            size=Text.Body1
            value="Acts as a bridge, forwarding transactions and messages between networks and ensuring the proper format and adherence to IBC protocols."
          />
        </Col>
      </Row>
      <Row marginTop=24 marginBottom=24 marginBottomSm={24}>
        <Col col=Col.Twelve>
          <SearchInput
            placeholder="Search by Relayer / connection ID / Channel ID"
            onChange=setSearchTerm
            maxWidth=500
          />
        </Col>
      </Row>
      <Row marginTop=24 marginBottom=24 marginBottomSm={24}>
        <Col col=Col.Twelve>
          <div
            className={CssHelper.flexBox(~justify=#flexStart, ~align=#center, ~direction=#row, ())}>
            <div
              className={Styles.toggleChannelButton}
              onClick={_ => {
                setShowActive(prev => !prev)
              }}>
              <ToggleSwitch isChecked=showActive />
            </div>
            <HSpacing size=Spacing.sm />
            <Text value="Show only open channel" color={theme.neutral_900} />
            <HSpacing size=Spacing.sm />
            <CTooltip
              tooltipPlacementSm=CTooltip.BottomRight
              tooltipText="Show only the active channels that are currently being managed by the IBC relayer">
              <Icon name="fal fa-info-circle" size=12 color={theme.neutral_600} />
            </CTooltip>
          </div>
        </Col>
      </Row>
      <Row>
        <Col col=Col.Twelve>
          {switch relayersSub {
          | Data(relayers) => {
              let filteredRelayers =
                relayers
                ->Belt.Array.keep((relayer: RelayerSub.t) => {
                  let isChainMatch = relayer.chainID->Js.String2.includes(searchTerm)

                  let isConnectionMatch =
                    relayer.connections->Belt.Array.some(connection =>
                      connection.connectionID->Js.String2.includes(searchTerm) &&
                        connection.channels->Belt.Array.length > 0
                    )

                  let isChannelMatch =
                    relayer.connections->Belt.Array.some(connection =>
                      connection.channels->Belt.Array.some(
                        channel => channel.channel->Js.String2.includes(searchTerm),
                      )
                    )

                  isChainMatch || isConnectionMatch || isChannelMatch
                })
                ->Belt.Array.map(relayer => {
                  ...relayer,
                  connections: relayer.connections
                  ->Belt.Array.map(connection => {
                    ...connection,
                    channels: connection.channels->Belt.Array.keep(
                      channel =>
                        (showActive ? channel.state == RelayerSub.Open : true) && (
                          searchTerm->Js.String2.startsWith("channel-")
                            ? channel.channel->Js.String2.includes(searchTerm)
                            : true
                        ),
                    ),
                  })
                  ->Belt.Array.keep(connection =>
                    connection.channels->Belt.Array.length > 0 && (
                        searchTerm->Js.String2.startsWith("connection-")
                          ? connection.connectionID->Js.String2.includes(searchTerm)
                          : true
                      )
                  ),
                })
                ->Belt.Array.keep(relayer => relayer.connections->Belt.Array.length > 0)

              <>
                {filteredRelayers->Belt.Array.length > 0
                  ? <>
                      <div className={Styles.relayerTableHead}>
                        <Row alignItems=Row.Center>
                          <Col col=Col.Six>
                            <Text value="Chain ID" weight={Semibold} />
                          </Col>
                          <Col col=Col.Three>
                            <Text value="Active Channels" weight={Semibold} align={Center} />
                          </Col>
                        </Row>
                      </div>
                      {filteredRelayers
                      ->Belt.Array.mapWithIndex((i, relayer) => {
                        <RelayerCard relayer key={i->Belt.Int.toString} />
                      })
                      ->React.array}
                    </>
                  : <EmptyContainer>
                      <img
                        alt="No Relayer Found"
                        src={isDarkMode ? Images.noDelegatorDark : Images.noDelegatorLight}
                        className=Styles.noDataImage
                      />
                      <Heading
                        size=Heading.H4
                        value="No Relayer Found"
                        align=Heading.Center
                        weight=Heading.Regular
                        color={theme.neutral_600}
                      />
                    </EmptyContainer>}
              </>
            }

          | NoData =>
            <EmptyContainer>
              <img
                alt="No Relayer Found"
                src={isDarkMode ? Images.noDelegatorDark : Images.noDelegatorLight}
                className=Styles.noDataImage
              />
              <Heading
                size=Heading.H4
                value="No Relayer Found"
                align=Heading.Center
                weight=Heading.Regular
                color={theme.neutral_600}
              />
            </EmptyContainer>
          | _ => React.null
          }}
        </Col>
      </Row>
    </div>
  </Section>
}
