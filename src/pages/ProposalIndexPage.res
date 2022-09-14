module Styles = {
  open CssJs;

  let statusLogo = style(. [width(#px(20))]);
  let resultContainer = style(. [selector("> div + div", [marginTop(#px(24))])]);

  let voteButton = x =>
    switch(x){
      | ProposalSub.Voting => style(. [visibility(#visible)])
      | Deposit
      | Passed
      | Rejected
      | Failed => style(. [visibility(#hidden)]);
    }

  let chartContainer = style(. [paddingRight(#px(20)), Media.mobile([paddingRight(#zero)])]);

  let parameterChanges = (theme: Theme.t) =>
    style(. [padding2(~v=#px(16), ~h=#px(24)), backgroundColor(theme.secondaryTableBg)]);
};

@react.component
let make = (~proposalID) => {
  let proposalSub = ProposalSub.get(proposalID);
  // let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(proposalID);
  // let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount();

  // let allSub = Sub.all3(proposalSub, voteStatByProposalIDSub, bondedTokenCountSub);

  <Section>
    <div className=CssHelper.container>
      <Row>
        <Col>
          <Heading value="Proposal Details" size=Heading.H2 marginBottom=40 marginBottomSm=24 />
        </Col>
      </Row>
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=16>
        {switch (proposalSub) {
         | Data({id, name, status}) =>
            <>
              <Col col=Col.Eight mbSm=16>
                <div
                  className={Css.merge(list{
                    CssHelper.flexBox(),
                    CssHelper.flexBoxSm(~direction=#column, ~align=#flexStart, ()),
                    })}>
                  <div className={CssHelper.flexBox()}>
                    <TypeID.Proposal id position=TypeID.Title />
                    <HSpacing size=Spacing.sm />
                    <Heading size=Heading.H3 value=name />
                    <HSpacing size={#px(16)} />
                  </div>
                  <div className={CssHelper.mtSm(~size=16, ())}> <ProposalBadge status /> </div>
                </div>
              </Col>
              
            </>
         | _ =>
            <Col col=Col.Eight mbSm=16>
              <div className={CssHelper.flexBox()}>
                <LoadingCensorBar width=270 height=15 />
                <HSpacing size={#px(16)} />
                <div className={CssHelper.mtSm(~size=16, ())}>
                  <LoadingCensorBar width=100 height=15 radius=50 />
                </div>
              </div>
            </Col>
         }}
      </Row>
    </div>
  </Section>
}
