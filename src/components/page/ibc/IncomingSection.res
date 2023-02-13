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
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  let packetsQuery = IBCQuery.getList(
    ~pageSize=100,
    ~direction=Incoming,
    ~packetType="Oracle Request",
    ~port="",
    ~channel="",
    ~sequence=None,
    ~chainID="",
    (),
  )
  Js.log(packetsQuery)

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
    {isMobile ? React.null : <TxHeadDesktop />}
    <Row>
      <Col col=Col.Twelve>
        <div className=Styles.txListContainer> {isMobile ? React.null : <TxListDesktop />} </div>
      </Col>
    </Row>
  </div>
}
