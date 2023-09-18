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
  let make = (~routes: list<array<(string, Route.t, string, string)>>) => {
    let currentRoute = RescriptReactRouter.useUrl()

    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className={"nav-container"} id="navigationBar">
      {routes
      ->Belt.List.mapWithIndex((v, route) =>
        <div
          className={Css.merge(list{"nav-item-wrapper", Styles.navItemWrapper(theme)})}
          key={v->Belt.Int.toString}>
          <ul>
            {route
            ->Belt.Array.mapWithIndex((i, (label, link, icon, urlSet)) => {
              <li key={i->Belt.Int.toString} className={Styles.navItem}>
                <Link
                  className={Styles.navLink(
                    currentRoute.path
                    ->Belt.List.toArray
                    ->Belt.Array.get(0)
                    ->Belt.Option.getWithDefault("")
                    ->Js.String2.includes(urlSet) || currentRoute->Route.fromUrl == link,
                    theme,
                  )}
                  route=link>
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
    [("Home", Route.HomePage, Images.homeIconSidebar, "/")],
    [
      ("Blocks", BlockPage, Images.blockIconSidebar, "block"),
      ("Transactions", TxHomePage, Images.txIconSidebar, "tx"),
      ("Validators", ValidatorsPage, Images.validatorIconSidebar, "validator"),
      ("Proposals", ProposalPage, Images.proposalIconSidebar, "proposal"),
    ],
    [
      ("Data Sources", DataSourcePage, Images.datasourceIconSidebar, "data-source"),
      ("Oracle Scripts", OracleScriptPage, Images.oracleIconSidebar, "oracle-script"),
      ("Requests", RequestHomePage, Images.requestIconSidebar, "request"),
    ],
    // TODO: enable only for devnet
    // [("Group Module", GroupPage(Group), Images.groupIconSidebar, "group")],
    [("IBCs", RelayersHomepage, Images.ibcIconSidebar, "relayer")],
  }

  <NavContent routes=sidebarRoutes />
}
