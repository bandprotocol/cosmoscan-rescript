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

  let underline = style(. [textDecoration(#underline)])
}

module DepositButton = {
  @react.component
  let make = (
    ~accountOpt: option<AccountContext.t>,
    ~proposalID,
    ~proposalName,
    ~vetoID,
    ~totalDeposit,
  ) => {
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let openVeto = () =>
      Deposit(proposalID, proposalName, vetoID, totalDeposit)->SubmitTx->OpenModal->dispatchModal

    switch accountOpt {
    | Some({address}) =>
      <Button variant={Text} onClick={_ => openVeto()} style=Styles.underline>
        {"Deposit"->React.string}
      </Button>
    | None => React.null
    }
  }
}

module Wait = {
  @react.component
  let make = (
    ~proposal: CouncilProposalSub.t,
    ~vetoProposal: CouncilProposalSub.VetoProposal.t,
    ~totalDeposit: Coin.t,
  ) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (accountOpt, _) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openDepositors = () =>
      vetoProposal.id->ID.LegacyProposal.toInt->Depositors->OpenModal->dispatchModal

    <Row marginTopSm=24>
      <Col col=Col.Twelve mb=8 style={CssHelper.flexBox()}>
        <Heading
          value="Reject Details" size=Heading.H4 weight=Heading.Semibold color={theme.neutral_600}
        />
        <HSpacing size=Spacing.xs />
        <CTooltip
          tooltipPlacement=CTooltip.Top
          tooltipText="A veto proposal can be opened to prevent a proposal from being approved. It requires a deposit of 1,000 BAND.  
A veto proposal will pass and the proposal being vetoed will be rejected if the veto proposal has a quorum of more than 50% and the yes threshold exceeds 40%.">
          <Icon name="fal fa-info-circle" size=16 color={theme.neutral_400} />
        </CTooltip>
        <HSpacing size=Spacing.xs />
        <div className={CssHelper.clickable} onClick={_ => openDepositors()}>
          <Text
            value="View deposit transactions"
            size=Text.Body2
            weight=Text.Thin
            color=theme.primary_600
            spacing=Text.Em(0.05)
            block=true
          />
        </div>
      </Col>
      <Col col=Col.Twelve>
        <InfoContainer py=24 px=24>
          <Row>
            <Col col=Col.Five>
              <div className={CssHelper.flexBox()}>
                <Heading
                  value="Open status"
                  size=Heading.H4
                  weight=Heading.Regular
                  color={theme.neutral_900}
                  marginRight=8
                />
              </div>
            </Col>
            <Col col=Col.Seven>
              <div className={CssHelper.flexBox()}>
                <img alt="Pending Icon" src=Images.pending />
                <HSpacing size=Spacing.sm />
                <Text value="Incomplete" size=Text.Body1 color=theme.neutral_900 />
              </div>
            </Col>
          </Row>
          <Row marginTop=16>
            <Col col=Col.Five>
              <div className={CssHelper.flexBox()}>
                <Heading
                  value="Total deposit"
                  size=Heading.H4
                  weight=Heading.Regular
                  color={theme.neutral_900}
                  marginRight=8
                />
              </div>
            </Col>
            <Col col=Col.Seven>
              <div className={CssHelper.flexBox()}>
                <Text
                  value={`${totalDeposit
                    ->Coin.getBandAmountFromCoin
                    ->Format.fPretty(~digits=0)}/1,000 BAND`}
                  size=Text.Body1
                  code=true
                  color=theme.neutral_900
                />
                <HSpacing size=Spacing.sm />
                <DepositButton
                  accountOpt
                  proposalID=proposal.id
                  proposalName=proposal.title
                  vetoID=vetoProposal.id
                  totalDeposit={list{totalDeposit}}
                />
              </div>
            </Col>
          </Row>
          <Row marginTop=16>
            <Col>
              <div className={CssHelper.clickable} onClick={_ => openDepositors()}>
                <Text
                  value="View deposit transactions"
                  size=Text.Body2
                  weight=Text.Thin
                  color=theme.primary_600
                  spacing=Text.Em(0.05)
                  block=true
                />
              </div>
            </Col>
          </Row>
        </InfoContainer>
      </Col>
    </Row>
  }
}

module VetoVoteButton = {
  @react.component
  let make = (
    ~accountOpt: option<AccountContext.t>,
    ~vetoProposal: CouncilProposalSub.VetoProposal.t,
  ) => {
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let vote = () =>
      (vetoProposal.id, "vetoProposal name")->SubmitMsg.VetoVote->SubmitTx->OpenModal->dispatchModal

    switch accountOpt {
    | Some({address}) =>
      <Button
        variant={Outline} px=70 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => vote()}>
        {"Vote"->React.string}
      </Button>

    | None => React.null
    }
  }
}

