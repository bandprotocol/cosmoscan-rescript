module Styles = {
  open CssJs

  let proposalCardContainer = style(. [maxWidth(#px(932))])

  let badge = style(. [marginTop(#px(8))])
  let timestamp = style(. [selector("> p", [fontWeight(#num(300))])])
}

@react.component
let make = (~reserveIndex, ~proposal: CouncilProposalSub.t) => {
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

  <Col key={reserveIndex->Belt.Int.toString} style=Styles.proposalCardContainer mb=24 mbSm=16>
    <InfoContainer py=24>
      <Row>
        <Col col=Col.Twelve>
          <Link
            route=ProposalDetailsPage(proposal.id->ID.Proposal.toInt)
            className={CssHelper.flexBox()}>
            <TypeID.Proposal
              id={proposal.id}
              position=TypeID.Title
              size=Text.Xl
              weight=Text.Bold
              color={theme.neutral_900}
              isNotLink=true
            />
            <HSpacing size=Spacing.sm />
            <Text
              size=Text.Xl value=proposal.title color={theme.neutral_900} weight=Text.Semibold
            />
            <HSpacing size=Spacing.sm />
            {isMobile ? React.null : <ProposalBadge status=proposal.status />}
          </Link>
          {isMobile
            ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.badge})}>
                <ProposalBadge status=proposal.status />
              </div>
            : React.null}
        </Col>
      </Row>
      <SeperatedLine />
      <Row>
        <Col col=Col.Four colSm=Col.Six>
          <Heading
            value="Vote by"
            size=Heading.H5
            marginBottom=8
            weight=Heading.Thin
            color={theme.neutral_600}
          />
          <div className={CssHelper.clickable} onClick={_ => openMembers()}>
            <Text
              value={proposal.council.name->CouncilSub.getCouncilNameString}
              size=Text.Body1
              weight=Text.Thin
              color=theme.primary_600
              spacing=Text.Em(0.05)
              block=true
            />
          </div>
        </Col>
        {isMobile
          ? React.null
          : <Col col=Col.Four>
              <Heading
                value="Voting End"
                size=Heading.H5
                marginBottom=8
                weight=Heading.Thin
                color={theme.neutral_600}
              />
              <Timestamp
                size=Text.Body1
                timeOpt={Some(proposal.votingEndTime)}
                color={theme.neutral_900}
                suffix=" +UTC"
                style={Styles.timestamp}
              />
            </Col>}
        <Col col=Col.Three colSm=Col.Six>
          <Heading
            value="Yes Vote"
            size=Heading.H5
            marginBottom=8
            weight=Heading.Thin
            color={theme.neutral_600}
          />
          <div className={CssHelper.flexBox()}>
            <Text
              value={(proposal.yesVotePercent < 10. ? "0" : "") ++
              proposal.yesVotePercent->Format.fPretty(~digits=2) ++ "%"}
              size=Text.Body1
              weight=Text.Thin
              color=theme.neutral_900
              spacing=Text.Em(0.05)
              block=true
              code=true
            />
            <HSpacing size=Spacing.sm />
            <ProgressBar.Voting2
              slots={ProgressBar.Slot.getYesNoSlot(
                theme,
                ~yes={proposal.yesVote},
                ~no={proposal.noVote},
                ~totalWeight={proposal.totalWeight},
              )}
            />
          </div>
        </Col>
        {isMobile
          ? React.null
          : switch proposal.vetoProposalOpt {
            | Some(vetoProposal) =>
              <Col col=Col.One>
                <Heading
                  value="Veto"
                  size=Heading.H5
                  marginBottom=8
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                <Text
                  value={vetoProposal.status->CouncilProposalSub.CurrentStatus.getStatusText}
                  size=Text.Body1
                  weight=Text.Regular
                  color={vetoProposal.status->CouncilProposalSub.CurrentStatus.getStatusColorInverse(
                    theme,
                  )}
                  spacing=Text.Em(0.05)
                  block=true
                />
              </Col>

            | None => React.null
            }}
      </Row>
    </InfoContainer>
  </Col>
}
