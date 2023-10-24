module Styles = {
  open CssJs

  let tableItem = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_200),
      padding2(~v=px(16), ~h=#zero),
      selector("> div", [minWidth(#percent(12.))]),
      selector("> div:nth-child(2)", [minWidth(#percent(50.))]),
      Media.mobile([
        selector("> div", [minWidth(#percent(20.))]),
        selector("> div:nth-child(2)", [minWidth(#percent(50.))]),
        selector("> div:first-child", [minWidth(#percent(10.))]),
      ]),
    ])

  let tableLink = (theme: Theme.t) =>
    style(. [
      cursor(pointer),
      selector("&:hover span", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])
}
@react.component
let make = (~group: Group.t) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()
  <>
    <div
      className={Css.merge(list{
        "table_item",
        CssHelper.flexBox(~align=#center, ~justify=#spaceBetween, ()),
        Styles.tableItem(theme),
      })}>
      <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
        <TypeID.Group id=group.id size={Body1} weight={Bold} />
      </div>
      <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
        <Link
          className={Css.merge(list{Styles.tableLink(theme)})}
          route={OracleScriptDetailsPage(1, OracleScriptRequests)}>
          <Text
            value=group.name ellipsis=true color={theme.primary_600} weight=Semibold size={Body1}
          />
        </Link>
      </div>
      <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
        <Text
          value={group.memberCount->Belt.Int.toString}
          color={theme.neutral_900}
          size={Body1}
          code=true
        />
      </div>
      <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
        <Text
          value={group.proposalsCount->Belt.Int.toString}
          color={theme.neutral_900}
          size={Body1}
          code=true
        />
      </div>
      {isMobile
        ? React.null
        : <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
            <Text
              value={group.proposalOnVoting->Belt.Array.length->Belt.Int.toString}
              color={theme.neutral_900}
              size={Body1}
              code=true
            />
          </div>}
    </div>
  </>
}
