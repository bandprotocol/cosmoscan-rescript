module Styles = {
  open CssJs

  let header = (theme: Theme.t) =>
    style(. [
      position(#relative),
      paddingTop(Spacing.lg),
      backgroundColor(theme.neutral_000),
      zIndex(3),
      Media.mobile([
        padding(#px(16)),
        marginBottom(#zero),
        position(#sticky),
        top(#zero),
        width(#percent(100.)),
      ]),
    ])

  let bandLogo = style(. [width(#px(40)), marginRight(#px(5)), Media.mobile([width(#px(34))])])

  let blockImage = style(. [display(#block)])

  let link = style(. [cursor(#pointer)])

  let chainIDContainer = style(. [marginLeft(#px(24))])

  let chainIDContainerMobile = style(. [margin(#zero)])

  let boxShadow = style(. [
    boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.08)))),
    position(#relative),
  ])
}

module LinkToHome = {
  @react.component
  let make = (~children) => <Link className=Styles.link route=Route.HomePage> children </Link>
}

module DesktopRender = {
  @react.component
  let make = () => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <header className={Styles.header(theme)}>
      <div className=CssHelper.container>
        <Row alignItems=Row.Center marginBottom=22>
          <Col col=Col.Six>
            <div className={CssHelper.flexBox(~align=#center, ())}>
              <LinkToHome>
                <div className={CssHelper.flexBox(~align=#center, ())}>
                  <img src=Images.bandLogo alt="band-logo" className=Styles.bandLogo />
                  <div>
                    <Text
                      value="BANDCHAIN"
                      size=Text.Body2
                      weight=Text.Semibold
                      nowrap=true
                      color=theme.neutral_900
                      special=true
                    />
                    <Text
                      value="Cosmoscan"
                      nowrap=true
                      size=Text.Caption
                      weight=Text.Semibold
                      color=theme.neutral_900
                      special=true
                    />
                  </div>
                </div>
              </LinkToHome>
              <div className=Styles.chainIDContainer>
                <ChainIDBadge />
              </div>
            </div>
          </Col>
          <Col col=Col.Six>
            <div className={CssHelper.flexBox(~align=#center, ~justify=#flexEnd, ())}>
              <SearchBar />
            </div>
          </Col>
        </Row>
      </div>
      <Section bg=theme.neutral_100 pt=0 pb=0 style=Styles.boxShadow>
        <div className=CssHelper.container>
          <Row alignItems=Row.Center>
            <Col col=Col.Eight>
              <NavBar />
            </Col>
            <Col col=Col.Four>
              <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
                <UserAccount />
                <HSpacing size=#px(10) />
                <ToggleThemeButton />
              </div>
            </Col>
          </Row>
        </div>
      </Section>
    </header>
  }
}

module MobileRender = {
  @react.component
  let make = () => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <header className={Styles.header(theme)}>
      <Row alignItems=Row.Center>
        <Col colSm=Col.Six>
          <div className={CssHelper.flexBox(~align=#flexEnd, ())}>
            <LinkToHome>
              <img
                src=Images.bandLogo
                alt="band-logo"
                className={Css.merge(list{Styles.bandLogo, Styles.blockImage})}
              />
            </LinkToHome>
            <HSpacing size=Spacing.sm />
            <LinkToHome>
              <div className={CssHelper.flexBox(~direction=#column, ~align=#flexStart, ())}>
                <Text
                  value="BANDCHAIN"
                  size=Text.Body2
                  weight=Text.Bold
                  color=theme.neutral_900
                  spacing=Text.Em(0.05)
                  block=true
                />
                <Text
                  value="CosmoScan"
                  size=Text.Caption
                  color=theme.neutral_600
                  spacing=Text.Em(0.03)
                  block=true
                />
              </div>
            </LinkToHome>
          </div>
        </Col>
        <Col colSm=Col.Six>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ~wrap=#nowrap, ())}>
            <ToggleThemeButton />
            <NavBar />
          </div>
        </Col>
      </Row>
      <Row marginTopSm=24 marginBottomSm=24 style={Styles.chainIDContainerMobile}>
        <ChainIDBadge />
      </Row>
      <Row marginTop=20>
        <Col colSm=Col.Twelve>
          <SearchBar />
        </Col>
      </Row>
    </header>
  }
}

@react.component
let make = () => Media.isMobile() ? <MobileRender /> : <DesktopRender />
