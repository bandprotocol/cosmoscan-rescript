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
  let make = (~members: array<CouncilProposalSub.council_member_t>) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <TBody paddingV=#px(12)>
      {members
      ->Belt.Array.mapWithIndex((index, member) => <>
        <Row alignItems=Row.Center key={member.account.address->Address.toBech32}>
          <Col col=Col.One>
            <Text value={(index + 1)->Belt.Int.toString} size=Text.Body1 weight=Text.Thin />
          </Col>
          <Col col=Col.Six>
            <AddressRender
              address=member.account.address position=AddressRender.Subtitle ellipsis=true
            />
          </Col>
          <Col col=Col.Five>
            <Text
              value={`${member.since->MomentRe.Moment.format(
                  "YYYY-MM-DD",
                  _,
                )} (${member.since->MomentRe.Moment.fromNow(~withoutSuffix=Some(true))})`}
              size=Text.Body1
              weight=Text.Thin
              align=Text.Right
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
  let make = (~name: string, ~members: array<CouncilProposalSub.council_member_t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    members
    ->Belt.Array.mapWithIndex((index, member) =>
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
            <AddressRender address=member.account.address position={Subtitle} ellipsis=true />
          </Col>
        </Row>
        <Row marginTopSm=16>
          <Col colSm=Col.Three>
            <Text block=true value="SINCE" size=Text.Caption weight=Text.Semibold />
          </Col>
          <Col colSm=Col.Nine>
            <Text
              block=true
              value={`${member.since->MomentRe.Moment.format(
                  "YYYY-MM-DD",
                  _,
                )} (${member.since->MomentRe.Moment.fromNow(~withoutSuffix=Some(true))})`}
              size=Text.Caption
              weight=Text.Semibold
            />
          </Col>
        </Row>
      </div>
    )
    ->React.array
  }
}

@react.component
let make = (~council: CouncilProposalSub.council_t) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <div className={Styles.container(theme)}>
    <Heading
      size=Heading.H2
      value={council.name->CouncilSub.getCouncilNameString ++ " Members"}
      marginBottom=8
      marginBottomSm=8
    />
    <div className={Css.merge(list{CssHelper.flexBox(), Styles.description})}>
      <Text value={council.name->CouncilSub.getCouncilNameString ++ " Address"} size=Text.Body1 />
      <HSpacing size=Spacing.sm />
      <AddressRender
        address=council.account.address position=AddressRender.Subtitle copy=true ellipsis=true
      />
    </div>
    {switch isMobile {
    | true =>
      <RenderBodyMobile
        name={council.name->CouncilSub.getCouncilNameString} members=council.councilMembers
      />
    | false =>
      <>
        <THead height=30>
          <Row alignItems=Row.Center>
            <Col col=Col.One>
              <Text value="#" size=Text.Caption weight=Text.Semibold />
            </Col>
            <Col col=Col.Six>
              <Text
                value={council.name->CouncilSub.getCouncilNameString ++ " Members"}
                size=Text.Caption
                weight=Text.Semibold
                transform={Uppercase}
              />
            </Col>
            <Col col=Col.Five>
              <Text value="SINCE" size=Text.Caption weight=Text.Semibold align=Text.Right />
            </Col>
          </Row>
        </THead>
        <RenderBody members=council.councilMembers />
      </>
    }}
  </div>
}
