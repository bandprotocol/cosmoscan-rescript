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
  let make = (~votes: array<VoteSub.t>) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <TBody paddingV=#px(12)>
      {votes
      ->Belt.Array.mapWithIndex((index, vote) => <>
        <Row alignItems=Row.Center key={vote.voter->Address.toBech32}>
          <Col col=Col.Four>
            <AddressRender address=vote.voter position=AddressRender.Subtitle ellipsis=true />
          </Col>
          <Col col=Col.Five>
            {switch vote.txHashOpt {
            | Some(txHash) => <TxLink txHash width=280 fullHash=false ellipsisLimit=10 />
            // TODO: Handle Null Txhash for deposit
            | None => <Text value="No Tx" size=Text.Body1 weight=Text.Thin />
            }}
          </Col>
          <Col col=Col.Three style={CssHelper.flexBox(~justify=#end_, ())}>
            <Timestamp
              timeOpt=vote.timestampOpt size=Text.Body2 weight=Text.Regular textAlign=Text.Right
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
  let make = (~votes: array<VoteSub.t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    votes
    ->Belt.Array.mapWithIndex((index, vote) =>
      <div className={Styles.memberCard(theme, isDarkMode)}>
        <Row marginTopSm=16>
          <Col colSm=Col.Three>
            <Text block=true value="ADDRESS" size=Text.Caption weight=Text.Semibold />
          </Col>
          <Col colSm=Col.Nine>
            <AddressRender address=vote.voter position={Subtitle} ellipsis=true />
          </Col>
        </Row>
        <Row marginTopSm=16>
          <Col colSm=Col.Three>
            <Text block=true value="TX HASH" size=Text.Caption weight=Text.Semibold />
          </Col>
          <Col colSm=Col.Nine>
            {switch vote.txHashOpt {
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
              timeOpt=vote.timestampOpt size=Text.Body2 weight=Text.Regular textAlign=Text.Right
            />
          </Col>
        </Row>
      </div>
    )
    ->React.array
  }
}

@react.component
let make = (~vetoId) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()
  // TODO: add pagination
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5
  let votesSubAll = VoteSub.getListAll(vetoId, ~pageSize, ~page, ())

  <div className={Styles.container(theme)}>
    <Heading size=Heading.H2 value="Veto Votes" marginBottom=16 marginBottomSm=8 />
    <SeperatedLine mt=0 mb=0 color=theme.neutral_100 />
    {switch votesSubAll {
    | Data(votes) =>
      switch isMobile {
      | true => <RenderBodyMobile votes />
      | false =>
        <>
          <Row alignItems=Row.Center marginTop=12 marginBottom=12>
            <Col col=Col.Four>
              <Text value="Voter" size=Text.Caption weight=Text.Semibold />
            </Col>
            <Col col=Col.Five>
              <Text value="TX HASH" size=Text.Caption weight=Text.Semibold />
            </Col>
            <Col col=Col.Three>
              <Text value="TIMESTAMP" size=Text.Caption weight=Text.Semibold align=Text.Right />
            </Col>
          </Row>
          <RenderBody votes />
        </>
      }
    | Error(err) =>
      <Text value={err.message} color={theme.error_600} align=Text.Center breakAll=true />
    | Loading | NoData => <LoadingCensorBar width=153 height=30 />
    }}
  </div>
}
