module Styles = {
  open CssJs

  let jsonMode = style(. [display(#flex), alignItems(#center), cursor(#pointer), height(#px(30))])
}

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
