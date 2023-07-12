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

type variant = Short | Full

@react.component
let make = (~proposal: CouncilProposalSub.t, ~votes: array<CouncilVoteSub.t>, ~variant=Full) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

  let formatVotePercent = value =>
    (value < 10. ? "0" : "") ++ value->Format.fPretty(~digits=2) ++ "%"

  <Row>
    <Col col=Col.Seven>
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
            style={CssHelper.flexBox(~direction=#column, ~justify=#center, ~align=#left, ())}
            col={switch variant {
            | Full => Col.Four
            | Short => Col.Six
            }}>
            <div>
              <Row>
                <Col
                  col={switch variant {
                  | Full => Col.Six
                  | Short => Col.Seven
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
                  | Short => Col.Five
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
              <Row marginTop=18 alignItems=Row.Center>
                <Col
                  col={switch variant {
                  | Full => Col.Six
                  | Short => Col.Seven
                  }}>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Current Status"
                      size=Heading.H5
                      weight=Heading.Regular
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
                <Col
                  col={switch variant {
                  | Full => Col.Six
                  | Short => Col.Five
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
          <Col
            col={switch variant {
            | Full => Col.Five
            | Short => Col.Six
            }}>
            <Row>
              <Col col=Col.Twelve>
                <Text size=Text.Body2 weight=Text.Semibold color={theme.neutral_600} marginBottom=8>
                  <span>
                    {`${votes
                      ->Belt.Array.length
                      ->Belt.Int.toString}/${proposal.council.councilMembers
                      ->Belt.Array.length
                      ->Belt.Int.toString} `->React.string}
                  </span>
                  <span
                    className={Css.merge(list{Styles.councilMember(theme), CssHelper.clickable})}
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
            <Row marginTop=4 marginBottom=14>
              <Col col=Col.Twelve style={CssHelper.flexBox()}>
                <div className={CssHelper.mr(~size=40, ())}>
                  <div className={CssHelper.flexBox()}>
                    <div className={Styles.smallDot(theme.success_600)} />
                    <Text
                      value="Yes"
                      size=Text.Body1
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
                    value={
                      let yesVote = votes->CouncilVoteSub.getVoteCount(Yes)
                      `${yesVote->Belt.Int.toString} ${yesVote > 1 ? "votes" : "vote"}`
                    }
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_600}
                  />
                </div>
                <div>
                  <div className={CssHelper.flexBox()}>
                    <div className={Styles.smallDot(theme.error_600)} />
                    <Text
                      value="No"
                      size=Text.Body1
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
                    value={
                      let noVote = votes->CouncilVoteSub.getVoteCount(No)
                      `${noVote->Belt.Int.toString} ${noVote > 1 ? "votes" : "vote"}`
                    }
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_600}
                  />
                </div>
              </Col>
            </Row>
          </Col>
        </Row>
      </InfoContainer>
    </Col>
  </Row>
}
