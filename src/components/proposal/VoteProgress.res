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

  let rejectVoteDetail = style(. [display(#flex), Media.mobile([display(#block)])])

  let voteCountGroup = style(. [
    display(#flex),
    flexGrow(1.),
    width(#percent(100.)),
    Media.mobile([display(#block)]),
  ])
  let voteCountBox = style(. [marginRight(#px(16)), flexGrow(1.)])
}

@react.component
let make = (~proposal: CouncilProposalSub.t, ~votes: array<CouncilVoteSub.t>) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

  let {
    yesVoteByWeight,
    noVoteByWeight,
    yesVotePercent,
    noVotePercent,
    totalWeight,
  } = Council.calculateVote(votes, proposal.council.councilMembers)

  <>
    <Row>
      <Col col=Col.Twelve>
        <Text size=Text.Body2 weight=Text.Semibold color={theme.neutral_600} marginBottom=8>
          <span>
            {`${votes->Belt.Array.length->Belt.Int.toString}/${proposal.council.councilMembers
              ->Belt.Array.length
              ->Belt.Int.toString} `->React.string}
          </span>
          <span
            className={Css.merge(list{Styles.councilMember(theme), CssHelper.clickable})}
            onClick={_ => openMembers()}>
            {proposal.council.name->Council.getCouncilNameString->React.string}
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
            ~yes={yesVoteByWeight->Belt.Int.toFloat},
            ~no={noVoteByWeight->Belt.Int.toFloat},
            ~totalWeight={totalWeight},
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
              value={yesVotePercent->Format.fVotePercent}
              size=Text.Body2
              weight=Text.Regular
              color={theme.neutral_900}
            />
          </div>
          <Text
            value={`${yesVoteByWeight->Belt.Int.toString} ${yesVoteByWeight > 1
                ? "votes"
                : "vote"}`}
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
              value={proposal.noVotePercent->Format.fVotePercent}
              size=Text.Body2
              weight=Text.Regular
              color={theme.neutral_900}
            />
          </div>
          <Text
            value={`${noVoteByWeight->Belt.Int.toString} ${noVoteByWeight > 1 ? "votes" : "vote"}`}
            size=Text.Body2
            weight=Text.Regular
            color={theme.neutral_600}
          />
        </div>
      </Col>
    </Row>
  </>
}

module Veto = {
  @react.component
  let make = (~vetoProposal: CouncilProposalSub.VetoProposal.t, ~legacy=false) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openVetos = () => vetoProposal.id->VetoVote->OpenModal->dispatchModal

    <>
      <Row>
        <Col col=Col.Twelve mb=8 style={Styles.rejectVoteDetail}>
          <Text
            value={`${vetoProposal.totalVote->Format.fCurrency} of ${vetoProposal.totalBondedTokens->Format.fCurrency} BAND voted (${vetoProposal.turnout->Belt.Float.toString}%)`}
            size=Text.Body2
            weight=Text.Semibold
            color={theme.neutral_600}
          />
          <HSpacing size=Spacing.sm />
          <div className={CssHelper.clickable} onClick={_ => openVetos()}>
            <Text
              value="View veto votes"
              size=Text.Body2
              weight=Text.Thin
              color=theme.primary_600
              spacing=Text.Em(0.05)
              block=true
            />
          </div>
        </Col>
      </Row>
      <Row>
        <Col col=Col.Twelve>
          <ProgressBar.Voting2
            slots={ProgressBar.Slot.getFullSlot(
              theme,
              ~yes={vetoProposal.yesVote},
              ~no={vetoProposal.noVote},
              ~noWithVeto={vetoProposal.noWithVetoVote},
              ~abstain={vetoProposal.abstainVote},
              ~totalBondedTokens={vetoProposal.totalBondedTokens},
              ~invertColor=true,
              (),
            )}
            fullWidth=true
          />
        </Col>
      </Row>
      <Row marginTop=4 marginBottom=14>
        <Col col=Col.Twelve style={CssHelper.flexBox()}>
          <div className={Styles.voteCountGroup}>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div
                    className={Styles.smallDot(Vote.Full.Yes->Vote.Full.getColorInvert(theme))}
                  />
                  <Text
                    value="Yes"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={vetoProposal.yesVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${vetoProposal.yesVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div className={Styles.smallDot(Vote.Full.No->Vote.Full.getColorInvert(theme))} />
                  <Text
                    value="No"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={vetoProposal.noVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${vetoProposal.noVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
            </div>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div
                    className={Styles.smallDot(
                      Vote.Full.NoWithVeto->Vote.Full.getColorInvert(theme),
                    )}
                  />
                  <Text
                    value="Veto"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={vetoProposal.noWithVetoVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${vetoProposal.noWithVetoVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div
                    className={Styles.smallDot(Vote.Full.Abstain->Vote.Full.getColorInvert(theme))}
                  />
                  <Text
                    value="Abstain"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={vetoProposal.abstainVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${vetoProposal.abstainVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
            </div>
          </div>
        </Col>
      </Row>
    </>
  }
}

module Legacy = {
  @react.component
  let make = (~proposal: ProposalSub.t, ~voteStat: VoteSub.vote_stat_t, ~bondedToken: Coin.t) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openVetos = () => Syncing->OpenModal->dispatchModal

    let yesVote = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalYes
    | None => voteStat.totalYes
    }

    let noVote = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalNo
    | None => voteStat.totalNo
    }

    let noWithVetoVote = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalNoWithVeto
    | None => voteStat.totalNoWithVeto
    }

    let abstainVote = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalAbstain
    | None => voteStat.totalAbstain
    }

    let yesVotePercent = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalYesPercent
    | None => voteStat.totalYesPercent
    }

    let noVotePercent = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalNoPercent
    | None => voteStat.totalNoPercent
    }

    let noWithVetoVotePercent = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalNoWithVetoPercent
    | None => voteStat.totalNoWithVetoPercent
    }

    let abstainVotePercent = switch proposal.totalBondedTokens {
    | Some(_) => proposal.endTotalAbstainPercent
    | None => voteStat.totalAbstainPercent
    }

    let turnOut = switch proposal.totalBondedTokens {
    | Some(totalBondedTokensExn) => proposal.endTotalVote /. totalBondedTokensExn *. 100.
    | None => voteStat.total /. bondedToken->Coin.getBandAmountFromCoin *. 100.
    }

    let totalBondedToken = switch proposal.totalBondedTokens {
    | Some(totalBondedTokensExn) => totalBondedTokensExn
    | None => bondedToken->Coin.getBandAmountFromCoin
    }

    <>
      <Row marginBottom=16>
        <Col col=Col.Twelve style={CssHelper.flexBox()}>
          <Text
            value={`${yesVote->Format.fCurrency} of ${totalBondedToken->Format.fCurrency} BAND voted (${turnOut->Format.fPretty(
                ~digits=2,
              )}%)`}
            size=Text.Body2
            weight=Text.Semibold
            color={theme.neutral_600}
          />
          <HSpacing size=Spacing.sm />
        </Col>
      </Row>
      <Row>
        <Col col=Col.Twelve>
          <ProgressBar.Voting2
            slots={ProgressBar.Slot.getFullSlot(
              theme,
              ~yes={yesVote},
              ~no={noVote},
              ~noWithVeto={noWithVetoVote},
              ~abstain={abstainVote},
              ~totalBondedTokens={totalBondedToken},
              (),
            )}
            fullWidth=true
          />
        </Col>
      </Row>
      <Row marginTop=8>
        <Col col=Col.Twelve style={CssHelper.flexBox()}>
          <div className={Styles.voteCountGroup}>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div className={Styles.smallDot(Vote.Full.Yes->Vote.Full.getColor(theme))} />
                  <Text
                    value="Yes"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={yesVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${yesVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div className={Styles.smallDot(Vote.Full.No->Vote.Full.getColor(theme))} />
                  <Text
                    value="No"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={noVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${noVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
            </div>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div
                    className={Styles.smallDot(Vote.Full.NoWithVeto->Vote.Full.getColor(theme))}
                  />
                  <Text
                    value="Veto"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={noWithVetoVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${noWithVetoVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
              <div className={Styles.voteCountBox}>
                <div className={CssHelper.flexBox()}>
                  <div className={Styles.smallDot(Vote.Full.Abstain->Vote.Full.getColor(theme))} />
                  <Text
                    value="Abstain"
                    size=Text.Body1
                    weight=Text.Semibold
                    color={theme.neutral_900}
                    marginRight=8
                  />
                  <Text
                    value={abstainVotePercent->Format.fVotePercent}
                    size=Text.Body2
                    weight=Text.Regular
                    color={theme.neutral_900}
                  />
                </div>
                <Text
                  value={`${abstainVote->Format.fPretty(~digits=0)} BAND`}
                  size=Text.Body2
                  weight=Text.Regular
                  color={theme.neutral_600}
                />
              </div>
            </div>
          </div>
        </Col>
      </Row>
    </>
  }
}
