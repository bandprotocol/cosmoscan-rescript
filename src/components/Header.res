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
    marginLeft(#px(16)),
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
let make = (~toggleSidebar, ~show) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <div className={Css.merge(list{"header-top", Styles.headerTop})}>
    <header className={Styles.header(theme)}>
      <div className=CssHelper.container>
        <Row alignItems=Row.Center>
          <Col col=Col.Six colSm=Col.Eight>
            <div className={CssHelper.flexBox(~align=#center, ~justify=#flexEnd, ())}>
              <SearchBar />
            </div>
          </Col>
          <Col col=Col.Six colSm=Col.Four>
            <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
              {isMobile
                ? React.null
                : <>
                    <UserAccount />
                    <HSpacing size=#px(10) />
                  </>}
              <div className={CssHelper.flexBox(~justify=#flexEnd, ~wrap=#nowrap, ())}>
                <ToggleThemeButton />
                {isMobile
                  ? <div className=Styles.menuContainer onClick={_ => toggleSidebar()}>
                      {show
                        ? <Icon name="fal fa-times" color={theme.neutral_900} size=24 />
                        : <Icon name="fal fa-bars" color={theme.neutral_900} size=24 />}
                    </div>
                  : React.null}
              </div>
            </div>
          </Col>
        </Row>
      </div>
    </header>
  </div>
}
