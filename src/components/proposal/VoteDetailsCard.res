module Styles = {
  open CssJs

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

  let msgContainer = style(. [selector("> div + div", [marginTop(#px(24))])])
}

type variant = Short | Half | Full

@react.component
let make = (~proposal: CouncilProposalSub.t, ~votes: array<CouncilVoteSub.t>, ~variant=Full) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

  <Row>
    <Col col=Col.Twelve>
      <Heading
        value="Vote Details"
        size=Heading.H4
        weight=Heading.Semibold
        color={theme.neutral_600}
        marginBottom=8
      />
    </Col>
    <Col col=Col.Twelve>
      <InfoContainer py=24 px=32>
        <Row>
          <Col
            col={switch variant {
            | Full => Col.Four
            | _ => Col.Six
            }}
            mb=22
            style={CssHelper.flexBox(~direction=#column, ~justify=#center, ~align=#left, ())}>
            <div>
              <Row>
                <Col
                  col={switch variant {
                  | Full => Col.Six
                  | _ => Col.Seven
                  }}>
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
                <Col
                  col={switch variant {
                  | Full => Col.Six
                  | _ => Col.Five
                  }}>
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
              <Row marginTop=16 alignItems=Row.Center>
                <Col
                  col={switch variant {
                  | Full => Col.Six
                  | _ => Col.Seven
                  }}>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Current Status"
                      size=Heading.H5
                      weight=Heading.Regular
                      color={theme.neutral_900}
                    />
                    {proposal.isCurrentRejectByVeto
                      ? <>
                          <HSpacing size=Spacing.xs />
                          <CTooltip
                            tooltipPlacement=CTooltip.Bottom
                            tooltipText="The proposal was rejected because a veto was passed.">
                            <Icon name="fal fa-info-circle" size=16 color={theme.neutral_400} />
                          </CTooltip>
                        </>
                      : React.null}
                  </div>
                </Col>
                <Col
                  col={switch variant {
                  | Full => Col.Six
                  | _ => Col.Five
                  }}>
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
            </div>
          </Col>
          {switch variant {
          | Half => <SeperatedLine mt=24 mb=24 color=theme.neutral_300 />
          | _ => React.null
          }}
          <Col
            col={switch variant {
            | Full => Col.Five
            | Short => Col.Six
            | Half => Col.Twelve
            }}>
            <VoteProgress proposal votes />
          </Col>
        </Row>
      </InfoContainer>
    </Col>
  </Row>
}

module Legacy = {
  @react.component
  let make = (~proposal: ProposalSub.t, ~voteStat: VoteSub.vote_stat_t, ~bondedToken: Coin.t) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let turnOut = switch proposal.totalBondedTokens {
    | Some(totalBondedTokensExn) => proposal.endTotalVote /. totalBondedTokensExn *. 100.
    | None => voteStat.total /. bondedToken->Coin.getBandAmountFromCoin *. 100.
    }

    <Row>
      <Col col=Col.Twelve>
        <Heading
          value="Vote Details"
          size=Heading.H4
          weight=Heading.Semibold
          color={theme.neutral_600}
          marginBottom=8
        />
      </Col>
      <Col col=Col.Twelve>
        <InfoContainer py=24 px=32>
          <Row>
            <Col col=Col.Three>
              <Row>
                <Col col=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Turnout"
                      size=Heading.H5
                      weight=Heading.Regular
                      color={theme.neutral_900}
                      marginRight=8
                    />
                    <Text
                      // minimum yes vote to pass set in CouncilProposalSub.passedTheshold
                      value="min 40%"
                      size=Text.Body2
                      weight=Text.Regular
                      color={theme.neutral_600}
                    />
                  </div>
                </Col>
                <Col col=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <img
                      src={switch proposal.status {
                      | Passed => Images.yesGreen
                      | _ => Images.noRed
                      }}
                      alt={proposal.status->ProposalSub.getStatusText}
                      className=Styles.yesnoImg
                    />
                    <Text
                      value={turnOut->Format.fPercent(~digits=2)}
                      size=Text.Body1
                      weight=Text.Bold
                      color={theme.neutral_900}
                      code=true
                    />
                  </div>
                </Col>
              </Row>
              <Row marginTop=16>
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
                      value="min 50%"
                      size=Text.Body2
                      weight=Text.Regular
                      color={theme.neutral_600}
                    />
                  </div>
                </Col>
                <Col col=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <img
                      src={switch proposal.status {
                      | Passed => Images.yesGreen
                      | _ => Images.noRed
                      }}
                      alt={proposal.status->ProposalSub.getStatusText}
                      className=Styles.yesnoImg
                    />
                    <Text
                      value={proposal.endTotalYesPercent->Format.fPercent(~digits=2)}
                      size=Text.Body1
                      weight=Text.Bold
                      color={theme.neutral_900}
                      code=true
                    />
                  </div>
                </Col>
              </Row>
              <Row marginTop=16 alignItems=Row.Center>
                <Col col=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Status"
                      size=Heading.H5
                      weight=Heading.Regular
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
                <Col col=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Text
                      value={proposal.status->ProposalSub.getStatusText}
                      size=Text.Body1
                      weight=Text.Semibold
                      color={proposal.status->ProposalSub.getStatusColor(theme)}
                      block=true
                    />
                  </div>
                </Col>
              </Row>
            </Col>
            <Col col=Col.Nine>
              <VoteProgress.Legacy proposal voteStat bondedToken />
            </Col>
          </Row>
        </InfoContainer>
      </Col>
    </Row>
  }
}
