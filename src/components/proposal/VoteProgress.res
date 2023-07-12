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
}

@react.component
let make = (~proposal: CouncilProposalSub.t, ~votes: array<CouncilVoteSub.t>) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

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
              value={proposal.yesVotePercent->Format.fVotePercent}
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
              value={proposal.noVotePercent->Format.fVotePercent}
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
  </>
}

module Veto = {
  @react.component
  let make = (~vetoProposal: CouncilProposalSub.VetoProposal.t) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openVetos = () => Syncing->OpenModal->dispatchModal

    <>
      <Row>
        <Col col=Col.Twelve mb=8 style={CssHelper.flexBox()}>
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
          <div className={CssHelper.mr(~size=16, ())}>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.smallDot(theme.error_600)} />
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
          <div className={CssHelper.mr(~size=16, ())}>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.smallDot(theme.success_600)} />
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
          <div className={CssHelper.mr(~size=16, ())}>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.smallDot(theme.success_800)} />
              <Text
                value="NWV"
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
          <div className={CssHelper.mr(~size=16, ())}>
            <div className={CssHelper.flexBox()}>
              <div className={Styles.smallDot(theme.neutral_500)} />
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
        </Col>
      </Row>
    </>
  }
}
