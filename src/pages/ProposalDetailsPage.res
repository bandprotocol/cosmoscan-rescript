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
}

module VoteButton = {
  @react.component
  let make = (~proposalID) => {
    let trackingSub = TrackingSub.use()

    let (accountOpt, _) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let connect = chainID => dispatchModal(OpenModal(Connect(chainID)))

    let vote = () => Webapi.Dom.window->Webapi.Dom.Window.alert("vote")

    switch accountOpt {
    | Some(_) =>
      <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => vote()}>
        {"Vote"->React.string}
      </Button>
    | None =>
      switch trackingSub {
      | Data({chainID}) =>
        <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => connect(chainID)}>
          {"Vote"->React.string}
        </Button>
      | Error(err) =>
        // log for err details
        Js.Console.log(err)
        <Text value="chain id not found" />
      | _ => <LoadingCensorBar width=90 height=26 />
      }
    }
  }
}

module RenderData = {
  @react.component
  let make = (~proposal: CouncilProposalSub.t) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <Section>
      <div className=CssHelper.container>
        <button
          className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
          onClick={_ => Route.redirect(OracleScriptPage)}>
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
                // TODO: change dis wen title ready
                value="Activate the community pool"
                color={theme.neutral_900}
                weight=Heading.Semibold
              />
              <HSpacing size=Spacing.sm />
              {isMobile ? React.null : <CouncilProposalBadge status=proposal.status />}
            </div>
            {isMobile
              ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.badge})}>
                  <CouncilProposalBadge status=proposal.status />
                </div>
              : React.null}
          </Col>
        </Row>
        <Row justify=Row.Between>
          <Col col=Col.Four>
            <Row>
              <Col col=Col.Six>
                <Heading
                  value="Submit & Voting Starts"
                  size=Heading.H5
                  marginBottom=8
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={Some(proposal.votingEndTime)} color={theme.neutral_900}
                />
              </Col>
              <Col col=Col.Six>
                <Heading
                  value="Voting Ends"
                  size=Heading.H5
                  marginBottom=8
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                <Timestamp
                  size=Text.Body1 timeOpt={Some(proposal.votingEndTime)} color={theme.neutral_900}
                />
              </Col>
            </Row>
          </Col>
          <Col col=Col.Two>
            <VoteButton proposalID=proposal.id />
          </Col>
        </Row>
      </div>
    </Section>
  }
}

@react.component
let make = (~proposalID) => {
  let proposalSub = CouncilProposalSub.get(proposalID)
  // let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(proposalID)
  // let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  // let allSub = Sub.all3(proposalSub, voteStatByProposalIDSub, bondedTokenCountSub)
  switch proposalSub {
  | Data(proposal) => <RenderData proposal />
  | Error(err) => <Heading value={err.message} />
  | Loading => <Heading value="Loading" />
  | NoData => <Heading value="NoData" />
  }
}
