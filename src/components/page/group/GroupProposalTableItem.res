module Styles = {
  open CssJs

  let tableItem = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_200),
      padding2(~v=px(16), ~h=#zero),
      selector("> div:first-child", [minWidth(#percent(10.)), textAlign(#center)]),
      selector("> div:nth-child(2)", [width(#percent(40.))]),
      selector("> div:nth-child(3)", [width(#percent(10.))]),
      selector("> div:nth-child(4)", [width(#percent(15.))]),
      selector("> div:nth-child(5)", [width(#percent(10.))]),
    ])

  let tableLink = (theme: Theme.t) =>
    style(. [
      cursor(pointer),
      selector("&:hover span", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])

  let tableItemMobile = style(. [marginBottom(#px(16))])
}

module TableItemMobile = {
  @react.component
  let make = () => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    <>
      <InfoContainer style={Styles.tableItemMobile}>
        <Row>
          <Col col=Col.Twelve>
            <TypeID.GroupProposalLink id={1->ID.GroupProposal.fromInt}>
              <div className={Css.merge(list{CssHelper.flexBox()})}>
                <TypeID.GroupProposal
                  id={1->ID.GroupProposal.fromInt}
                  position=TypeID.Subtitle
                  isNotLink=true
                  weight={Semibold}
                />
                <HSpacing size=Spacing.sm />
                <Heading
                  size=Heading.H4
                  value="Group Proposal Example"
                  weight=Heading.Semibold
                  color={theme.primary_600}
                />
              </div>
            </TypeID.GroupProposalLink>
          </Col>
        </Row>
        <Row marginTop={16}>
          <Col colSm=Col.Four>
            <Text value="Group" size={Body1} weight={Semibold} />
          </Col>
          <Col colSm=Col.Eight>
            <TypeID.GroupLink id={1->ID.Group.fromInt}>
              <div className={Css.merge(list{CssHelper.flexBox()})}>
                <TypeID.Group
                  id={1->ID.Group.fromInt} position=TypeID.Subtitle isNotLink=true weight={Semibold}
                />
                <HSpacing size=Spacing.sm />
                <Heading
                  size=Heading.H4
                  value="Group Example"
                  weight=Heading.Semibold
                  color={theme.primary_600}
                />
              </div>
            </TypeID.GroupLink>
          </Col>
        </Row>
        <Row marginTop={16}>
          <Col colSm=Col.Four>
            <Text value="Message" size={Body1} weight={Semibold} />
          </Col>
          <Col colSm=Col.Eight>
            <MsgBadge name="Message" />
          </Col>
        </Row>
        <Row marginTop={16}>
          <Col colSm=Col.Four>
            <Text value="Status" size={Body1} weight={Semibold} />
          </Col>
          <Col colSm=Col.Eight>
            <GroupProposalStatus
              value={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED->GroupProposalStatus.parseGroupProposalStatus}
              color={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED}
            />
          </Col>
        </Row>
      </InfoContainer>
    </>
  }
}

@react.component
let make = (~item) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <>
    {isMobile
      ? <TableItemMobile />
      : <div
          className={Css.merge(list{
            "table_item",
            CssHelper.flexBox(~align=#center, ~justify=#spaceBetween, ()),
            Styles.tableItem(theme),
          })}>
          <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
            // TODO: hardcode
            <TypeID.GroupProposal id={item->ID.GroupProposal.fromInt} size={Body1} weight={Bold} />
          </div>
          <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
            <Link
              className={Css.merge(list{Styles.tableLink(theme)})}
              route={OracleScriptDetailsPage(1, OracleScriptRequests)}>
              <Text
                // TODO: hardcode
                value="Group Proposal Example"
                ellipsis=true
                color={theme.primary_600}
                weight=Semibold
                size={Body1}
              />
            </Link>
          </div>
          <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
            //TODO: hardcode
            <MsgBadge name="Message" />
          </div>
          <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
            <TypeID.GroupLink id={1->ID.Group.fromInt}>
              <div className={Css.merge(list{CssHelper.flexBox()})}>
                <TypeID.Group
                  id={1->ID.Group.fromInt} position=TypeID.Subtitle isNotLink=true weight={Semibold}
                />
                <HSpacing size=Spacing.sm />
                <Heading
                  size=Heading.H4
                  value="Group Example"
                  weight=Heading.Semibold
                  color={theme.primary_600}
                />
              </div>
            </TypeID.GroupLink>
          </div>
          <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
            <GroupProposalStatus
              value={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED->GroupProposalStatus.parseGroupProposalStatus}
              color={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED}
            />
          </div>
        </div>}
  </>
}
