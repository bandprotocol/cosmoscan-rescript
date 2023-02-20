module Styles = {
  open CssJs

  let filterButtonsContainer = style(. [
    display(#flex),
    flexDirection(#row),
    alignItems(#center),
    justifyContent(#flexStart),
    width(#percent(100.)),
    marginTop(#px(16)),
    selector(
      "> button",
      [marginRight(#px(8)), selector(":last-child", [marginRight(#px(0))]), borderRadius(#px(100))],
    ),
  ])
  let txListContainer = style(. [marginTop(#px(16)), width(#percent(100.))])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let paperStyle = (theme: Theme.t, isDarkMode) =>
    style(. [
      width(#percent(100.)),
      backgroundColor(isDarkMode ? theme.white : theme.white),
      borderRadius(#px(10)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      padding(#px(16)),
      border(#px(1), #solid, isDarkMode ? hex("F3F4F6") : hex("F3F4F6")), // TODO: will change to theme color
    ])
}

@react.component
let make = (~chainID, ~channel, ~port, ~sequence) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()
  let isTablet = Media.isTablet()

  let (page, setPage) = React.useState(_ => 1)
  let (packetType, setPacketType) = React.useState(_ => "All")

  let packetCountSub = IBCSub.outgoingCount()
  let pageSize = 5

  let packetsSub = IBCQuery.getList(
    ~page,
    ~pageSize,
    ~direction=Outgoing,
    ~packetType={
      switch packetType {
      | "All" => ""
      | _ => packetType
      }
    },
    ~port,
    ~channel,
    ~sequence,
    ~chainID,
    (),
  )

  <div>
    <Row>
      <Col col=Col.Twelve>
        <Heading value="Outgoing" size=Heading.H3 marginBottom=8 />
        <Text
          size=Text.Body2
          weight=Text.Thin
          color=theme.neutral_600
          value="Sending transaction information from BandChain to counterparty chain"
        />
      </Col>
    </Row>
    <Row>
      <Col col=Col.Twelve>
        <div className={Styles.filterButtonsContainer}>
          {["All", "Oracle Response", "Fungible Token"]
          ->Belt.Array.mapWithIndex((i, pt) =>
            <ChipButton
              key={i->Belt.Int.toString}
              variant={ChipButton.Outline}
              onClick={_ => setPacketType(_ => pt)}
              isActive={pt === packetType}>
              {pt->React.string}
            </ChipButton>
          )
          ->React.array}
        </div>
      </Col>
    </Row>
    {isTablet ? React.null : <OutgoingPacketTableHead />}
    <Row marginTop=8>
      {switch packetsSub {
      | Data(packets) if packets->Belt.Array.length === 0 =>
        <div className={Styles.paperStyle(theme, isDarkMode)}>
          <EmptyContainer>
            <img
              alt="No Packets"
              src={isDarkMode ? Images.noOracleDark : Images.noOracleLight}
              className=Styles.noDataImage
            />
            <Heading
              size=Heading.H4
              value="No Packets"
              align=Heading.Center
              weight=Heading.Regular
              color={theme.neutral_600}
            />
          </EmptyContainer>
        </div>
      | Data(packets) =>
        packets
        ->Belt_Array.mapWithIndex((i, e) =>
          <Col col=Col.Twelve key={i->Belt.Int.toString} mb=16>
            <PacketItem packetSub={Query.resolve(e)} />
          </Col>
        )
        ->React.array
      | Error(_) =>
        <div className={Styles.paperStyle(theme, isDarkMode)}>
          <EmptyContainer>
            <img
              alt="No Packets"
              src={isDarkMode ? Images.noOracleDark : Images.noOracleLight}
              className=Styles.noDataImage
            />
            <Heading
              size=Heading.H4
              value="No Packets"
              align=Heading.Center
              weight=Heading.Regular
              color={theme.neutral_600}
            />
          </EmptyContainer>
        </div>
      | _ =>
        Belt_Array.make(pageSize, Query.NoData)
        ->Belt_Array.mapWithIndex((i, noData) =>
          <Col col=Col.Twelve key={i->Belt.Int.toString} mb=24>
            <PacketItem packetSub=noData />
          </Col>
        )
        ->React.array
      }}
    </Row>
    {switch packetCountSub {
    | Data(packetCount) =>
      let pageCount = Page.getPageCount(packetCount, pageSize)
      <Pagination2
        currentPage=page
        pageCount
        onPageChange={newPage => setPage(_ => newPage)}
        onChangeCurrentPage={newPage => setPage(_ => newPage)}
      />
    | _ => React.null
    }}
  </div>
}
