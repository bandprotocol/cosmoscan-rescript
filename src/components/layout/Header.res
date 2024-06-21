module Styles = {
  open CssJs

  let header = (theme: Theme.t) =>
    style(. [
      position(#relative),
      padding2(~v=#px(16), ~h=#px(16)),
      backgroundColor(theme.neutral_200),
      zIndex(3),
      Media.mobile([
        padding(#px(16)),
        marginBottom(#zero),
        position(#sticky),
        top(#zero),
        width(#percent(100.)),
      ]),
    ])

  let headerTop = style(. [
    position(#fixed),
    top(#zero),
    left(#px(Sidebar.sidebarWidth)),
    width(#percent(100.)),
    maxWidth(#calc(#sub, #percent(100.), #px(Sidebar.sidebarWidth))),
    zIndex(800),
    Media.mobile([left(#zero), maxWidth(#percent(100.))]),
  ])

  let menuContainer = style(. [
    display(#flex),
    alignItems(#center),
    justifyContent(#center),
    textAlign(#center),
    width(#px(32)),
    height(#px(32)),
    cursor(#pointer),
  ])
}

@react.component
let make = (~setShow, ~show) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()
  let currentRoute = RescriptReactRouter.useUrl()->Route.fromUrl

  <div className={Css.merge(list{"header-top", Styles.headerTop})}>
    <header className={Styles.header(theme)}>
      <div className=CssHelper.container>
        <Row alignItems=Row.Center>
          {isMobile
            ? <Col col=Col.One colSm=Col.One>
                <div className={CssHelper.flexBox(~justify=#flexEnd, ~wrap=#nowrap, ())}>
                  {isMobile
                    ? <div className=Styles.menuContainer onClick={_ => setShow(_ => !show)}>
                        {show
                          ? <Icon name="fal fa-times" color={theme.neutral_900} size=24 />
                          : <Icon name="fal fa-bars" color={theme.neutral_900} size=24 />}
                      </div>
                    : React.null}
                </div>
              </Col>
            : React.null}
          <Col col=Col.Six colSm=Col.Eleven>
            <div className={CssHelper.flexBox(~align=#center, ~justify=#flexEnd, ())}>
              <SearchBar />
            </div>
          </Col>
          {isMobile
            ? React.null
            : <Col col=Col.Six colSm=Col.Four>
                <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
                  {isMobile
                    ? React.null
                    : <>
                        <UserAccount />
                        <HSpacing size=#px(10) />
                      </>}
                  <div className={CssHelper.flexBox(~justify=#flexEnd, ~wrap=#nowrap, ())}>
                    {isMobile ? React.null : <ToggleThemeButton />}
                  </div>
                </div>
              </Col>}
        </Row>
      </div>
    </header>
  </div>
}
