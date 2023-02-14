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

  let (page, setPage) = React.useState(_ => 1)

  let packetsSub = IBCQuery.getList(
    ~page,
    ~pageSize=10,
    ~direction=Incoming,
    ~packetType="Oracle Request",
    ~port="",
    ~channel="",
    ~sequence=None,
    ~chainID="",
    (),
  )

  <div>
    <Row>
      <Col col=Col.Twelve>
        <Heading value="Incoming" size=Heading.H3 marginBottom=8 />
        <Text
          size=Text.Lg
          weight=Text.Thin
          color=theme.textSecondary
          value="Receiving transaction information from counterparty chain to BandChain"
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
            {"Oracle Request"->React.string}
          </ChipButton>
          <ChipButton variant={ChipButton.Outline} onClick={_ => Js.log("click")}>
            {"Fungible Token"->React.string}
          </ChipButton>
        </div>
      </Col>
    </Row>
    {isMobile ? React.null : <PacketTableHead />}
    // <Row>
    //   <Col col=Col.Twelve>
    //     // <div className=Styles.txListContainer> {isMobile ? React.nulQl : <PacketItem />} </div>
    //     {switch packetsQuery {
    //     | Data(packets) =>
    //       packets->Belt.Array.map(packet =>
    //         <div className=Styles.txListContainer>
    //           <PacketItem packet />
    //         </div>
    //       )
    //     | _ => <LoadingCensorBar width=200 height=15 />
    //     }}
    //   </Col>
    // </Row>
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
          <Col col=Col.Twelve key={i->Belt.Int.toString} mb=24>
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
        Belt_Array.make(10, Sub.NoData)
        ->Belt_Array.mapWithIndex((i, noData) =>
          <Col col=Col.Twelve key={i->Belt.Int.toString} mb=24>
            <PacketItem packetSub=noData />
          </Col>
        )
        ->React.array
      }}
    </Row>
  </div>
}
