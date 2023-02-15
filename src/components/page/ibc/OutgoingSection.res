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
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()
  let isTablet = Media.isTablet()

  let (page, setPage) = React.useState(_ => 1)

  let packetCountSub = IBCSub.outgoingCount()
  let pageSize = 5

  let packetsSub = IBCQuery.getList(
    ~page,
    ~pageSize,
    ~direction=Outgoing,
    ~packetType="",
    ~port="",
    ~channel="",
    ~sequence=None,
    ~chainID="",
    (),
  )

  <div>
    <Row>
      <Col col=Col.Twelve>
        <Heading value="Outgoing" size=Heading.H3 marginBottom=8 />
        <Text
          size=Text.Lg
          weight=Text.Thin
          color=theme.textSecondary
          value="Sending transaction information from BandChain to counterparty chain"
        />
      </Col>
    </Row>
    <Row>
      <Col col=Col.Twelve>
        <div className={Styles.filterButtonsContainer}>
          <ChipButton
            variant={ChipButton.Outline} onClick={_ => Js.log("click")} className="selected">
            {"All"->React.string}
          </ChipButton>
          <ChipButton variant={ChipButton.Outline} onClick={_ => Js.log("click")}>
            {"Oracle Response"->React.string}
          </ChipButton>
          <ChipButton variant={ChipButton.Outline} onClick={_ => Js.log("click")}>
            {"Fungible Token"->React.string}
          </ChipButton>
        </div>
      </Col>
    </Row>
    {isTablet ? React.null : <OutgoingPacketTableHead />}
    <Row marginTop=8>
      {switch packetsSub {
      | Data(packets) if packets->Belt.Array.length === 0 =>
        <EmptyContainer backgroundColor={theme.mainBg}>
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
            color={theme.textSecondary}
          />
        </EmptyContainer>
      | Data(packets) =>
        packets
        ->Belt_Array.mapWithIndex((i, e) =>
          <Col col=Col.Twelve key={i->Belt.Int.toString} mb=16>
            <PacketItem packetSub={Sub.resolve(e)} />
          </Col>
        )
        ->React.array
      | Error(_) =>
        <EmptyContainer backgroundColor={theme.mainBg}>
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
            color={theme.textSecondary}
          />
        </EmptyContainer>
      | _ =>
        Belt_Array.make(pageSize, Sub.NoData)
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
