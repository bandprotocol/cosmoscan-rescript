@react.component
let make = () => {

  let votes = VoteSub.getVoteStatByProposalID(ID.Proposal.fromInt(4))
  let bondAmount = ValidatorSub.getTotalBondedAmount();

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          {
            switch votes {
              | Data(vote) => <Text value={vote.totalYes -> Belt.Float.toString} size=Text.Lg />
              | Loading => <Text value="Loading" size=Text.Lg />
              | NoData => <Text value="NoData" size=Text.Lg />
              | Error(err) => <Text value=err.message size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine/>
        <Col col=Col.Twelve>
          {
            switch votes {
              | Data(vote) => <Text value={vote.totalNo -> Belt.Float.toString} size=Text.Lg />
              | Loading => <Text value="Loading" size=Text.Lg />
              | NoData => <Text value="NoData" size=Text.Lg />
              | Error(err) => <Text value=err.message size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine/>
        <Col col=Col.Twelve>
          {
            switch bondAmount {
              | Data(vote) => <Text value={vote -> Coin.getBandAmountFromCoin -> Belt.Float.toString} size=Text.Lg />
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
