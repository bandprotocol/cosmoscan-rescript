module Styles = {
  open CssJs

  let card = (theme: Theme.t) => style(. [backgroundColor(theme.neutral_000)])
}

@react.component
let make = (~port, ~channel) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Section ptSm=32 pbSm=32>
    <div className=CssHelper.container id="section_relayer_details">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          <div className={Styles.card(theme)}>
            <Heading value="Channel" size=Heading.H2 marginBottom=16 marginBottomSm=8 />
          </div>
        </Col>
      </Row>
    </div>
    <div className=CssHelper.container id="section_incoming_packets">
      <IncomingSection chainID="consumer" channel port />
    </div>
    <div className=CssHelper.container id="section_outgoing_packets">
      <OutgoingSection chainID="consumer" channel port />
    </div>
  </Section>
}
