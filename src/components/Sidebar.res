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

  let socialContainer = style(. [padding(#px(24)), selector("a + a", [marginLeft(#px(16))])])
  let socialImg = (theme: Theme.t) =>
    style(. [
      width(#px(16)),
      selector("> div >svg", [width(#px(16)), height(#px(16))]),
      selector("svg path", [SVG.fill(theme.neutral_600)]),
      hover([selector("svg path", [SVG.fill(theme.primary_600)])]),
    ])
}

let sidebarWidth = 240

module LinkToHome = {
  @react.component
  let make = (~children) => <Link className=Styles.link route=Route.HomePage> children </Link>
}

let mapImages = [
  ["https:/\/github.com/bandprotocol", Images.githubSvg, "bandprotocol on github"],
  ["https:/\/twitter.com/BandProtocol", Images.twitterSvg, "bandprotocol on twitter"],
  ["https:/\/t.me/bandprotocol", Images.telegramSvg, "bandprotocol on telegram"],
  ["https:/\/discord.com/invite/3t4bsY7", Images.discordSvg, "bandprotocol on discord"],
  [
    "https:/\/coinmarketcap.com/currencies/band-protocol/",
    Images.coinmarketcapWhiteSvg,
    "bandprotocol on coinmarketcap",
  ],
  [
    "https:/\/www.coingecko.com/en/coins/band-protocol",
    Images.coingeckoSvg,
    "bandprotocol on coingecko",
  ],
]

@react.component
let make = (~isOpen) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <div
    className={Css.merge(list{
      "sidebar--wrapper",
      Styles.sidebarWrapper(~sidebarWidth, ~isOpen, ~isMobile, ~theme),
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
      <div
        className={Css.merge(list{
          CssHelper.flexBox(~justify=#center, ()),
          Styles.socialContainer,
        })}>
        {mapImages
        ->Belt.Array.mapWithIndex((i, e) =>
          <AbsoluteLink key={Belt.Int.toString(i)} href={e[0]}>
            <ReactSvg
              src={e[1]}
              className={Css.merge(list{"sidebar--social-icon", Styles.socialImg(theme)})}
            />
          </AbsoluteLink>
        )
        ->React.array}
      </div>
    </div>
  </div>
}
