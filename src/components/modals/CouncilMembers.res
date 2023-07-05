module Styles = {
  open CssJs
  let container = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.neutral_000),
      width(#percent(100.)),
      minWidth(#px(568)),
      minHeight(#px(360)),
      padding(#px(32)),
      Media.mobile([minWidth(#px(300))]),
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
    members
    ->Belt.Array.mapWithIndex((index, member) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("#", Text(index->Belt.Int.toString)),
            ("ADDRESS", Address(member.account.address, 200, #account)),
            (
              "SINCE",
              Text(
                `${member.since->MomentRe.Moment.format(
                    "YYYY-MM-DD",
                    _,
                  )} (${member.since->MomentRe.Moment.fromNow(~withoutSuffix=Some(true))})`,
              ),
            ),
          ]
        }
        key={member.account.address->Address.toBech32}
        idx={member.account.address->Address.toBech32}
      />
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
    {isMobile
      ? <>
          <RenderBodyMobile
            name={council.name->CouncilSub.getCouncilNameString} members=council.councilMembers
          />
        </>
      : <>
          <THead height=30>
            <Row alignItems=Row.Center>
              <Col col=Col.One>
                <Text value="#" size=Text.Caption weight=Text.Semibold />
              </Col>
              <Col col=Col.Six>
                <Text value="TECH COUNCIL MEMBERS" size=Text.Caption weight=Text.Semibold />
              </Col>
              <Col col=Col.Five>
                <Text value="SINCE" size=Text.Caption weight=Text.Semibold align=Text.Right />
              </Col>
            </Row>
          </THead>
          <RenderBody members=council.councilMembers />
        </>}
  </div>
}
