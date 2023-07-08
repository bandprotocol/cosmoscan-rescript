module Styles = {
  open CssJs

  let statusLogo = style(. [width(#px(20))])
  let resultContainer = style(. [selector("> div + div", [marginTop(#px(24))])])

  let voteButton = status =>
    switch status {
    | ProposalSub.Voting => style(. [visibility(#visible)])
    | Deposit
    | Passed
    | Rejected
    | Inactive
    | Failed =>
      style(. [visibility(#hidden)])
    }

  let chartContainer = style(. [paddingRight(#px(20)), Media.mobile([paddingRight(#zero)])])

  let parameterChanges = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(16), ~h=#px(24)),
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.neutral_100),
    ])

  let proposalTypeBadge = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(6), ~h=#px(12)),
      borderRadius(#px(20)),
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.primary_100),
      display(#inlineBlock),
      selector(" > p", [color(theme.primary_600)]),
    ])

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
  let yesnoImg = style(. [width(#px(16)), height(#px(16)), marginRight(#px(4))])
  let councilMember = (theme: Theme.t) => style(. [color(theme.primary_600)])

  let smallDot = color =>
    style(. [
      width(#px(8)),
      height(#px(8)),
      borderRadius(#percent(50.)),
      backgroundColor(color),
      marginRight(#px(8)),
    ])
}

let formatVotePercent = value => (value < 10. ? "0" : "") ++ value->Format.fPretty(~digits=2) ++ "%"

module VoteButton = {
  @react.component
  let make = (~proposalID, ~address) => {
    let vote = () => Webapi.Dom.window->Webapi.Dom.Window.alert("vote")
    let accountQuery = AccountQuery.get(address)

    switch accountQuery {
    | Data({councilOpt}) =>
      switch councilOpt {
      | Some(council) =>
        <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => vote()}>
          {"Vote"->React.string}
        </Button>
      | None => React.null
      }
    | _ => React.null
    }
  }
}

module RenderData = {
  @react.component
  let make = (~proposal: CouncilProposalSub.t) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (accountOpt, _) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

    <Section>
      <div className=CssHelper.container>
        <button
          className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
          onClick={_ => Route.redirect(ProposalPage)}>
          <Icon name="fa fa-angle-left" mr=8 size=16 />
          <Text value="Back to all proposals" size=Text.Xl color=theme.neutral_600 />
        </button>
        <Row style=Styles.header>
          <Col col=Col.Twelve>
            <div className={CssHelper.flexBox()}>
              <TypeID.Proposal
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
              {isMobile ? React.null : <CouncilProposalBadge status=proposal.status />}
            </div>
            {isMobile
              ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.badge})}>
                  <CouncilProposalBadge status=proposal.status />
                </div>
              : React.null}
          </Col>
        </Row>
        <Row justify=Row.Between>
          <Col col=Col.Four>
            <Row>
              <Col col=Col.Six>
                <Heading
                  value="Submit & Voting Starts"
                  size=Heading.H5
                  marginBottom=8
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={Some(proposal.submitTime)} color={theme.neutral_900}
                />
              </Col>
              <Col col=Col.Six>
                <Heading
                  value="Voting Ends"
                  size=Heading.H5
                  marginBottom=8
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={Some(proposal.votingEndTime)} color={theme.neutral_900}
                />
              </Col>
            </Row>
          </Col>
          {switch accountOpt {
          | Some({address}) =>
            <Col col=Col.Two>
              <VoteButton proposalID=proposal.id address />
            </Col>
          | None => React.null
          }}
        </Row>
        <SeperatedLine mt=32 mb=24 color=theme.neutral_200 />
        <Row>
          <Col>
            <Heading
              value="Vote Details"
              size=Heading.H4
              weight=Heading.Semibold
              color={theme.neutral_600}
              marginBottom=8
            />
          </Col>
        </Row>
        <Row marginBottom=24>
          <Col>
            <InfoContainer>
              <Row>
                <Col col=Col.Four>
                  <Row>
                    <Col col=Col.Six>
                      <div className={CssHelper.flexBox()}>
                        <Heading
                          value="Yes Vote"
                          size=Heading.H5
                          weight=Heading.Regular
                          color={theme.neutral_900}
                          marginRight=8
                        />
                        <Text
                          // minimum yes vote to pass set in CouncilProposalSub.passedTheshold
                          value={`min ${CouncilProposalSub.passedTheshold->Belt.Float.toString}%`}
                          size=Text.Body2
                          weight=Text.Regular
                          color={theme.neutral_600}
                        />
                      </div>
                    </Col>
                    <Col col=Col.Six>
                      <div className={CssHelper.flexBox()}>
                        <img
                          src={switch proposal.councilVoteStatus {
                          | Pass => Images.yesGreen
                          | Reject => Images.noRed
                          }}
                          alt={proposal.councilVoteStatus->CouncilProposalSub.CurrentStatus.getStatusText}
                          className=Styles.yesnoImg
                        />
                        <Text
                          value={proposal.yesVotePercent->Format.fPercent(~digits=2)}
                          size=Text.Body1
                          weight=Text.Bold
                          color={theme.neutral_900}
                        />
                      </div>
                    </Col>
                  </Row>
                  <Row marginTop=18 alignItems=Row.Center>
                    <Col col=Col.Six>
                      <div className={CssHelper.flexBox()}>
                        <Heading
                          value="Current Status"
                          size=Heading.H5
                          weight=Heading.Regular
                          color={theme.neutral_900}
                        />
                      </div>
                    </Col>
                    <Col col=Col.Six>
                      <div className={CssHelper.flexBox()}>
                        <Text
                          value={proposal.currentStatus->CouncilProposalSub.CurrentStatus.getStatusText}
                          size=Text.Body1
                          weight=Text.Semibold
                          color={proposal.currentStatus->CouncilProposalSub.CurrentStatus.getStatusColor(
                            theme,
                          )}
                          block=true
                        />
                      </div>
                    </Col>
                  </Row>
                </Col>
                <Col col=Col.Five>
                  <Row>
                    <Col col=Col.Twelve>
                      <Text
                        size=Text.Body2
                        weight=Text.Semibold
                        color={theme.neutral_600}
                        marginBottom=8>
                        <span>
                          {`${(proposal.noVote +. proposal.yesVote)
                              ->Belt.Float.toString}/${proposal.totalWeight->Belt.Int.toString} `->React.string}
                        </span>
                        <span
                          className={Css.merge(list{
                            Styles.councilMember(theme),
                            CssHelper.clickable,
                          })}
                          onClick={_ => openMembers()}>
                          {proposal.council.name->CouncilSub.getCouncilNameString->React.string}
                        </span>
                        <span> {" member votes"->React.string} </span>
                      </Text>
                    </Col>
                  </Row>
                  <Row>
                    <Col col=Col.Twelve>
                      <ProgressBar.Voting2
                        slots={ProgressBar.Slot.getYesNoSlot(
                          theme,
                          ~yes={proposal.yesVote},
                          ~no={proposal.noVote},
                          ~totalWeight={proposal.totalWeight},
                        )}
                        fullWidth=true
                      />
                    </Col>
                  </Row>
                  <Row marginTop=4>
                    <Col col=Col.Three>
                      <div className={CssHelper.flexBox()}>
                        <div className={Styles.smallDot(theme.success_600)} />
                        <Text
                          value="Yes"
                          size=Text.Body2
                          weight=Text.Semibold
                          color={theme.neutral_900}
                          marginRight=8
                        />
                        <Text
                          value={proposal.yesVotePercent->formatVotePercent}
                          size=Text.Body2
                          weight=Text.Regular
                          color={theme.neutral_900}
                        />
                      </div>
                      <Text
                        value={`${proposal.yesVote->Belt.Float.toString} ${proposal.yesVote > 1.
                            ? "votes"
                            : "vote"}`}
                        size=Text.Body2
                        weight=Text.Regular
                        color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Three>
                      <div className={CssHelper.flexBox()}>
                        <div className={Styles.smallDot(theme.error_600)} />
                        <Text
                          value="No"
                          size=Text.Body2
                          weight=Text.Semibold
                          color={theme.neutral_900}
                          marginRight=8
                        />
                        <Text
                          value={proposal.noVotePercent->formatVotePercent}
                          size=Text.Body2
                          weight=Text.Regular
                          color={theme.neutral_900}
                        />
                      </div>
                      <Text
                        value={`${proposal.noVote->Belt.Float.toString} ${proposal.noVote > 1.
                            ? "votes"
                            : "vote"}`}
                        size=Text.Body2
                        weight=Text.Regular
                        color={theme.neutral_600}
                      />
                    </Col>
                  </Row>
                </Col>
              </Row>
            </InfoContainer>
          </Col>
        </Row>
      </div>
    </Section>
  }
}

@react.component
let make = (~proposalID) => {
  let proposalSub = CouncilProposalSub.get(proposalID)
  // let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(proposalID)
  // let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  // let allSub = Sub.all3(proposalSub, voteStatByProposalIDSub, bondedTokenCountSub)
  switch proposalSub {
  | Data(proposal) => <RenderData proposal />
  | Error(err) => <Heading value={err.message} />
  | Loading => <Heading value="Loading" />
  | NoData => <Heading value="NoData" />
  }
}
