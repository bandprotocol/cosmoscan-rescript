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
    marginBottom(#px(16)),
  ])
  let txListContainer = style(. [marginTop(#px(16)), width(#percent(100.))])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let paperStyle = (theme: Theme.t, isDarkMode) =>
    style(. [
      width(#percent(100.)),
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.white),
      borderRadius(#px(10)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      padding(#px(16)),
      border(#px(1), #solid, theme.neutral_100),
    ])
}

@react.component
let make = (~chainID, ~channel, ~port) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()
  let isTablet = Media.isTablet()

  let (page, setPage) = React.useState(_ => 1)
  let (packetType, setPacketType) = React.useState(_ => "All")

  let packetCountSub = IBCSub.incomingCount(~port, ~channel, ~packetType, ())
  let pageSize = 5

  let packetsSub = IBCQuery.getList(
    ~page,
    ~pageSize,
    ~direction=Incoming,
    ~packetType={
      switch packetType {
      | "All" => ""
      | _ => packetType
      }
    },
    ~port,
    ~channel,
    ~chainID,
    (),
  )

  <div>
    <Row>
      <Col col=Col.Twelve>
        <Heading value="Incoming" size=Heading.H3 marginBottom=8 />
        <Text
          size=Text.Body1
          weight=Text.Thin
          color=theme.neutral_600
          value="Receiving transaction information from counterparty chain to BandChain"
        />
      </Col>
    </Row>
    <Row>
      <Col col=Col.Twelve>
        <div className={Styles.filterButtonsContainer}>
          {["All", "Oracle Request", "Fungible Token"]
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
    {isTablet ? React.null : <IncomingPacketTableHead />}
    <Row>
      {switch packetsSub {
      | Data(packets) if packets->Belt.Array.length > 0 =>
        packets
        ->Belt_Array.mapWithIndex((i, e) =>
          <Col col=Col.Twelve key={i->Belt.Int.toString} mb=16 mbSm=16>
            <PacketItem packetSub={Sub.resolve(e)} />
          </Col>
        )
        ->React.array

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
      | _ => React.null
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
