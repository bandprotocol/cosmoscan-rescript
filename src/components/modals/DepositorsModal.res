module Styles = {
  open CssJs
  let container = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.neutral_000),
      width(#percent(100.)),
      minWidth(#px(568)),
      minHeight(#px(360)),
      padding2(~v=#px(40), ~h=#px(16)),
      Media.mobile([minWidth(#px(300))]),
    ])

  let memberCard = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      padding2(~v=#px(4), ~h=#px(8)),
      borderRadius(#px(4)),
      marginTop(#px(8)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      border(#px(1), #solid, theme.neutral_100),
      Media.mobile([padding2(~v=#px(16), ~h=#px(16))]),
    ])

  let description = style(. [marginBottom(#px(24)), Media.mobile([marginBottom(#px(0))])])
}
module RenderBody = {
  @react.component
  let make = (~deposits: array<DepositSub.t>) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <TBody paddingV=#px(12)>
      {deposits
      ->Belt.Array.mapWithIndex((index, deposit) => <>
        <Row alignItems=Row.Center key={deposit.depositor->Address.toBech32}>
          <Col col=Col.One>
            <Text value={(index + 1)->Belt.Int.toString} size=Text.Body1 weight=Text.Thin />
          </Col>
          <Col col=Col.Three>
            <AddressRender
              address=deposit.depositor position=AddressRender.Subtitle ellipsis=true
            />
          </Col>
          <Col col=Col.Two>
            {switch deposit.txHashOpt {
            | Some(txHash) => <TxLink txHash width=280 fullHash=false ellipsisLimit=10 />
            // TODO: Handle Null Txhash for deposit
            | None => <Text value="No Tx" size=Text.Body1 weight=Text.Thin />
            }}
          </Col>
          <Col col=Col.Three>
            <Text
              value={deposit.amount->Coin.getBandAmountFromCoins->Format.fPretty(~digits=0)}
              size=Text.Body1
              weight=Text.Thin
              align={Right}
              code=true
            />
          </Col>
          <Col col=Col.Three style={CssHelper.flexBox(~justify=#end_, ())}>
            <Timestamp
              timeOpt=deposit.timestampOpt size=Text.Body2 weight=Text.Regular textAlign=Text.Right
            />
          </Col>
        </Row>
        <SeperatedLine mt=12 mb=12 color=theme.neutral_100 />
      </>)
      ->React.array}
    </TBody>
  }
}
module RenderBodyMobile = {
  @react.component
  let make = (~deposits: array<DepositSub.t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    deposits
    ->Belt.Array.mapWithIndex((index, deposit) =>
      <div className={Styles.memberCard(theme, isDarkMode)}>
        <Row>
          <Col colSm=Col.Three>
            <Text block=true value="No." size=Text.Caption weight=Text.Semibold />
          </Col>
          <Col colSm=Col.Nine>
            <Text
              block=true
              value={(index + 1)->Belt.Int.toString}
              size=Text.Caption
              weight=Text.Semibold
            />
          </Col>
        </Row>
        <Row marginTopSm=16>
          <Col colSm=Col.Three>
            <Text block=true value="ADDRESS" size=Text.Caption weight=Text.Semibold />
          </Col>
          <Col colSm=Col.Nine>
            <AddressRender address=deposit.depositor position={Subtitle} ellipsis=true />
          </Col>
        </Row>
        <Row marginTopSm=16>
          <Col colSm=Col.Three>
            <Text block=true value="TX HASH" size=Text.Caption weight=Text.Semibold />
          </Col>
          <Col colSm=Col.Nine>
            {switch deposit.txHashOpt {
            | Some(txHash) => <TxLink txHash width=280 fullHash=false />
            // TODO: Handle Null Txhash for deposit
            | None => <Text value="No Tx" size=Text.Body1 weight=Text.Thin />
            }}
          </Col>
        </Row>
        <Row marginTopSm=16>
          <Col colSm=Col.Three>
            <Text block=true value="Timestamp" size=Text.Caption weight=Text.Semibold />
          </Col>
          <Col colSm=Col.Nine>
            <Timestamp
              timeOpt=deposit.timestampOpt size=Text.Body2 weight=Text.Regular textAlign=Text.Right
            />
          </Col>
        </Row>
      </div>
    )
    ->React.array
  }
}

@react.component
let make = (~vetoId: int) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()
  // TODO: add pagination
  let depositsSub = DepositSub.getList(vetoId->ID.LegacyProposal.fromInt, ~pageSize=10, ~page=1, ())

  <div className={Styles.container(theme)}>
    <Heading size=Heading.H2 value="Depositors" marginBottom=16 marginBottomSm=8 />
    <SeperatedLine mt=0 mb=0 color=theme.neutral_100 />
    {switch depositsSub {
    | Data(deposits) =>
      switch isMobile {
      | true => <RenderBodyMobile deposits />
      | false =>
        <>
          <Row alignItems=Row.Center marginTop=12 marginBottom=12>
            <Col col=Col.One>
              <Text value="No." size=Text.Caption weight=Text.Semibold />
            </Col>
            <Col col=Col.Three>
              <Text value="DEPOSITORS" size=Text.Caption weight=Text.Semibold />
            </Col>
            <Col col=Col.Two>
              <Text value="TX HASH" size=Text.Caption weight=Text.Semibold />
            </Col>
            <Col col=Col.Three>
              <Text
                value="DEPOSIT AMOUNT (BAND)"
                size=Text.Caption
                weight=Text.Semibold
                align=Text.Right
              />
            </Col>
            <Col col=Col.Three>
              <Text value="TIMESTAMP" size=Text.Caption weight=Text.Semibold align=Text.Right />
            </Col>
          </Row>
          <RenderBody deposits />
        </>
      }
    // TODO: insert Loader
    | Error(err) =>
      <Text value={err.message} color={theme.error_600} align=Text.Center breakAll=true />
    | Loading | NoData =>
      <Text value="Loading" color={theme.error_600} align=Text.Center breakAll=true />
    }}
  </div>
}
