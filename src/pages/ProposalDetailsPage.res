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

  let buttonStyled = style(. [
    backgroundColor(#transparent),
    border(#zero, #solid, #transparent),
    outlineStyle(#none),
    cursor(#pointer),
    padding2(~v=#zero, ~h=#zero),
    margin4(~top=#zero, ~right=#zero, ~bottom=#px(40), ~left=#zero),
  ])

  let badge = style(. [marginTop(#px(8))])
  let header = style(. [marginBottom(#px(24))])
  let msgContainer = style(. [selector("> div + div", [marginTop(#px(24))])])
}

module VoteButton = {
  @react.component
  let make = (~proposalID, ~address) => {
    let vote = () => Webapi.Dom.window->Webapi.Dom.Window.alert("vote")
    let accountQuery = AccountQuery.get(address)

    switch accountQuery {
    | Data({councilOpt}) =>
      switch councilOpt {
      | Some(council) =>
        <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => vote()}>
          {"Vote"->React.string}
        </Button>
      | None => React.null
      }
    | _ => React.null
    }
  }
}

module OpenVetoButton = {
  @react.component
  let make = (~proposalID, ~address) => {
    let vote = () => Webapi.Dom.window->Webapi.Dom.Window.alert("vote")
    let accountQuery = AccountQuery.get(address)

    switch accountQuery {
    | Data({councilOpt}) =>
      switch councilOpt {
      | Some(council) =>
        <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => vote()}>
          {"Vote"->React.string}
        </Button>
      | None => React.null
      }
    | _ => React.null
    }
  }
}

module RenderData = {
  @react.component
  let make = (~proposal: CouncilProposalSub.t, ~votes: array<CouncilVoteSub.t>) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (accountOpt, _) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openMembers = () => proposal.council->CouncilMembers->OpenModal->dispatchModal
    let openVeto = () => proposal.council->CouncilMembers->OpenModal->dispatchModal

    <Section>
      <div className=CssHelper.container>
        <button
          className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
          onClick={_ => Route.redirect(ProposalPage)}>
          <Icon name="fa fa-angle-left" mr=8 size=16 />
          <Text value="Back to all proposals" size=Text.Xl color=theme.neutral_600 />
        </button>
        <Row style=Styles.header>
          <Col col=Col.Twelve>
            <div className={CssHelper.flexBox()}>
              <TypeID.Proposal
                id={proposal.id}
                position=TypeID.Title
                size=Text.Xxxxl
                weight=Text.Bold
                color={theme.neutral_900}
                isNotLink=true
              />
              <HSpacing size=Spacing.sm />
              <Heading
                size=Heading.H1
                value=proposal.title
                color={theme.neutral_900}
                weight=Heading.Semibold
              />
              <HSpacing size=Spacing.sm />
              {isMobile ? React.null : <ProposalBadge status=proposal.status />}
            </div>
            {isMobile
              ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.badge})}>
                  <ProposalBadge status=proposal.status />
                </div>
              : React.null}
          </Col>
        </Row>
        <Row justify=Row.Between>
          <Col col=Col.Six>
            <Row>
              <Col col=Col.Four>
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
              <Col col=Col.Four>
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
                <Col col=Col.Four>
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
          {switch accountOpt {
          | Some({address}) =>
            <Col col=Col.Two>
              {switch proposal.status {
              | VotingPeriod => <VoteButton proposalID=proposal.id address />
              | _ =>
                <Button
                  variant={Outline}
                  px=40
                  py=10
                  fsize=14
                  style={CssHelper.flexBox()}
                  onClick={_ => openVeto()}>
                  {"Open Veto"->React.string}
                </Button>
              // | _ => React.null
              }}
            </Col>
          | None => React.null
          }}
        </Row>
        <SeperatedLine mt=32 mb=24 color=theme.neutral_200 />
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
                <RejectDetailsCard.Wait vetoProposal />
              </Col>
            | _ =>
              <Col col=Col.Six>
                <RejectDetailsCard.Vote vetoProposal />
              </Col>
            }

          | None => React.null
          }}
        </Row>
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
                      value={proposal.council.name->CouncilSub.getCouncilNameString}
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
        <SeperatedLine mt=40 mb=40 color=theme.neutral_200 />
        <VoteBreakdownTable members=proposal.council.councilMembers votes />
      </div>
    </Section>
  }
}

@react.component
let make = (~proposalID) => {
  let proposalSub = CouncilProposalSub.get(proposalID)
  let councilVoteSub = CouncilVoteSub.get(proposalID)
  // let depositsSub = DepositSub.getList(proposalID, ~pageSize, ~page, ())

  let allSub = Sub.all2(proposalSub, councilVoteSub)
  // let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(proposalID)
  // let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  // let allSub = Sub.all3(proposalSub, voteStatByProposalIDSub, bondedTokenCountSub)
  switch allSub {
  | Data(proposal, votes) => <RenderData proposal votes />
  | Error(err) => <Heading value={err.message} />
  | Loading => <Heading value="Loading" />
  | NoData => <Heading value="NoData" />
  }
}
