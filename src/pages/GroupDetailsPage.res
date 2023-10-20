module Styles = {
  open CssJs
  let titleSpacing = style(. [marginBottom(#px(4))])
  let idCointainer = style(. [marginBottom(#px(16))])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let noPadding = style(. [padding(#zero)])
  let groupID = style(. [
    fontFamilies([#custom("Roboto Mono"), #monospace]),
    marginRight(#px(8)),
    Media.mobile([display(#block)]),
  ])

  let buttonStyled = style(. [
    backgroundColor(#transparent),
    border(#zero, #solid, #transparent),
    outlineStyle(#none),
    cursor(#pointer),
    padding2(~v=#zero, ~h=#zero),
    margin4(~top=#zero, ~right=#zero, ~bottom=#px(40), ~left=#zero),
  ])

  let relatedDSContainer = style(. [
    selector("> div + div", [marginTop(#px(16))]),
    selector("> div > a", [marginRight(#px(8))]),
  ])
}

module Content = {
  @react.component
  let make = (~group: Group.t, ~hashtag) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let mock = MockGroup.mock

    <Section>
      <div className=CssHelper.container>
        <button
          className={Css.merge(list{CssHelper.flexBox(), Styles.buttonStyled})}
          onClick={_ => Route.redirect(GroupPage(Proposal))}>
          <Icon name="fa fa-angle-left" mr=8 size=16 />
          <Text
            value="Back to group module" size=Text.Xl weight=Text.Semibold color=theme.neutral_600
          />
        </button>
        <Row marginBottom=24 marginBottomSm=24 marginLeft=0 alignItems=Row.Center>
          <div className={Css.merge(list{CssHelper.flexBox(), Styles.idCointainer})}>
            <Heading size=Heading.H1 weight=Heading.Bold style={CssHelper.flexBox()}>
              <span className=Styles.groupID>
                {`#G${mock.id->ID.Group.toInt->Belt.Int.toString} `->React.string}
              </span>
              // TODO: extract group name from meta data
              <span> {group.name->React.string} </span>
            </Heading>
          </div>
        </Row>
        <InfoContainer>
          <Table>
            <Tab.Route
              tabs=[
                {
                  name: `Proposal (${group.proposalsCount->Belt.Int.toString})`,
                  route: group.id->ID.Group.getRouteWithTab(Route.GroupProposal),
                },
                {
                  name: `Policy (${group.policiesCount->Belt.Int.toString})`,
                  route: group.id->ID.Group.getRouteWithTab(Route.GroupPolicy),
                },
                {
                  name: `Members (${group.memberCount->Belt.Int.toString})`,
                  route: group.id->ID.Group.getRouteWithTab(Route.GroupMember),
                },
                {
                  name: "Information",
                  route: group.id->ID.Group.getRouteWithTab(Route.GroupInformation),
                },
              ]
              currentRoute={group.id->ID.Group.getRouteWithTab(hashtag)}>
              {switch hashtag {
              | GroupProposal => <GroupDetailsTabs.Proposal groupID=group.id />
              | GroupPolicy => <GroupDetailsTabs.Policy groupID=group.id />
              | GroupMember => <GroupDetailsTabs.Members groupID=group.id />
              | GroupInformation => <GroupDetailsTabs.Information group />
              }}
            </Tab.Route>
          </Table>
        </InfoContainer>
      </div>
    </Section>
  }
}

@react.component
let make = (~groupID, ~hashtag) => {
  let groupSub = GroupSub.get(groupID)

  switch groupSub {
  | Data(group) => <Content group hashtag />
  | NoData => <Text value="NoData" />
  | Error(_) => <Text value="Error" />
  | Loading => <Text value="Loading" />
  }
}
