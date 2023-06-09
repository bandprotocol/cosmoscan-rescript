module RenderDesktop = {
  module Styles = {
    open CssJs

    let nav = (isActive, theme: Theme.t) =>
      style(. [
        padding3(~top=#px(16), ~h=#zero, ~bottom=#px(12)),
        cursor(#pointer),
        fontSize(#px(12)),
        fontWeight(#num(600)),
        hover([color(theme.neutral_900)]),
        active([color(theme.neutral_900)]),
        transition(~duration=400, "all"),
        color(isActive ? theme.neutral_900 : theme.neutral_600),
        borderBottom(#px(4), #solid, isActive ? theme.primary_600 : #transparent),
      ])
  }

  @react.component
  let make = (~routes, ~last) => {
    let currentRoute = RescriptReactRouter.useUrl()->Route.fromUrl

    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className={CssHelper.flexBox(~justify=#spaceBetween, ())} id="navigationBar">
      {routes
      ->Belt.List.map(((v, route)) =>
        <React.Fragment key=v>
          <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
            <Link className={Styles.nav(currentRoute == route, theme)} route>
              {v->React.string}
            </Link>
          </div>
          {last->Belt.List.has(v, (a, b) => a == b) ? <Divider key={`${v}-divider`} /> : React.null}
        </React.Fragment>
      )
      ->Array.of_list
      ->React.array}
    </div>
  }
}

module RenderMobile = {
  module Styles = {
    open CssJs

    let navContainer = (show, theme: Theme.t) =>
      style(. [
        display(#flex),
        padding2(~v=#zero, ~h=#px(16)),
        flexDirection(#column),
        alignItems(#center),
        opacity(show ? 1. : 0.),
        zIndex(99),
        pointerEvents(show ? #auto : #none),
        width(#percent(100.)),
        height(#vh(100.)),
        position(#absolute),
        top(#zero),
        left(#zero),
        right(#zero),
        transition(~duration=400, "all"),
        backgroundColor(theme.neutral_000),
        boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.08)))),
      ])

    let nav = (isActive, isLast, theme: Theme.t) =>
      style(. [
        fontSize(#px(14)),
        fontWeight(isActive ? #num(700) : #num(600)),
        color(isActive ? theme.neutral_900 : theme.neutral_600),
        width(#percent(100.)),
        padding2(~v=#px(16), ~h=#zero),
        textAlign(#center),
        borderBottom(#px(1), #solid, isLast ? theme.neutral_600 : theme.neutral_300),
      ])

    let bandLogo = style(. [width(#px(40)), marginRight(#px(5)), Media.mobile([width(#px(34))])])
    let blockImage = style(. [display(#block)])

    let menuContainer = style(. [
      marginLeft(#px(16)),
      flexBasis(#px(24)),
      flexGrow(0.),
      flexShrink(0.),
      height(#px(24)),
      textAlign(#center),
    ])
    let menu = style(. [width(#px(20)), display(#block)])
    let toggleContainer = style(. [padding2(~v=#px(24), ~h=#zero)])
    let backdropContainer = show =>
      style(. [
        width(#percent(100.)),
        height(#percent(100.)),
        backgroundColor(#rgba((0, 0, 0, #num(0.5)))),
        position(#fixed),
        opacity(show ? 1. : 0.),
        pointerEvents(show ? #auto : #none),
        left(#zero),
        top(#px(58)),
        transition(~duration=400, "all"),
      ])
    let brandRowContainer = {
      style(. [paddingTop(#px(16)), paddingBottom(#px(24)), width(#percent(100.))])
    }
  }

  @react.component
  let make = (~routes, ~last) => {
    let currentRoute = RescriptReactRouter.useUrl()->Route.fromUrl
    let (show, setShow) = React.useState(_ => false)
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let modeMsg = {
      let mode = isDarkMode ? "Lightmode" : "Darkmode"
      "Switch to " ++ mode
    }

    React.useEffect1(_ => {
      setShow(_ => false)
      None
    }, [currentRoute])

    <>
      <div className=Styles.menuContainer onClick={_ => setShow(prev => !prev)}>
        {show
          ? <Icon name="fal fa-times" color={theme.neutral_900} size=24 />
          : <Icon name="fal fa-bars" color={theme.neutral_900} size=24 />}
      </div>
      <div className={Styles.navContainer(show, theme)}>
        <div className={Styles.brandRowContainer}>
          <Row alignItems=Row.Center>
            <Col colSm=Col.Six>
              <div className={CssHelper.flexBox(~align=#flexEnd, ())}>
                <LinkToHome>
                  <img
                    src=Images.bandLogo
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
                      nowrap=true
                      color=theme.neutral_900
                      spacing=Text.Em(0.05)
                    />
                    <VSpacing size=Spacing.xs />
                    <Text
                      value="CosmoScan"
                      nowrap=true
                      size=Text.Caption
                      color=theme.neutral_600
                      spacing=Text.Em(0.03)
                    />
                  </div>
                </LinkToHome>
              </div>
            </Col>
            <Col colSm=Col.Six>
              <div className={CssHelper.flexBox(~justify=#flexEnd, ~wrap=#nowrap, ())}>
                <ToggleThemeButton />
                <div className=Styles.menuContainer onClick={_ => setShow(prev => !prev)}>
                  {show
                    ? <Icon name="fal fa-times" color={theme.neutral_900} size=24 />
                    : <Icon name="fal fa-bars" color={theme.neutral_900} size=24 />}
                </div>
              </div>
            </Col>
          </Row>
        </div>
        {routes
        ->Belt.List.map(((v, route)) => {
          let isActive = currentRoute == route
          let isLast = last->Belt.List.has(v, (a, b) => a == b)
          <Link className={Styles.nav(isActive, isLast, theme)} route> {v->React.string} </Link>
        })
        ->Array.of_list
        ->React.array}
      </div>
      <div onClick={_ => setShow(prev => !prev)} className={Styles.backdropContainer(show)} />
    </>
  }
}

@react.component
let make = () => {
  let routes = list{
    ("Home", Route.HomePage),
    ("Blocks", BlockPage),
    ("Transactions", TxHomePage),
    ("Validators", ValidatorsPage),
    ("Proposals", ProposalPage),
    ("Requests", RequestHomePage),
    ("Data Sources", DataSourcePage),
    ("Oracle Scripts", OracleScriptPage),
    ("IBCs", RelayersHomepage),
  }

  // last nav of each section to separate by divider
  let last = list{"Home", "Proposals", "Oracle Scripts"}

  Media.isMobile() ? <RenderMobile routes last /> : <RenderDesktop routes last />
}