module Vote = {
  @react.component
  let make = (
    ~vetoProposal: CouncilProposalSub.VetoProposal.t,
    ~status: CouncilProposalSub.Status.t,
    ~bondedToken: float,
  ) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (accountOpt, _) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(vetoProposal.id)

    let openDepositors = () =>
      vetoProposal.id->ID.LegacyProposal.toInt->Depositors->OpenModal->dispatchModal

    let turnout = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.total /. bondedToken *. 100.
    | _ => vetoProposal.turnout
    }

    let isTurnoutPassed = switch voteStatByProposalIDSub {
    | Data(voteStat) =>
      (turnout > CouncilProposalSub.VetoProposal.turnoutThreshold)
        ->CouncilProposalSub.CurrentStatus.fromBool
    | _ => vetoProposal.isTurnoutPassed
    }

    let isYesPassed = switch voteStatByProposalIDSub {
    | Data(voteStat) =>
      // veto passed mean Reject the Proposal
      // so invert it status !(
      !(
        voteStat.totalYes /. voteStat.total >= CouncilProposalSub.VetoProposal.yesThreshold
      )->CouncilProposalSub.CurrentStatus.fromBool
    | _ => vetoProposal.isYesPassed
    }

    let yesVote = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalYes
    | _ => vetoProposal.yesVote
    }

    let yesVotePercent = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalYesPercent
    | _ => vetoProposal.yesVotePercent
    }

    let noVote = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalNo
    | _ => vetoProposal.noVote
    }

    let noVotePercent = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalNoPercent
    | _ => vetoProposal.noVotePercent
    }

    let noWithVetoVote = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalNoWithVeto
    | _ => vetoProposal.noWithVetoVote
    }

    let noWithVetoVotePercent = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalNoWithVetoPercent
    | _ => vetoProposal.noWithVetoVotePercent
    }

    let abstainVote = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalAbstain
    | _ => vetoProposal.abstainVote
    }

    let abstainVotePercent = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.totalAbstainPercent
    | _ => vetoProposal.abstainVotePercent
    }

    let totalVote = switch voteStatByProposalIDSub {
    | Data(voteStat) => voteStat.total
    | _ => vetoProposal.totalVote
    }

    <Row marginTopSm=24>
      <Col col=Col.Twelve mb=8 style={CssHelper.flexBox()}>
        <Heading
          value="Reject Details" size=Heading.H4 weight=Heading.Semibold color={theme.neutral_600}
        />
        <HSpacing size=Spacing.xs />
        <CTooltip
          tooltipPlacement=CTooltip.Top
          tooltipText="A veto proposal can be opened to prevent a proposal from being approved. It requires a deposit of 1,000 BAND.  
