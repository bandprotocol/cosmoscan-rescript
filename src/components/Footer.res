module Styles = {
  open CssJs

  let footerBg = style(. [zIndex(4)])
  let socialContainer = style(. [selector("a + a", [marginLeft(#px(16))])])
  let socialImg = style(. [width(#px(16))])
}

let mapImages = [
  ["https:/\/github.com/bandprotocol", Images.githubSvg, "bandprotocol on github"],
  ["https:/\/medium.com/bandprotocol", Images.mediumSvg, "bandprotocol on medium"],
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
let make = () => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <Section bg=theme.footer pt=24 pb=24 ptSm=24 pbSm=24 style=Styles.footerBg>
    <div className=CssHelper.container>
      <Row alignItems=Row.Center>
        <Col col=Col.Six mbSm=24>
          <div
            className={Css.merge(list{
              CssHelper.flexBox(~justify=isMobile ? #center : #flexStart, ()),
              Styles.socialContainer,
            })}>
            {mapImages
            ->Belt.Array.mapWithIndex((i, e) =>
              <AbsoluteLink key={Belt.Int.toString(i)} href={e[0]}>
                <img src={e[1]} alt={e[2]} className=Styles.socialImg />
              </AbsoluteLink>
            )
            ->React.array}
          </div>
        </Col>
        <Col col=Col.Six>
          <div className={CssHelper.flexBox(~justify=isMobile ? #center : #flexEnd, ())}>
            <Text block=true value="Cosmoscan" weight=Text.Semibold color=theme.white />
            <HSpacing size=#px(5) />
            <Icon name="far fa-copyright" color=theme.white />
            <HSpacing size=#px(5) />
            <Text block=true value="2021" weight=Text.Semibold color=theme.white />
          </div>
        </Col>
      </Row>
    </div>
  </Section>
}
