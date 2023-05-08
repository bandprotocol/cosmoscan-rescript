module ProofHeight = {
  @react.component
  let make = (~proofHeight: MsgDecoder.Height.t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <>
      <SeperatedLine mt=24 mb=24 />
      <Row>
        <Col mb=24>
          <Heading value="Proof Height" size=Heading.H4 color=theme.neutral_600 />
        </Col>
        <Col col=Col.Six mbSm=24>
          <Heading
            value="Revision Height"
            size=Heading.H4
            marginBottom=8
            weight=Heading.Regular
            color=theme.neutral_600
          />
          <Text size=Text.Body1 value={proofHeight.revisionHeight->Belt.Int.toString} />
        </Col>
        <Col col=Col.Six>
          <Heading
            value="Revision Number"
            size=Heading.H4
            marginBottom=8
            weight=Heading.Regular
            color=theme.neutral_600
          />
          <Text size=Text.Body1 value={proofHeight.revisionNumber->Belt.Int.toString} />
        </Col>
      </Row>
    </>
  }
}

module ConsensusHeight = {
  @react.component
  let make = (~proofHeight: MsgDecoder.Height.t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <>
      <SeperatedLine mt=24 mb=24 />
      <Row>
        <Col mb=24>
          <Heading value="Consensus Height" size=Heading.H4 color=theme.neutral_600 />
        </Col>
        <Col col=Col.Six mbSm=24>
          <Heading
            value="Revision Height"
            size=Heading.H4
            marginBottom=8
            weight=Heading.Regular
            color=theme.neutral_600
          />
          <Text size=Text.Body1 value={proofHeight.revisionHeight->Belt.Int.toString} />
        </Col>
        <Col col=Col.Six>
          <Heading
            value="Revision Number"
            size=Heading.H4
            marginBottom=8
            weight=Heading.Regular
            color=theme.neutral_600
          />
          <Text size=Text.Body1 value={proofHeight.revisionNumber->Belt.Int.toString} />
        </Col>
      </Row>
    </>
  }
}