A veto proposal will pass and the proposal being vetoed will be rejected if the veto proposal has a quorum of more than 50% and the yes threshold exceeds 40%.">
          <Icon name="fal fa-info-circle" size=16 color={theme.neutral_400} />
        </CTooltip>
        <HSpacing size=Spacing.xs />
        <div className={CssHelper.clickable} onClick={_ => openDepositors()}>
          <Text
            value="View deposit transactions"
            size=Text.Body2
            weight=Text.Thin
            color=theme.primary_600
            spacing=Text.Em(0.05)
            block=true
          />
        </div>
      </Col>
      <Col col=Col.Twelve>
        <InfoContainer py=24 px=24>
          <Row>
            <Col col=Col.Six colSm=Col.Twelve>
              <Row marginBottom=16>
                <Col col=Col.Seven colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Turnout"
                      size=Heading.H4
                      weight=Heading.Regular
                      color={theme.neutral_900}
                      marginRight=8
                    />
                    <Text
                      // minimum yes vote to pass set in CouncilProposalSub.passedThreshold
                      value={`min ${CouncilProposalSub.VetoProposal.turnoutThreshold->Belt.Float.toString}%`}
                      size=Text.Body2
                      weight=Text.Regular
                      color={theme.neutral_600}
                    />
                  </div>
                </Col>
                <Col col=Col.Five colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <img
                      src={switch isTurnoutPassed {
                      | Pass => Images.yesRed
                      | Reject => Images.noGreen
                      }}
                      alt={isTurnoutPassed->CouncilProposalSub.CurrentStatus.getStatusText}
                      className=Styles.yesnoImg
                    />
                    <Text
                      value={turnout->Format.fVotePercent}
                      size=Text.Body1
                      weight=Text.Bold
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
              </Row>
              <Row marginBottom=16>
                <Col col=Col.Seven colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Yes Vote"
                      size=Heading.H4
                      weight=Heading.Regular
                      color={theme.neutral_900}
                      marginRight=8
                    />
                    <Text
                      // minimum yes vote to pass set in CouncilProposalSub.passedThreshold
                      value={`min ${CouncilProposalSub.VetoProposal.yesThreshold->Belt.Float.toString}%`}
                      size=Text.Body2
                      weight=Text.Regular
                      color={theme.neutral_600}
                    />
                  </div>
                </Col>
                <Col col=Col.Five colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <img
                      src={switch isYesPassed {
                      | Pass => Images.yesRed
                      | Reject => Images.noGreen
                      }}
                      alt={isYesPassed->CouncilProposalSub.CurrentStatus.getStatusText}
                      className=Styles.yesnoImg
                    />
                    <Text
                      value={yesVotePercent->Format.fVotePercent}
                      size=Text.Body1
                      weight=Text.Bold
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
              </Row>
              <Row>
                <Col col=Col.Seven colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value={switch status {
                      | VetoPeriod => "Current Status"
                      | _ => "Status"
                      }}
                      size=Heading.H4
                      weight=Heading.Regular
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
                <Col col=Col.Five colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Text
                      value={vetoProposal.status->CouncilProposalSub.CurrentStatus.getStatusText}
                      size=Text.Body1
                      weight=Text.Semibold
                      color={vetoProposal.status->CouncilProposalSub.CurrentStatus.getStatusColorInverse(
                        theme,
                      )}
                      block=true
                    />
                  </div>
                </Col>
              </Row>
            </Col>
            {switch status {
            | VetoPeriod =>
              <Hidden variant={Mobile}>
                <Col col=Col.Six style={CssHelper.flexBox(~justify=#end_, ~align=#flexStart, ())}>
                  <VetoVoteButton accountOpt vetoProposal />
                </Col>
              </Hidden>
            | _ => React.null
            }}
          </Row>
          <SeperatedLine mt=24 mb=24 color=theme.neutral_300 />
          <Row marginTop=16>
            <Col>
              <VoteProgress.Veto
                props={{
                  proposal_id: vetoProposal.id,
                  yesVote,
                  noVote,
                  noWithVetoVote,
                  abstainVote,
                  totalVote,
                  yesVotePercent,
                  noVotePercent,
                  noWithVetoVotePercent,
                  abstainVotePercent,
                  totalBondedTokens: bondedToken,
                  turnout,
                }}
              />
            </Col>
          </Row>
        </InfoContainer>
      </Col>
    </Row>
  }
}
