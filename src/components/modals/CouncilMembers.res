module Styles = {
  open CssJs
  let container = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.neutral_000),
      width(#percent(100.)),
      minWidth(#px(568)),
      minHeight(#px(360)),
      padding(#px(32)),
    ])

  let description = style(. [marginBottom(#px(24))])
}

@react.component
let make = (~council: CouncilProposalSub.council_t) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

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
    <TBody paddingV=#px(12)>
      {council.councilMembers
      ->Belt.Array.mapWithIndex((index, member) => <>
        <Row alignItems=Row.Center>
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
              value={member.since->MomentRe.Moment.fromNow(~withoutSuffix=None)}
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
  </div>
}
