module Styles = {
  open CssJs

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
    style(. [padding(#px(24)), Media.mobile([padding(#px(16))])])
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
      justifyContent(#center),
      alignItems(#center),
      cursor(#pointer),
      padding2(~v=#px(10), ~h=#zero),
    ])
  }

  let toggleChannelButton = style(. [display(#inlineBlock)])
}

module RelayerCard = {
  @react.component
  let make = (~chainID: IBCFilterSub.filter_counterparty_t, ~channelState, ()) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let (show, setShow) = React.useState(_ => false)

    let toggle = () => setShow(prev => !prev)

    <div className={Styles.relayerItem(theme, isDarkMode)}>
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~justify=#spaceBetween, ~align=#center, ()),
          Styles.relayerTitleWrapper(theme, isDarkMode),
          "chain",
        })}>
        <div
          className={Css.merge(list{CssHelper.flexBox(~justify=#flexStart, ~align=#center, ())})}>
          <Avatar moniker={chainID.chainID} identity={chainID.chainID} width=40 />
          <HSpacing size=Spacing.lg />
          <Heading size={H3} value={chainID.chainID} weight={Semibold} />
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
        <LiveConnection counterpartyChainID={chainID.chainID} state=channelState />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let (showActive, setShowActive) = React.useState(() => true)

  let (searchTerm, setSearchTerm) = React.useState(_ => "")
  // React.useEffect1(() => {
  //   setPage(_ => 1)
  //   None
  // }, [searchTerm])
  let chainIDFilterSub = IBCFilterSub.getChainFilterList()

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
          <SearchInput placeholder="Search relayer" onChange=setSearchTerm maxWidth=370 />
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
          {switch chainIDFilterSub {
          | Data(chainIDList) =>
            <div>
              {
                let filteredRelayers =
                  searchTerm->Js.String2.length == 0
                    ? chainIDList
                    : chainIDList->Belt.Array.keep(relayer => {
                        relayer.chainID->Js.String2.toLowerCase->Js.String2.includes(searchTerm)
                      })

                filteredRelayers
                ->Belt.Array.mapWithIndex((i, channel) => {
                  <RelayerCard
                    chainID=channel channelState={showActive} key={i->Belt.Int.toString}
                  />
                })
                ->React.array
              }
            </div>

          | _ => <LoadingCensorBar width=285 height=37 radius=8 />
          }}
        </Col>
      </Row>
    </div>
  </Section>
}
