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

  let proposalId = style(. [
    fontFamilies([#custom("Roboto Mono"), #monospace]),
    Media.mobile([display(#block), marginBottom(#px(8))]),
  ])

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

  let loadingContainer = style(. [
    display(#flex),
    alignItems(#center),
    width(#percent(100.)),
    height(#vh(80.)),
  ])

  let buttonStyled = style(. [
    backgroundColor(#transparent),
    border(#zero, #solid, #transparent),
    outlineStyle(#none),
    cursor(#pointer),
    padding2(~v=#zero, ~h=#zero),
    margin4(~top=#zero, ~right=#zero, ~bottom=#px(40), ~left=#zero),
    Media.mobile([margin4(~top=#zero, ~right=#zero, ~bottom=#px(16), ~left=#zero)]),
  ])

  let badge = style(. [marginTop(#px(8))])
  let header = style(. [marginBottom(#px(24))])
  let msgContainer = style(. [selector("> div + div", [marginTop(#px(24))])])
}

module VoteButton = {
  @react.component
  let make = (~accountOpt: option<AccountContext.t>, ~proposalID, ~proposalName) => {
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let vote = () => Vote(proposalID, proposalName)->SubmitTx->OpenModal->dispatchModal

    switch accountOpt {
    | Some({address}) =>
      let accountQuery = AccountQuery.get(address)
      switch accountQuery {
      | Data({councilMembers}) =>
        switch councilMembers->Belt.Array.length > 0 {
        | true =>
          <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => vote()}>
            {"Vote"->React.string}
          </Button>
        | false => React.null
        }
      | _ => React.null
      }
    | None => React.null
    }
  }
}

module OpenVetoButton = {
  @react.component
  let make = (~accountOpt: option<AccountContext.t>, ~proposalID, ~proposalName) => {
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let openVeto = () => OpenVeto(proposalID, proposalName)->SubmitTx->OpenModal->dispatchModal

    switch accountOpt {
    | Some({address}) =>
      <Button
        variant={Outline}
        px=40
        py=10
        fsize=14
        style={CssHelper.flexBox()}
        onClick={_ => openVeto()}>
        {"Open Veto"->React.string}
      </Button>
    | None => React.null
    }
  }
}

module RenderData = {
  @react.component
  let make = (
    ~proposal: CouncilProposalSub.t,
    ~votes: array<CouncilVoteSub.t>,
    ~bondedToken: float,
  ) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (accountOpt, _) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

    <Section ptSm=16>
      <div className=CssHelper.container>
        <button
          className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
          onClick={_ => Route.redirect(ProposalPage)}>
          <Icon name="fa fa-angle-left" mr=8 size=16 />
          <Text
            value="Back to all proposals" size=Text.Xl weight=Text.Semibold color=theme.neutral_600
          />
        </button>
        <Row style=Styles.header>
          <Col col=Col.Twelve>
            <div className={CssHelper.flexBox()}>
              // TODO: seem like this Header reused in every detail page should created component for it
              <Heading size=Heading.H1 weight=Heading.Semibold>
                <span className=Styles.proposalId>
                  {`#P${proposal.id->ID.Proposal.toInt->Belt.Int.toString} `->React.string}
                </span>
                <span> {proposal.title->React.string} </span>
              </Heading>
              <HSpacing size=Spacing.sm />
              {isMobile ? React.null : <ProposalBadge status=proposal.status tooltip=true />}
            </div>
            {isMobile
              ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.badge})}>
                  <ProposalBadge status=proposal.status tooltip=true />
                </div>
              : React.null}
          </Col>
        </Row>
        <Row justify=Row.Between>
          <Col col=Col.Six>
            <Row>
              <Col col=Col.Four colSm=Col.Twelve mtSm=24>
                <Heading
                  value="Submit & Voting Starts"
                  size=Heading.H4
                  marginBottom=8
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={Some(proposal.submitTime)} color={theme.neutral_900}
                />
              </Col>
              <Col col=Col.Four colSm=Col.Twelve mtSm=24>
                <Heading
                  value="Voting Ends"
                  size=Heading.H4
                  marginBottom=8
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={Some(proposal.votingEndTime)} color={theme.neutral_900}
                />
              </Col>
              {switch proposal.vetoEndTime {
              | Some(vetoEndTime) =>
                <Col col=Col.Four colSm=Col.Twelve mtSm=24>
                  <Heading
                    value="Waiting for Veto Ends"
                    size=Heading.H4
                    marginBottom=8
                    weight=Heading.Semibold
                    color={theme.neutral_600}
                  />
                  <Timestamp
                    size=Text.Body1 timeOpt={proposal.vetoEndTime} color={theme.neutral_900}
                  />
                </Col>
              | None => React.null
              }}
            </Row>
          </Col>
          <Hidden variant={Mobile}>
            <Col col=Col.Two>
              {switch proposal.status {
              | VotingPeriod =>
                <VoteButton proposalID=proposal.id proposalName=proposal.title accountOpt />
              | WaitingVeto =>
                switch proposal.vetoProposalOpt {
                | Some(_) => React.null
                | None =>
                  <OpenVetoButton accountOpt proposalID=proposal.id proposalName=proposal.title />
                }
              | _ => React.null
              }}
            </Col>
          </Hidden>
        </Row>
        <SeperatedLine mt=32 mb=24 mtSm=24 mbSm=24 color=theme.neutral_200 />
        <Row marginBottom=24>
          <Col
            col={switch proposal.vetoProposalOpt {
            | Some(_) =>
              switch proposal.status {
              | WaitingVeto => Col.Seven
              | _ => Col.Six
              }
            | None => Col.Twelve
            }}>
            <VoteDetailsCard
              proposal
              votes
              variant={switch proposal.vetoProposalOpt {
              | Some(_) =>
                switch proposal.status {
                | WaitingVeto => Short
                | _ => Half
                }
              | None => Full
              }}
            />
          </Col>
          {switch proposal.vetoProposalOpt {
          | Some(vetoProposal) =>
            switch proposal.status {
            | WaitingVeto =>
              <Col col=Col.Five>
                {switch proposal.vetoProposalOpt {
                | Some({id, totalDeposit}) =>
                  <RejectDetailsCard.Wait
                    proposal
                    totalDeposit={totalDeposit
                    ->Belt.List.reduce(0., (acc, deposit) => acc +. deposit.amount)
                    ->Coin.newUBANDFromAmount}
                    vetoProposal
                  />

                | None => React.null
                }}
              </Col>
            | _ =>
              <Col col=Col.Six>
                <RejectDetailsCard.Vote vetoProposal status=proposal.status bondedToken />
              </Col>
            }

          | None => React.null
          }}
        </Row>
        <Hidden variant={Desktop}>
          <SeperatedLine mtSm=24 mbSm=24 color=theme.neutral_300 />
        </Hidden>
        <Row marginBottom=24>
          <Col col=Col.Twelve>
            <Heading
              value="Proposal Details"
              size=Heading.H4
              weight=Heading.Semibold
              color={theme.neutral_600}
              marginBottom=8
            />
          </Col>
          <Col col=Col.Twelve>
            <InfoContainer>
              <Row marginBottom=16 alignItems=Row.Center>
                <Col col=Col.Two colSm=Col.Four>
                  <Heading
                    value="Proposer" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Ten colSm=Col.Eight>
                  <AddressRender
                    address={proposal.account.address}
                    position=AddressRender.Subtitle
                    copy=true
                    ellipsis=isMobile
                  />
                </Col>
              </Row>
              <Row marginBottom=16 alignItems=Row.Center>
                <Col col=Col.Two colSm=Col.Four>
                  <Heading
                    value="Vote by" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Ten colSm=Col.Eight>
                  <div className={CssHelper.clickable} onClick={_ => openMembers()}>
                    <Text
                      value={proposal.council.name->Council.getCouncilNameString}
                      size=Text.Body1
                      weight=Text.Thin
                      color=theme.primary_600
                      spacing=Text.Em(0.05)
                      block=true
                    />
                  </div>
                </Col>
              </Row>
              <Row marginBottom=16 alignItems=Row.Center>
                <Col col=Col.Two colSm=Col.Four>
                  <Heading
                    value="Description"
                    size=Heading.H4
                    weight=Heading.Thin
                    color={theme.neutral_600}
                  />
                </Col>
                <Col col=Col.Ten colSm=Col.Eight>
                  // TODO: where is description in database?
                  <MarkDown value=proposal.metadata />
                </Col>
              </Row>
            </InfoContainer>
          </Col>
        </Row>
        <Row marginBottom=16>
          <Col>
            <Heading
              value={`Messages (${proposal.messages->Belt.List.length->Belt.Int.toString})`}
              size=Heading.H4
              weight=Heading.Semibold
              color={theme.neutral_600}
            />
          </Col>
        </Row>
        <Row marginBottom=24>
          <Col>
            <div className=Styles.msgContainer>
              {proposal.messages
              ->Belt.List.mapWithIndex((index, msg) => {
                let badge = msg.decoded->Msg.getBadge
                <MsgDetailCard key={index->Belt.Int.toString ++ badge.name} msg />
              })
              ->Array.of_list
              ->React.array}
            </div>
          </Col>
        </Row>
        <Hidden variant={Mobile}>
          <SeperatedLine mt=40 mb=40 color=theme.neutral_200 />
        </Hidden>
        <VoteBreakdownTable members=proposal.council.councilMembers votes />
      </div>
    </Section>
  }
}

@react.component
let make = (~proposalID) => {
  let proposalSub = CouncilProposalSub.get(proposalID)
  let councilVoteSub = CouncilVoteSub.get(proposalID)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  let allSub = Sub.all3(proposalSub, councilVoteSub, bondedTokenCountSub)
  switch allSub {
  | Data(proposal, votes, bondedToken) =>
    <RenderData proposal votes bondedToken={bondedToken->Coin.getUBandAmountFromCoin /. 1e6} />
  | Error(err) => <Heading value={err.message} />
  | Loading =>
    <div className=Styles.loadingContainer>
      <LoadingCensorBar.CircleSpin />
    </div>
  | NoData => <Heading value="NoData" />
  }
}
