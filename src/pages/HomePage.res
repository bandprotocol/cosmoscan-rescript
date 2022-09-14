@react.component
let make = () => {

  let votes = VoteSub.get(ID.Proposal.fromInt(4))
  let test2 = TestSub.log()

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          {
            switch votes {
              | Data(vote) => <Text value={vote -> Belt.Float.toString} size=Text.Lg />
              | Loading => <Text value="Loading" size=Text.Lg />
              | NoData => <Text value="NoData" size=Text.Lg />
              | Error(err) => <Text value=err.message size=Text.Lg />
            }
          }
        </Col>
      </Row>
    </div>
  </Section>;
}
