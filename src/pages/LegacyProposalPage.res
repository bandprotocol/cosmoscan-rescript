module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let chipContainer = style(. [marginTop(#px(16))])
  let chip = style(. [borderRadius(#px(20)), marginRight(#px(8)), marginTop(#px(8))])
  let badge = style(. [marginTop(#px(8))])
}

@react.component
let make = () => {
  let pageSize = 10
  let (filterStr, setFilterStr) = React.useState(_ => "All")

  let proposalsSub = ProposalSub.getList(~pageSize, ~page=1, ())
  let proposalCount = ProposalSub.count()

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Section>
    <div className=CssHelper.container id="proposalsSection">
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
                <LegacyProposalCard key={i->Belt.Int.toString} reserveIndex=i proposal />
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
