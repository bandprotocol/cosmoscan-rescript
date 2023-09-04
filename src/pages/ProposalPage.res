module Styles = {
  open CssJs

  let descriptionHeader = (theme: Theme.t) =>
    style(. [
      fontSize(#px(14)),
      fontWeight(#num(400)),
      color(theme.neutral_600),
      selector("> a", [color(theme.primary_600)]),
    ])

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let chipContainer = style(. [marginTop(#px(16))])
  let chip = style(. [borderRadius(#px(20)), marginRight(#px(8)), marginTop(#px(8))])
}

@react.component
let make = () => {
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 10
  let (filterStr, setFilterStr) = React.useState(_ => "All")

  let councilProposalSub = CouncilProposalSub.getList(~filter=filterStr, ~pageSize, ~page, ())
  let councilProposalCount = CouncilProposalSub.count(~filter=filterStr)
  let proposalCount = ProposalSub.count()

  let isMobile = Media.isMobile()

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
      {switch isMobile {
      | false =>
        switch councilProposalCount {
        | Data(count) => {
            let pageCount = Page.getPageCount(count, pageSize)

            {
              switch count > pageSize {
              | true =>
                <Pagination
                  currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)}
                />
              | false => React.null
              }
            }
          }

        | _ => React.null
        }
      | true => React.null
      }}
    </div>
  </Section>
}
