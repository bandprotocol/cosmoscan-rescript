module Styles = {
  open CssJs
  let socialContainer = style(. [padding(#px(24)), selector("a + a", [marginLeft(#px(16))])])
  let socialImg = (theme: Theme.t) =>
    style(. [
      width(#px(16)),
      selector("> div >svg", [width(#px(16)), height(#px(16))]),
      selector("svg path", [SVG.fill(theme.neutral_600)]),
      hover([selector("svg path", [SVG.fill(theme.primary_600)])]),
    ])
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
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className={Css.merge(list{CssHelper.flexBox(~justify=#center, ()), Styles.socialContainer})}>
    {mapImages
    ->Belt.Array.mapWithIndex((i, e) =>
      <AbsoluteLink key={Belt.Int.toString(i)} href={e[0]}>
        <ReactSvg
          src={e[1]} className={Css.merge(list{"sidebar--social-icon", Styles.socialImg(theme)})}
        />
      </AbsoluteLink>
    )
    ->React.array}
  </div>
}
