@react.component
let make = () => {
  let pageSize = 10
  let proposalsSub = ProposalSub.getList(~pageSize, ~page=1, ())

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          <Heading value="All Proposals" size=Heading.H2 />
        </Col>
      </Row>
      <Row>
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
                <img alt="No Proposal" src={isDarkMode ? Images.noTxDark : Images.noTxLight} />
                <Heading
                  size=Heading.H4
                  value="No Proposal"
                  align=Heading.Center
                  weight=Heading.Regular
                  color={theme.textSecondary}
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
