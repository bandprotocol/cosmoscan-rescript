module Styles = {
  open CssJs

  let topicContainer = style(. [
    display(#flex),
    justifyContent(#spaceBetween),
    width(#percent(100.)),
    lineHeight(#px(16)),
    alignItems(#center),
  ])

  let failIcon = style(. [width(#px(16)), height(#px(16))])
  let msgContainer = style(. [selector("> div + div", [marginTop(#px(24))])])
  let jsonMode = style(. [display(#flex), alignItems(#center), cursor(#pointer), height(#px(30))])
}

let renderUnknownMessage = () =>
  <Col col=Col.Six>
    <div className=Styles.topicContainer>
      <Text value="Unknown Message" size=Text.Caption transform=Text.Uppercase />
      <img src=Images.fail alt="Unknown Message" className=Styles.failIcon />
    </div>
  </Col>

module MsgDetailCard = {
  @react.component
  let make = (~msg: Msg.result_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let badge = msg.decoded->Msg.getBadge
    let (showJson, setShowJson) = React.useState(_ => false)
    let toggle = () => setShowJson(prev => !prev)

    <InfoContainer>
      <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
        <div className={CssHelper.flexBox()}>
          <IndexMsgIcon category=badge.category />
          <HSpacing size=Spacing.sm />
          <Heading value=badge.name size=Heading.H4 />
        </div>
        <div className=Styles.jsonMode onClick={_ => toggle()}>
          <Text value="JSON Mode" weight=Text.Semibold color=theme.neutral_900 />
          <Switch checked=showJson />
        </div>
      </div>
      {showJson
        ? <div className={CssHelper.mt(~size=32, ())}>
            <JsonViewer src=msg.raw />
          </div>
        : <>
            <SeperatedLine mt=32 mb=24 />
            <RenderMsgDetails contents={msg.decoded->RenderMsgDetails.getContent} />
          </>}
    </InfoContainer>
  }
}

@react.component
let make = (~messages: list<Msg.result_t>) =>
  <div className=Styles.msgContainer>
    {messages
    ->Belt.List.mapWithIndex((index, msg) => {
      let badge = msg.decoded->Msg.getBadge
      <MsgDetailCard key={index->Belt.Int.toString ++ badge.name} msg />
    })
    ->Array.of_list
    ->React.array}
  </div>

module Loading = {
  @react.component
  let make = () =>
    <InfoContainer>
      <div className={CssHelper.flexBox()}>
        <LoadingCensorBar width=24 height=24 radius=24 />
        <HSpacing size=Spacing.sm />
        <LoadingCensorBar width=75 height=15 />
        <SeperatedLine mt=32 mb=24 />
      </div>
      <Row>
        <Col col=Col.Six mb=24>
          <LoadingCensorBar width=75 height=15 mb=8 />
          <LoadingCensorBar width=150 height=15 />
        </Col>
        <Col col=Col.Six mb=24>
          <LoadingCensorBar width=75 height=15 mb=8 />
          <LoadingCensorBar width=150 height=15 />
        </Col>
        <Col col=Col.Six>
          <LoadingCensorBar width=75 height=15 mb=8 />
          <LoadingCensorBar width=150 height=15 />
        </Col>
      </Row>
    </InfoContainer>
}
