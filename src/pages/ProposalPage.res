module Styles = {
  open CssJs

  let descriptionHeader = (theme: Theme.t) =>
    style(. [
      fontSize(#px(14)),
      fontWeight(#num(400)),
      color(theme.neutral_600),
      selector("> a", [color(theme.primary_600)]),
    ])

  let idContainer = {
    style(. [
      selector(
        "> h3",
        [
          marginLeft(#px(10)),
          marginRight(#px(10)),
          Media.mobile([marginLeft(#zero), marginTop(#px(8)), marginBottom(#px(8))]),
        ],
      ),
    ])
  }
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let proposalLink = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.primary_600),
      borderRadius(#px(8)),
      width(#px(32)),
      height(#px(32)),
      hover([backgroundColor(theme.primary_800)]),
    ])

  let proposalCardContainer = style(. [maxWidth(#px(932))])

  let chipContainer = style(. [marginTop(#px(16))])
  let chip = style(. [borderRadius(#px(20)), marginRight(#px(8)), marginTop(#px(8))])
  let badge = style(. [marginTop(#px(8))])
  let timestamp = style(. [selector("> p", [fontWeight(#num(300))])])
}

module CouncilProposalCard = {
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
}

module ProposalCard = {
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
                size=Text.Xl value=proposal.name color={theme.neutral_900} weight=Text.Semibold
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
              <AddressRender
                address=proposerAddress position=AddressRender.Subtitle ellipsis=true
              />
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
}

@react.component
let make = () => {
  let pageSize = 10
  let (filterStr, setFilterStr) = React.useState(_ => "All")

  let proposalsSub = ProposalSub.getList(~pageSize, ~page=1, ())
  let councilProposalSub = CouncilProposalSub.getList(~filter=filterStr, ~pageSize, ~page=1, ())
  let councilProposalCount = CouncilProposalSub.count()
  let proposalCount = ProposalSub.count()

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve mb=8 mbSm=16 style={CssHelper.flexBox()}>
          <Heading value="Council Proposals" size=Heading.H1 />
          <HSpacing size=Spacing.lg />
          {switch councilProposalCount {
          | Data(count) =>
            <Text
              value={count->Belt.Int.toString ++ " In Total"}
              size=Text.Xl
              weight=Text.Regular
              color=theme.neutral_600
              block=true
            />
          | _ => React.null
          }}
        </Col>
        <Col col=Col.Twelve>
          <p className={Styles.descriptionHeader(theme)}>
            <span> {"All proposals are first discussed on a "->React.string} </span>
            <AbsoluteLink href="#">
              <span> {"forum"->React.string} </span>
            </AbsoluteLink>
            <span>
              {" before being submitted to the on-chain proposal system by "->React.string}
            </span>
            <AbsoluteLink href="#">
              <span> {"council members"->React.string} </span>
            </AbsoluteLink>
            <span> {" to involve the community and improve decision-making."->React.string} </span>
          </p>
        </Col>
        <Col col=Col.Twelve style={Css.merge(list{CssHelper.flexBox(), Styles.chipContainer})}>
          {CouncilProposalSub.proposalsTypeStr
          ->Belt.Array.mapWithIndex((i, pt) =>
            <ChipButton
              key={i->Belt.Int.toString}
              variant={ChipButton.Outline}
              onClick={_ => setFilterStr(_ => pt)}
              isActive={pt === filterStr}
              style={Styles.chip}>
              {pt->React.string}
            </ChipButton>
          )
          ->React.array}
        </Col>
      </Row>
      <Row style={CssHelper.flexBox(~justify=#center, ())}>
        {switch councilProposalSub {
        | Data(proposals) =>
          proposals->Belt.Array.size > 0
            ? proposals
              ->Belt.Array.mapWithIndex((i, proposal) => {
                <CouncilProposalCard key={i->Belt.Int.toString} reserveIndex=i proposal />
              })
              ->React.array
            : <EmptyContainer>
                <img
                  alt="No Proposal"
                  src={isDarkMode ? Images.noTxDark : Images.noTxLight}
                  className=Styles.noDataImage
                />
                <Heading
                  size=Heading.H4
                  value="No Proposal"
                  align=Heading.Center
                  weight=Heading.Regular
                  color={theme.neutral_600}
                />
              </EmptyContainer>
        | _ =>
          Belt.Array.make(pageSize, Sub.NoData)
          ->Belt.Array.mapWithIndex((i, noData) => React.null)
          // <CouncilProposalCard key={i->Belt.Int.toString} reserveIndex=i id={1->ID.Proposal.fromInt} />
          ->React.array
        }}
      </Row>
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24 marginTop=40 marginTopSm=24>
        <Col col=Col.Twelve style={CssHelper.flexBox()}>
          <Heading value="Proposals" size=Heading.H1 />
          <HSpacing size=Spacing.lg />
          {switch proposalCount {
          | Data(count) =>
            <Text
              value={count->Belt.Int.toString ++ " In Total"}
              size=Text.Xl
              weight=Text.Regular
              color=theme.neutral_600
              block=true
            />
          | _ => React.null
          }}
        </Col>
      </Row>
      <Row style={CssHelper.flexBox(~justify=#center, ())}>
        {switch proposalsSub {
        | Data(proposals) =>
          proposals->Belt.Array.size > 0
            ? proposals
              ->Belt.Array.mapWithIndex((i, proposal) => {
                <ProposalCard key={i->Belt.Int.toString} reserveIndex=i proposal />
              })
              ->React.array
            : <EmptyContainer>
                <img
                  alt="No Proposal"
                  src={isDarkMode ? Images.noTxDark : Images.noTxLight}
                  className=Styles.noDataImage
                />
                <Heading
                  size=Heading.H4
                  value="No Proposal"
                  align=Heading.Center
                  weight=Heading.Regular
                  color={theme.neutral_600}
                />
              </EmptyContainer>
        | _ =>
          Belt.Array.make(pageSize, Sub.NoData)
          ->Belt.Array.mapWithIndex((i, noData) => React.null)
          ->React.array
        }}
      </Row>
    </div>
  </Section>
}
