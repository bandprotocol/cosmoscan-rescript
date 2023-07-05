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
  let chipStyle = style(. [borderRadius(#px(20)), marginRight(#px(8))])
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
                size=Text.Xl
                // TODO: change dis wen title ready
                value="Activate the community pool"
                color={theme.neutral_900}
                weight=Text.Semibold
              />
              <HSpacing size=Spacing.sm />
              <CouncilProposalBadge status=proposal.status />
            </div>
          </Col>
        </Row>
        <SeperatedLine />
        <Row>
          <Col col=Col.Four>
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
          <Col col=Col.Four>
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
          </Col>
          <Col col=Col.Three>
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
          {switch proposal.vetoProposal {
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
                value={vetoProposal.status->CouncilProposalSub.VetoProposal.getStatusText}
                size=Text.Body1
                weight=Text.Thin
                color={vetoProposal.status->CouncilProposalSub.VetoProposal.getStatusColor(theme)}
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
                size=Text.Xl
                value="Activate the community pool"
                color={theme.neutral_900}
                weight=Text.Semibold
              />
              <HSpacing size=Spacing.sm />
              <ProposalBadge status=proposal.status />
            </div>
          </Col>
        </Row>
        <SeperatedLine />
        <Row>
          <Col col=Col.Four>
            <Heading
              value="Proposer"
              size=Heading.H5
              marginBottom=8
              weight=Heading.Thin
              color={theme.neutral_600}
            />
            {switch proposal.proposerAddressOpt {
            | Some(proposerAddress) =>
              <AddressRender address=proposerAddress position=AddressRender.Subtitle />
            | None => <Text value="Proposed on Wenchang" />
            }}
          </Col>
          <Col col=Col.Four>
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
          </Col>
          <Col col=Col.Three>
            <Heading
              value="Turnout"
              size=Heading.H5
              marginBottom=8
              weight=Heading.Thin
              color={theme.neutral_600}
            />
            <div className={CssHelper.flexBox()}>
              <Text
                value={(proposal.endTotalYesPercent < 10. ? "0" : "") ++
                proposal.endTotalYesPercent->Format.fPretty(~digits=2) ++ "%"}
                size=Text.Body1
                weight=Text.Thin
                color=theme.neutral_900
                spacing=Text.Em(0.05)
                block=true
                code=true
              />
              <HSpacing size=Spacing.sm />
              <ProgressBar.Voting2
                slots={ProgressBar.Slot.getFullSlot(
                  theme,
                  ~yes={proposal.endTotalYes},
                  ~no={proposal.endTotalYes},
                  ~noWithVeto={proposal.endTotalNoWithVeto},
                  ~abstain={proposal.endTotalAbstain},
                  ~bondedTokenCount={proposal.totalBondedTokens->Belt.Option.getWithDefault(0.)},
                )}
              />
            </div>
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

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve style={CssHelper.flexBox()}>
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
              style={Styles.chipStyle}>
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
    </div>
  </Section>
}
