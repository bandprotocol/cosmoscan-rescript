module Styles = {
  open CssJs

  let version = (theme: Theme.t) =>
    style(. [
      display(#flex),
      borderRadius(#px(8)),
      border(#px(1), #solid, theme.neutral_600),
      backgroundColor(theme.neutral_000),
      padding2(~v=#px(8), ~h=#px(24)),
      minWidth(#px(153)),
      justifyContent(#spaceBetween),
      alignItems(#center),
      position(#relative),
      cursor(#pointer),
      zIndex(5),
      Media.smallMobile([minWidth(#px(90))]),
    ])

  let dropdown = (show, theme: Theme.t) =>
    style(. [
      position(#absolute),
      width(#percent(100.)),
      border(#px(1), #solid, theme.neutral_600),
      backgroundColor(theme.neutral_000),
      borderRadius(#px(8)),
      transition(~duration=200, "all"),
      top(#percent(110.)),
      left(#zero),
      height(#auto),
      opacity(show ? 1. : 0.),
      pointerEvents(show ? #auto : #none),
      overflow(#hidden),
      Media.mobile([top(#px(40))]),
    ])

  let link = (theme: Theme.t) =>
    style(. [
      textDecoration(#none),
      backgroundColor(theme.neutral_000),
      display(#block),
      padding2(~v=#px(8), ~h=#px(24)),
      hover([backgroundColor(theme.neutral_100)]),
    ])
}

type chainID =
  | WenchangTestnet
  | WenchangMainnet
  | GuanYuDevnet
  | GuanYuTestnet
  | GuanYuPOA
  | GuanYuMainnet
  | LaoziTestnet
  | LaoziMainnet
  | LaoziPOA
  | HackathonMainnet
  | Unknown

let parseChainID = x =>
  switch x {
  | "band-wenchang-testnet3" => WenchangTestnet
  | "band-wenchang-mainnet" => WenchangMainnet
  | "band-guanyu-devnet5"
  | "band-guanyu-devnet6"
  | "band-guanyu-devnet7"
  | "band-guanyu-devnet8"
  | "bandchain" =>
    GuanYuDevnet
  | "band-guanyu-testnet1"
  | "band-guanyu-testnet2"
  | "band-guanyu-testnet3"
  | "band-guanyu-testnet4" =>
    GuanYuTestnet
  | "band-guanyu-poa" => GuanYuPOA
  | "band-guanyu-mainnet" => GuanYuMainnet
  | "band-laozi-testnet1"
  | "band-laozi-testnet2"
  | "band-laozi-testnet3"
  | "band-laozi-testnet4"
  | "band-laozi-testnet5"
  | "band-laozi-testnet6" =>
    LaoziTestnet
  | "laozi-mainnet" => LaoziMainnet
  | "band-laozi-poa" => LaoziPOA
  | "band-laozi-hackathon" => HackathonMainnet
  | _ => Unknown
  }

let getLink = x =>
  switch x {
  | WenchangTestnet => "https://wenchang-testnet3.cosmoscan.io/"
  | WenchangMainnet => "https://wenchang-legacy.cosmoscan.io/"
  | GuanYuMainnet => "https://guanyu-legacy.cosmoscan.io/"
  | GuanYuDevnet => "https://guanyu-devnet.cosmoscan.io/"
  | GuanYuTestnet => "https://guanyu-testnet4.cosmoscan.io/"
  | GuanYuPOA => "https://guanyu-poa.cosmoscan.io/"
  | LaoziTestnet => "https://laozi-testnet6.cosmoscan.io/"
  | LaoziMainnet => "https://cosmoscan.io/"
  | LaoziPOA => "https://laozi-poa.cosmoscan.io/"
  | HackathonMainnet => "https://laozi-hackathon.cosmoscan.io/"
  | Unknown => ""
  }

let getName = x =>
  switch x {
  | WenchangTestnet => "wenchang-testnet"
  | WenchangMainnet => "wenchang-mainnet"
  | GuanYuDevnet => "guanyu-devnet"
  | GuanYuTestnet => "guanyu-testnet"
  | GuanYuPOA => "guanyu-poa"
  | GuanYuMainnet => "legacy-guanyu"
  | LaoziTestnet => "laozi-testnet"
  | LaoziMainnet => "laozi-mainnet"
  | LaoziPOA => "laozi-poa"
  | HackathonMainnet => "laozi-hackathon"
  | Unknown => "unknown"
  }

@react.component
let make = () => {
  let (show, setShow) = React.useState(_ => false)
  let trackingSub = TrackingSub.use()
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  switch trackingSub {
  | Data({chainID}) => {
      let currentChainID = chainID->parseChainID
      <div
        className={Styles.version(theme)}
        onClick={event => {
          setShow(oldVal => !oldVal)
          ReactEvent.Mouse.stopPropagation(event)
        }}>
        <Text
          value={currentChainID->getName}
          color={theme.neutral_900}
          nowrap=true
          weight=Text.Semibold
          size=Text.Body1
        />
        <HSpacing size=Spacing.sm />
        {show
          ? <Icon name="far fa-angle-up" color={theme.neutral_600} />
          : <Icon name="far fa-angle-down" color={theme.neutral_600} />}
        <div className={Styles.dropdown(show, theme)}>
          {[LaoziMainnet, LaoziTestnet]
          ->Belt.Array.keep(chainID => chainID != currentChainID)
          ->Belt.Array.map(chainID => {
            let name = chainID->getName
            <AbsoluteLink href={getLink(chainID)} key=name className={Styles.link(theme)}>
              <Text
                value=name
                color={theme.neutral_600}
                nowrap=true
                weight=Text.Semibold
                size=Text.Body1
              />
            </AbsoluteLink>
          })
          ->React.array}
        </div>
      </div>
    }

  | _ => <LoadingCensorBar width=153 height=30 />
  }
}
