module Styles = {
  open CssJs
  let titleSpacing = style(. [marginBottom(#px(4))])
  let idCointainer = style(. [marginBottom(#px(16))])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let noPadding = style(. [padding(#zero)])
  let groupID = style(. [
    fontFamilies([#custom("Roboto Mono"), #monospace]),
    Media.mobile([display(#block), marginBottom(#px(8))]),
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
  let make = (~groupID, ~hashtag) => {
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
            <Heading size=Heading.H1 weight=Heading.Bold>
              <span className=Styles.groupID>
                {`#G${mock.id->ID.Group.toInt->Belt.Int.toString} `->React.string}
              </span>
              <span> {"Group Name"->React.string} </span>
            </Heading>
          </div>
        </Row>
        <InfoContainer>
          <Table>
            <Tab.Route
              tabs=[
                {
                  name: "Proposal",
                  route: groupID->ID.Group.getRouteWithTab(Route.GroupProposal),
                },
                {
                  name: "Policy",
                  route: groupID->ID.Group.getRouteWithTab(Route.GroupPolicy),
                },
                {
                  name: "Members",
                  route: groupID->ID.Group.getRouteWithTab(Route.GroupMember),
                },
                {
                  name: "Information",
                  route: groupID->ID.Group.getRouteWithTab(Route.GroupInformation),
                },
              ]
              currentRoute={groupID->ID.Group.getRouteWithTab(hashtag)}>
              {switch hashtag {
              | GroupProposal => <GroupDetailsTabs.Proposal proposals={MockGroup.mock.proposals} />
              | GroupPolicy => <GroupDetailsTabs.Policy polices={MockGroup.mock.policies} />
              | GroupMember => <GroupDetailsTabs.Members members={MockGroup.mock.members} />
              | GroupInformation =>
                <GroupDetailsTabs.Information information={MockGroup.mock.information} />
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
  // TODO: not have a subscription yet
  // switch oracleScriptSub {
  // | NoData => <NotFound />
  // | Data(_) | Error(_) | Loading => <Content groupID hashtag />
  // }

  <Content groupID hashtag />
}
