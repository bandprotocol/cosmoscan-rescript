@react.component
let make = () => {
  let (text, setText) = React.useState(_ => "");
  let sub = ProposalSub.get(ID.Proposal.ID(6))
  let multi = ProposalSub.getList(~page=1, ~pageSize=10,())
  let count = ProposalSub.count()

  React.useEffect0(() => {
    // Run effects
    
    setText(_ => Js.Json.stringifyAny("Hello") -> Belt.Option.getExn)

    None // or Some(() => {})
  })

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          {
            switch multi {
              | Data(proposals) => <Text value={proposals -> Belt.Array.length -> Belt.Int.toString} size=Text.Lg />
              | Loading => <Text value="Loading" size=Text.Lg />
              | NoData => <Text value="NoData" size=Text.Lg />
              | Error(err) => <Text value=err.message size=Text.Lg />
            }
          }
        </Col>
        <Col col=Col.Twelve>
          {
            switch multi {
              | Data(proposals) => <Text value={proposals[5].id -> ID.Proposal.toString} size=Text.Lg />
              | Loading => <Text value="Loading" size=Text.Lg />
              | NoData => <Text value="NoData" size=Text.Lg />
              | Error(err) => <Text value=err.message size=Text.Lg />
            }
          }
        </Col>
        <Col col=Col.Twelve>
          {
            switch count {
              | Data(data) => <Text value={data -> Belt.Int.toString} size=Text.Lg />
              | _ => <Text value=text size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine />
        <Col col=Col.Twelve>
          {
            switch sub {
              | Data({description}) => <MarkDown value=description />
              | _ => <Text value=text size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine />
        <Col col=Col.Twelve>
          {
            switch sub {
              | Data({proposalType}) => <Text value=proposalType size=Text.Lg />
              | _ => <Text value=text size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine /> 
        <Col col=Col.Twelve>
          {
            switch sub {
              | Data({submitTime}) => <Text value={submitTime |> MomentRe.Moment.format("YYYY-MM-DD HH:mm:ss")} size=Text.Lg />
              | _ => <Text value=text size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine /> 
        <Col col=Col.Twelve>
          {
            switch sub {
              | Data({depositEndTime}) => <Text value={depositEndTime |> MomentRe.Moment.format("YYYY-MM-DD HH:mm:ss")} size=Text.Lg />
              | _ => <Text value=text size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine /> 
        <Col col=Col.Twelve>
          {
            switch sub {
              | Data({votingStartTime}) => <Text value={votingStartTime |> MomentRe.Moment.format("YYYY-MM-DD HH:mm:ss")} size=Text.Lg />
              | _ => <Text value=text size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine /> 
        <Col col=Col.Twelve>
          {
            switch sub {
              | Data({votingEndTime}) => <Text value={votingEndTime |> MomentRe.Moment.format("YYYY-MM-DD HH:mm:ss")} size=Text.Lg />
              | _ => <Text value=text size=Text.Lg />
            }
          }
        </Col>
      </Row>
    </div>
  </Section>;
}
