@react.component
let make = () => {
  let (page, _) = React.useState(_ => 1)
  let pageSize = 10

  let txsSub = TxSub.getList(~pageSize, ~page)

  let latestTxsSub = TxSub.getList(~pageSize=1, ~page=1)
  let isMobile = Media.isMobile()

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <Section ptSm=32 pbSm=32>
    <div className=CssHelper.container id="transactionsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          <Heading value="All Transactions" size=Heading.H2 marginBottom=16 marginBottomSm=8 />
          {switch latestTxsSub {
          | Data(txs) =>
            <Heading
              value={txs
              ->Belt.Array.get(0)
              ->Belt.Option.mapWithDefault(0, ({id}) => id)
              ->Format.iPretty ++ " In total"}
              size=Heading.H3
              weight=Heading.Thin
              color=theme.neutral_600
            />
          | _ => <LoadingCensorBar width=65 height=21 />
          }}
        </Col>
      </Row>
      <InfoContainer>
        <Table>
          {isMobile
            ? React.null
            : <THead>
                <Row alignItems=Row.Center>
                  <Col col=Col.Three>
                    <Text
                      block=true
                      value="TX Hash"
                      weight=Text.Semibold
                      transform=Text.Uppercase
                      size=Text.Caption
                    />
                  </Col>
                  <Col col=Col.One>
                    <Text
                      block=true
                      value="Block"
                      weight=Text.Semibold
                      transform=Text.Uppercase
                      size=Text.Caption
                    />
                  </Col>
                  <Col col=Col.One>
                    <Text
                      block=true
                      value="Status"
                      weight=Text.Semibold
                      transform=Text.Uppercase
                      size=Text.Caption
                      align=Text.Center
                    />
                  </Col>
                  <Col col=Col.Two>
                    <Text
                      block=true
                      value="Gas Fee (BAND)"
                      weight=Text.Semibold
                      transform=Text.Uppercase
                      size=Text.Caption
                    />
                  </Col>
                  <Col col=Col.Five>
                    <Text
                      block=true
                      value="Actions"
                      weight=Text.Semibold
                      transform=Text.Uppercase
                      size=Text.Caption
                    />
                  </Col>
                </Row>
              </THead>}
          <TxsTable txsSub />
        </Table>
      </InfoContainer>
    </div>
  </Section>
}
