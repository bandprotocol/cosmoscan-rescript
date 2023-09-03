module Styles = {
  open CssJs

  let sidebarWrapper = (~sidebarWidth: int, ~isOpen, ~isMobile, ~theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      maxWidth(#px(sidebarWidth)),
      backgroundColor(theme.neutral_100),
      position(isMobile ? #fixed : #static),
      left(isOpen ? #zero : #px(-sidebarWidth)),
      top(#zero),
      transition(~duration=400, "all"),
      height(#vh(100.)),
      overflowY(#scroll),
      overflowX(#hidden),
      zIndex(10000),
      display(#flex),
      flexDirection(#column),
      selector("> *", [width(#percent(100.))]),
    ])

  let sidebarHeader = style(. [padding(#px(24))])
  let bandLogo = style(. [width(#percent(100.))])

  let blockImage = style(. [display(#block)])

  let link = style(. [cursor(#pointer)])

  let chainIDContainer = style(. [marginLeft(#px(24))])

  let chainIDContainerMobile = style(. [margin(#zero)])

  let boxShadow = style(. [
    boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.08)))),
    position(#relative),
  ])
  let sidebarLogo = style(. [marginBottom(#px(20))])

  let sidebarMenuWrapper = style(. [
    padding(#zero),
    display(#flex),
    justifyContent(#spaceBetween),
    flexDirection(#column),
    height(#percent(100.)),
  ])

  let sidebarFooter = style(. [padding(#px(24))])
}

let sidebarWidth = 240

module LinkToHome = {
  @react.component
  let make = (~children) => <Link className=Styles.link route=Route.HomePage> children </Link>
}

@react.component
let make = (~show, ~setShow) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <div
    className={Css.merge(list{
      "sidebar--wrapper",
      Styles.sidebarWrapper(~isOpen=show, ~sidebarWidth, ~isMobile, ~theme),
    })}>
    <div className={Css.merge(list{"sidebar--header", Styles.sidebarHeader})}>
      <div
        className={Css.merge(list{
          "sidebar--logo",
          CssHelper.flexBox(~align=#center, ~justify=#center, ()),
          Styles.sidebarLogo,
        })}>
        <LinkToHome>
          <img
            src={isDarkMode ? Images.bandLogoLight : Images.bandLogoDark}
            alt="band-logo"
            className={Css.merge(list{Styles.bandLogo, Styles.blockImage})}
          />
        </LinkToHome>
      </div>
      <ChainIDBadge />
    </div>
    <div className={Css.merge(list{"sidebar--menu-wrapper", Styles.sidebarMenuWrapper})}>
      <NavBar />
      {isMobile
        ? <div className={Styles.sidebarFooter}>
            <ToggleThemeButton />
          </div>
        : <SocialList />}
    </div>
  </div>
}
