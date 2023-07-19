module Styles = {
  open CssJs

  let buttonStyled = style(. [
    backgroundColor(#transparent),
    border(#zero, #solid, #transparent),
    outlineStyle(#none),
    cursor(#pointer),
    padding2(~v=#zero, ~h=#zero),
    margin4(~top=#zero, ~right=#zero, ~bottom=#px(40), ~left=#zero),
  ])

  let badge = style(. [marginTop(#px(8))])
  let header = style(. [marginBottom(#px(24))])
  let msgContainer = style(. [selector("> div + div", [marginTop(#px(24))])])

  let proposalTypeBadge = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(6), ~h=#px(12)),
      borderRadius(#px(20)),
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.primary_100),
      display(#inlineBlock),
      selector(" > p", [color(theme.primary_600)]),
    ])

  let parameterChanges = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(16), ~h=#px(24)),
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.neutral_100),
    ])
}

module ProposalTypeBadge = {
  @react.component
  let make = (~proposalType) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.proposalTypeBadge(theme, isDarkMode)}>
      <Text
        value={proposalType->ProposalSub.ProposalType.getBadgeText}
        size=Text.Body2
        block=true
        weight={Semibold}
      />
    </div>
  }
}

module RenderData = {
  @react.component
  let make = (~proposal: ProposalSub.t, ~voteStat: VoteSub.vote_stat_t, ~bondedToken: Coin.t) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (accountOpt, _) = React.useContext(AccountContext.context)

    <Section>
      <div className=CssHelper.container>
        <button
          className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
          onClick={_ => Route.redirect(LegacyProposalPage)}>
          <Icon name="fa fa-angle-left" mr=8 size=16 />
          <Text value="Back to all legacy proposals" size=Text.Xl color=theme.neutral_600 />
        </button>
        <Row style=Styles.header>
          <Col col=Col.Twelve>
            <div className={CssHelper.flexBox()}>
              <TypeID.LegacyProposal
                id={proposal.id}
                position=TypeID.Title
                size=Text.Xxxxl
                weight=Text.Bold
                color={theme.neutral_900}
                isNotLink=true
              />
              <HSpacing size=Spacing.sm />
              <Heading
                size=Heading.H1
                value=proposal.title
                color={theme.neutral_900}
                weight=Heading.Semibold
              />
              <HSpacing size=Spacing.sm />
              {isMobile ? React.null : <LegacyProposalBadge status=proposal.status />}
            </div>
            {isMobile
              ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.badge})}>
                  <LegacyProposalBadge status=proposal.status />
                </div>
              : React.null}
          </Col>
        </Row>
        <Row justify=Row.Between>
          <Col col=Col.Six>
            <Row>
              <Col col=Col.Four>
                <Heading
                  value="Submit Time"
                  size=Heading.H4
                  marginBottom=8
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={Some(proposal.submitTime)} color={theme.neutral_900}
                />
              </Col>
              <Col col=Col.Four>
                <Heading
                  value="Voting Starts"
                  size=Heading.H4
                  marginBottom=8
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={proposal.votingStartTime} color={theme.neutral_900}
                />
              </Col>
              <Col col=Col.Four>
                <Heading
                  value="Voting Ends"
                  size=Heading.H4
                  marginBottom=8
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={proposal.votingEndTime} color={theme.neutral_900}
                />
              </Col>
            </Row>
          </Col>
        </Row>
        <SeperatedLine mt=32 mb=24 color=theme.neutral_200 />
        <Row marginBottom=24>
          <Col col=Col.Twelve>
            <VoteDetailsCard.Legacy proposal voteStat bondedToken />
          </Col>
        </Row>
        <Row marginBottom=24>
          <Col col=Col.Twelve>
            <Heading
              value="Proposal Details"
              size=Heading.H4
              weight=Heading.Semibold
              color={theme.neutral_600}
              marginBottom=8
            />
          </Col>
          <Col col=Col.Twelve>
            <InfoContainer>
              <Row marginBottom=24 alignItems=Row.Center>
                <Col col=Col.Four mbSm=8>
                  <Heading
                    value="Proposer" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Eight>
                  {switch proposal.proposerAddressOpt {
                  | Some(proposerAddress) =>
                    <AddressRender address=proposerAddress position=AddressRender.Subtitle />
                  | None => <Text value="Proposed on Wenchang" />
                  }}
                </Col>
              </Row>
              <Row marginBottom=24 alignItems=Row.Center>
                <Col col=Col.Four mbSm=8>
                  <Heading
                    value="Proposal Type"
                    size=Heading.H4
                    weight=Heading.Thin
                    color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Eight>
                  <ProposalTypeBadge proposalType=proposal.proposalType />
                </Col>
              </Row>
              <Row marginBottom=24>
                <Col col=Col.Four mbSm=8>
                  <Heading
                    value="Description"
                    size=Heading.H4
                    weight=Heading.Thin
                    color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Eight>
                  <MarkDown value=proposal.description />
                </Col>
              </Row>
            </InfoContainer>
          </Col>
        </Row>
        <Row marginBottom=16>
          <Col>
            <Heading
              value="Messages" size=Heading.H4 weight=Heading.Semibold color={theme.neutral_600}
            />
          </Col>
        </Row>
        <Row marginBottom=24>
          <Col>
            <InfoContainer>
              {switch proposal.content {
              | CommunityPoolSpend({recipient, amount}) =>
                <>
                  <Row marginBottom=24>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Recipient Address"
                        size=Heading.H4
                        weight=Heading.Thin
                        color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <AddressRender address=recipient position=AddressRender.Subtitle />
                    </Col>
                  </Row>
                  <Row>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Amount" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <AmountRender coins=amount pos=AmountRender.TxIndex />
                    </Col>
                  </Row>
                </>
              | SoftwareUpgrade({name, height}) =>
                <>
                  <Row marginBottom=24>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Upgrade Name"
                        size=Heading.H4
                        weight=Heading.Thin
                        color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <Text value={name} size=Text.Body1 block=true />
                    </Col>
                  </Row>
                  <Row>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Upgrade Height"
                        size=Heading.H4
                        weight=Heading.Thin
                        color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <Text value={height->Belt.Int.toString} size=Text.Body1 block=true />
                    </Col>
                  </Row>
                </>
              | ParameterChange(parameters) =>
                <>
                  <Row marginBottom=24>
                    <Col col=Col.Twelve>
                      <div className={Styles.parameterChanges(theme, isDarkMode)}>
                        {parameters
                        ->Belt.Array.mapWithIndex((i, value) =>
                          <div key={i->Belt.Int.toString}>
                            <Text
                              value={value.subspace ++ "." ++ value.key ++ ": " ++ value.value}
                              size=Text.Body1
                              block=true
                              code=true
                            />
                            {i < parameters->Belt.Array.length - 1
                              ? <VSpacing size=Spacing.md />
                              : React.null}
                          </div>
                        )
                        ->React.array}
                      </div>
                    </Col>
                  </Row>
                </>
              | _ => <Text value="Unable to show the proposal messages" />
              }}
            </InfoContainer>
          </Col>
        </Row>
        <LegacyVoteBreakdownTable members=[] proposalID=proposal.id />
      </div>
    </Section>
  }
}

@react.component
let make = (~proposalID) => {
  let proposalSub = ProposalSub.get(proposalID)
  let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(proposalID)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  let allSub = Sub.all3(proposalSub, voteStatByProposalIDSub, bondedTokenCountSub)

  switch allSub {
  | Data(proposal, voteStat, bondedToken) => <RenderData proposal voteStat bondedToken />
  | Error(err) => <Heading value={err.message} />
  | Loading => <Heading value="Loading" />
  | NoData => <Heading value="NoData" />
  }
}
