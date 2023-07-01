module Styles = {
  open CssJs
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
}

module ProposalCard = {
  @react.component
  let make = (~reserveIndex, ~proposalSub: Sub.variant<ProposalSub.t>) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <Col key={reserveIndex->Belt.Int.toString} style=Styles.proposalCardContainer mb=24 mbSm=16>
      <InfoContainer>
        <Row>
          <Col col=Col.Twelve>
            <div className={CssHelper.flexBox()}>
              <TypeID.Proposal id={1->ID.Proposal.fromInt} position=TypeID.Title />
              <Heading
                size=Heading.H3
                value="Activate the community pool"
                color={theme.neutral_900}
                weight=Heading.Semibold
              />
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
          </Col>
          <Col col=Col.Four>
            <Heading
              value="Voting End"
              size=Heading.H5
              marginBottom=8
              weight=Heading.Thin
              color={theme.neutral_600}
            />
            <Text
              value="2023-04-25 06:29:18 +UTC"
              size=Text.Body1
              weight=Text.Thin
              color=theme.neutral_900
              spacing=Text.Em(0.05)
              block=true
              code=true
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
                value="80.94%"
                size=Text.Body1
                weight=Text.Thin
                color=theme.neutral_900
                spacing=Text.Em(0.05)
                block=true
                code=true
              />
              <HSpacing size=Spacing.sm />
              <ProgressBar.Voting2
                slots={ProgressBar.Slot.getYesNoSlot(theme, ~yes=1123., ~no=100.)}
              />
            </div>
          </Col>
          <Col col=Col.One>
            <Heading
              value="Veto"
              size=Heading.H5
              marginBottom=8
              weight=Heading.Thin
              color={theme.neutral_600}
            />
          </Col>
        </Row>
      </InfoContainer>
    </Col>
  }
}

@react.component
let make = () => {
  let pageSize = 10
  let proposalsSub = ProposalSub.getList(~pageSize, ~page=1, ())
  let councilProposalSub = CouncilProposalSub.get(1)
  let councilVoteSub = CouncilVoteSub.get(1)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          <Heading value="All Proposals" size=Heading.H2 />
        </Col>
      </Row>
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          {switch councilVoteSub {
          | Data(data) => <h1> {data->Js.Json.stringifyAny->Belt.Option.getExn->React.string} </h1>
          | Error(err) => <h1> {err.message->React.string} </h1>
          | _ => <h1> {"null"->React.string} </h1>
          }}
        </Col>
      </Row>
      <Row style={CssHelper.flexBox(~justify=#center, ())}>
        {switch proposalsSub {
        | Data(proposals) =>
          proposals->Belt.Array.size > 0
            ? proposals
              ->Belt.Array.mapWithIndex((i, proposal) => {
                <ProposalCard
                  key={i->Belt.Int.toString} reserveIndex=i proposalSub={Sub.resolve(proposal)}
                />
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
          ->Belt.Array.mapWithIndex((i, noData) =>
            <ProposalCard key={i->Belt.Int.toString} reserveIndex=i proposalSub=noData />
          )
          ->React.array
        }}
      </Row>
    </div>
  </Section>
}
