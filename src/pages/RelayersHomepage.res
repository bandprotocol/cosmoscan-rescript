module Styles = {
  open CssJs
  let withWidth = (w, theme: Theme.t, fullHash) =>
    style(. [
      display(fullHash ? #flex : #inlineBlock),
      maxWidth(px(w)),
      cursor(pointer),
      selector("> span:hover", [color(theme.primary_600)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])

  let relayerItem = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      border(#px(1), solid, isDarkMode ? theme.neutral_200 : theme.neutral_100),
      boxShadow(
        Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), ~spread=#px(1), rgba(16, 18, 20, #num(0.15))),
      ),
      borderRadius(#px(10)),
      marginBottom(#px(24)),
    ])

  let relayerTitleWrapper = (theme: Theme.t, isDarkMode) => style(. [padding(#px(24))])
  let chainLogo = style(. [width(#px(24)), height(#px(24)), objectFit(#cover)])
  let relayerDetailsWrapper = (theme: Theme.t, isDarkMode) =>
    style(. [padding2(~v=#px(24), ~h=#px(24))])
}

module RelayerCard = {
  @react.component
  let make = (~chainID: IBCFilterSub.filter_counterparty_t, ()) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.relayerItem(theme, isDarkMode)}>
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~justify=#flexStart, ~align=#center, ()),
          Styles.relayerTitleWrapper(theme, isDarkMode),
        })}>
        <Avatar moniker={chainID.chainID} identity={chainID.chainID} width=40 />
        <HSpacing size=Spacing.lg />
        <Heading size={H3} value={chainID.chainID} weight={Semibold} />
      </div>
      <div className={Styles.relayerDetailsWrapper(theme, isDarkMode)}>
        <LiveConnection counterpartyChainID={chainID.chainID} />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let chainIDFilterSub = IBCFilterSub.getChainFilterList()

  <Section ptSm=32 pbSm=32>
    <div className=CssHelper.container id="ibcSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          <Heading value="IBC Relayers" size=Heading.H2 marginBottom=16 marginBottomSm=8 />
          <Text
            size=Text.Body1
            value="Acts as a bridge, forwarding transactions and messages between networks and ensuring the proper format and adherence to IBC protocols."
          />
          <div className={Css.merge(list{CssHelper.flexBox()})}>
            <Text size=Text.Body1 value="View" />
            <HSpacing size=Spacing.sm />
            <Link route=Route.IBCTxPage className="">
              <Text
                size=Text.Body1
                weight=Text.Semibold
                value="IBC Transactions"
                color={theme.primary_600}
              />
            </Link>
          </div>
        </Col>
      </Row>
      <Row>
        <Col col=Col.Twelve>
          {switch chainIDFilterSub {
          | Data(chainIDList) =>
            <div>
              {Belt.Array.mapWithIndex(chainIDList, (i, chainID) => {
                <RelayerCard chainID key={i->Belt.Int.toString} />
              })->React.array}
            </div>

          | _ => <LoadingCensorBar width=285 height=37 radius=8 />
          }}
        </Col>
      </Row>
    </div>
  </Section>
}
