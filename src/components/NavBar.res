module NavContent = {
  module Styles = {
    open CssJs

    let navLink = (isActive, theme: Theme.t) =>
      style(. [
        display(#block),
        padding2(~v=#px(13), ~h=#px(32)),
        fontSize(#px(14)),
        color(theme.neutral_600),
        fontWeight(#num(600)),
        boxShadow(
          isActive
            ? Shadow.box(~x=#px(4), ~y=#zero, ~blur=#zero, ~inset=true, theme.primary_default)
            : #unset,
        ),
        backgroundColor(isActive ? theme.neutral_000 : #transparent),
        hover([
          color(theme.neutral_900),
          textDecoration(#none),
          backgroundColor(theme.neutral_000),
          selector("svg [fill]", [SVG.fill(theme.primary_600)]),
        ]),
        selector("svg [fill]", [SVG.fill(isActive ? theme.primary_600 : theme.neutral_600)]),
      ])

    let navItemWrapper = (theme: Theme.t) =>
      style(. [
        borderBottom(#px(1), #solid, theme.neutral_300),
        selector("> ul", [marginTop(#px(8)), marginBottom(#px(8))]),
      ])

    let navItem = style(. [marginTop(#zero)])
    let iconSidebar = style(. [
      selector("> div", [display(#flex), alignItems(#center), justifyContent(#center)]),
    ])
  }

  @react.component
  let make = (~routes: list<array<(string, Route.t, string)>>) => {
    let currentRoute = RescriptReactRouter.useUrl()->Route.fromUrl

    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className={"nav-container"} id="navigationBar">
      {routes
      ->Belt.List.mapWithIndex((v, section) =>
        <div
          className={Css.merge(list{"nav-item-wrapper", Styles.navItemWrapper(theme)})}
          key={v->Belt.Int.toString}>
          <ul>
            {section
            ->Belt.Array.mapWithIndex((i, (label, link, icon)) => {
              <li key={i->Belt.Int.toString} className={Styles.navItem}>
                <Link className={Styles.navLink(currentRoute == link, theme)} route=link>
                  {<div className={CssHelper.flexBox(~direction=#row, ~align=#center, ())}>
                    <ReactSvg src={icon} className={Styles.iconSidebar} />
                    <HSpacing size={Spacing.sm} />
                    <Text value={label} size={Body1} />
                  </div>}
                </Link>
              </li>
            })
            ->React.array}
          </ul>
        </div>
      )
      ->Array.of_list
      ->React.array}
    </div>
  }
}

@react.component
let make = () => {
  let sidebarRoutes = list{
    [("Home", Route.HomePage, Images.homeIconSidebar)],
    [
      ("Blocks", BlockPage, Images.blockIconSidebar),
      ("Transactions", TxHomePage, Images.txIconSidebar),
      ("Validators", ValidatorsPage, Images.validatorIconSidebar),
      ("Proposals", ProposalPage, Images.proposalIconSidebar),
    ],
    [
      ("Data Sources", DataSourcePage, Images.datasourceIconSidebar),
      ("Oracle Scripts", OracleScriptPage, Images.oracleIconSidebar),
      ("Requests", RequestHomePage, Images.requestIconSidebar),
    ],
    [("Group Module", GroupPage(Group), Images.groupIconSidebar)],
    [("IBCs", RelayersHomepage, Images.ibcIconSidebar)],
  }

  <NavContent routes=sidebarRoutes />
}
