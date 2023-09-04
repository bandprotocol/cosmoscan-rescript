module Styles = {
  open CssJs

  let proposalCardContainer = style(. [maxWidth(#px(932))])

  let badge = style(. [marginTop(#px(8))])
  let timestamp = style(. [selector("> p", [fontWeight(#num(300))])])
}
@react.component
let make = (~reserveIndex, ~proposal: ProposalSub.t) => {
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(proposal.id)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()
  let allSub = Sub.all2(voteStatByProposalIDSub, bondedTokenCountSub)

  <Col key={reserveIndex->Belt.Int.toString} style=Styles.proposalCardContainer mb=24 mbSm=16>
    <InfoContainer py=24>
      <Row>
        <Col col=Col.Twelve>
          <div className={CssHelper.flexBox()}>
            <Link
              route=LegacyProposalDetailsPage(proposal.id->ID.LegacyProposal.toInt)
              className={CssHelper.flexBox()}>
              <TypeID.LegacyProposal
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
              {isMobile ? React.null : <LegacyProposalBadge status=proposal.status />}
            </Link>
            <HSpacing size=Spacing.sm />
            {isMobile ? <LegacyProposalBadge status=proposal.status /> : React.null}
          </div>
          {isMobile
            ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.badge})}>
                <LegacyProposalBadge status=proposal.status />
              </div>
            : React.null}
        </Col>
      </Row>
      <SeperatedLine />
      <Row>
        <Col col=Col.Four colSm=Col.Six>
          <Heading
            value="Proposer"
            size=Heading.H5
            marginBottom=8
            weight=Heading.Thin
            color={theme.neutral_600}
          />
          {switch proposal.proposerAddressOpt {
          | Some(proposerAddress) =>
            <AddressRender address=proposerAddress position=AddressRender.Subtitle ellipsis=true />
          | None => <Text value="Proposed on Wenchang" />
          }}
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
                timeOpt={switch proposal.status {
                | Deposit => Some(proposal.depositEndTime)
                | Voting
                | Passed
                | Rejected
                | Inactive
                | Failed =>
                  proposal.votingEndTime
                }}
                color={theme.neutral_900}
                suffix=" +UTC"
              />
            </Col>}
        <Col col=Col.Three colSm=Col.Six>
          <Heading
            value="Turnout"
            size=Heading.H5
            marginBottom=8
            weight=Heading.Thin
            color={theme.neutral_600}
          />
          {switch allSub {
          | Data({total, totalYes, totalNo, totalNoWithVeto, totalAbstain}, bondedToken) =>
            <div className={CssHelper.flexBox()}>
              <Text
                value={
                  let turnoutPercent = switch proposal.totalBondedTokens {
                  | Some(totalBondedTokensExn) =>
                    proposal.endTotalVote /. totalBondedTokensExn *. 100.
                  | None => total /. bondedToken->Coin.getBandAmountFromCoin *. 100.
                  }
                  (turnoutPercent < 10. ? "0" : "") ++
                  turnoutPercent->Format.fPretty(~digits=2) ++ "%"
                }
                size=Text.Body1
                weight=Text.Thin
                color=theme.neutral_900
                spacing=Text.Em(0.05)
                block=true
                code=true
              />
              <HSpacing size=Spacing.sm />
              {switch proposal.totalBondedTokens {
              | Some(_) =>
                <ProgressBar.Voting2
                  slots={ProgressBar.Slot.getFullSlot(
                    theme,
                    ~yes={proposal.endTotalYes},
                    ~no={proposal.endTotalNo},
                    ~noWithVeto={proposal.endTotalNoWithVeto},
                    ~abstain={proposal.endTotalAbstain},
                    ~totalBondedTokens={
                      proposal.totalBondedTokens->Belt.Option.getWithDefault(0.)
                    },
                    (),
                  )}
                />
              | None =>
                <ProgressBar.Voting2
                  slots={ProgressBar.Slot.getFullSlot(
                    theme,
                    ~yes={totalYes},
                    ~no={totalNo},
                    ~noWithVeto={totalNoWithVeto},
                    ~abstain={totalAbstain},
                    ~totalBondedTokens={
                      bondedToken->Coin.getBandAmountFromCoin
                    },
                    (),
                  )}
                />
              }}
            </div>
          | _ => <LoadingCensorBar width={isMobile ? 120 : 270} height=15 />
          }}
        </Col>
      </Row>
    </InfoContainer>
  </Col>
}
