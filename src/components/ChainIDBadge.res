module Styles = {
  open CssJs

  let buttonContainer = style(. [
    Media.mobile([
      width(#percent(100.)),
      marginTop(#px(16)),
      marginBottom(#px(24)),
    ])
    ]);
  let link = style(. [Media.mobile([flexBasis(#percent(50.))])])
  let baseBtn =
    style(. [
      textAlign(#center),
      Media.mobile([width(#percent(100.)), flexGrow(0.), flexShrink(0.), flexBasis(#percent(50.))]),
    ]);

  let leftBtn = (state, theme: Theme.t, isDarkMode) => {
    style(. [
      borderTopRightRadius(#zero),
      borderBottomRightRadius(#zero),
      backgroundColor(state ? theme.neutral_900 : theme.neutral_000),
      color(state ? theme.neutral_100 : theme.neutral_500),
      hover([
        backgroundColor(state ? theme.neutral_900 : theme.neutral_100),
        color(state ? theme.neutral_100 : theme.neutral_500),
      ]),
    ]);
  };
  let rightBtn = (state, theme: Theme.t, isDarkMode) => {
    style(. [
      borderTopLeftRadius(#zero),
      borderBottomLeftRadius(#zero),
      color(state ? theme.neutral_500 : theme.neutral_100),
      backgroundColor(state ? theme.neutral_000 : theme.neutral_900),
      hover([
        backgroundColor(state ? theme.neutral_100 : theme.neutral_900),
        color(state ? theme.neutral_500 : theme.neutral_100),
      ]),
    ]);
  };
};


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
  | Unknown;

let parseChainID = x =>
  switch x {
  | "band-wenchang-testnet3" => WenchangTestnet
  | "band-wenchang-mainnet" => WenchangMainnet
  | "band-guanyu-devnet5"
  | "band-guanyu-devnet6"
  | "band-guanyu-devnet7"
  | "band-guanyu-devnet8"
  | "bandchain" => GuanYuDevnet
  | "band-guanyu-testnet1"
  | "band-guanyu-testnet2"
  | "band-guanyu-testnet3"
  | "band-guanyu-testnet4" => GuanYuTestnet
  | "band-guanyu-poa" => GuanYuPOA
  | "band-guanyu-mainnet" => GuanYuMainnet
  | "band-laozi-testnet1"
  | "band-laozi-testnet2"
  | "band-laozi-testnet3"
  | "band-laozi-testnet4"
  | "band-laozi-testnet5"
  | "band-laozi-testnet6" => LaoziTestnet
  | "laozi-mainnet" => LaoziMainnet
  | "band-laozi-poa" => LaoziPOA
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
  | Unknown => ""
  }

let getName = x =>
  switch x {
  | WenchangTestnet => "wenchang-testnet"
  | WenchangMainnet => "wenchang-mainnet"
  | GuanYuDevnet => "guanyu-devnet"
  | GuanYuTestnet => "guanyu-testnet"
  | GuanYuPOA => "guanyu-poa"
  | GuanYuMainnet => "guanyu-mainnet"
  | LaoziTestnet => "laozi-testnet"
  | LaoziMainnet => "laozi-mainnet"
  | LaoziPOA => "laozi-poa"
  | Unknown => "unknown"
  }

@react.component
let make = (~dropdown=false) => {
    let isMobile = Media.isMobile()
    let currentRouteString = RescriptReactRouter.useUrl() -> Route.fromUrl -> Route.toAbsoluteString
    let (show, setShow) = React.useState(_ => false)
    let trackingSub = TrackingSub.use()
    let ({ThemeContext.theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    
    
    switch trackingSub {
      | Data(tracking) =>  {
        let currentChainID = tracking.chainID->parseChainID;
        let networkNames = [LaoziMainnet, LaoziTestnet] -> Belt.Array.map(chainID => chainID->getName)
        let isMainnet = (currentChainID->getName) == "laozi-mainnet"

        <div className={Css.merge(list{CssHelper.flexBox(), Styles.buttonContainer})}>
          <AbsoluteLink 
            className=Styles.link
            href={isMainnet ? "" : getLink(LaoziMainnet) ++ currentRouteString} 
            noNewTab=true
          >
            <Button
              px=16
              py=8
              variant=Button.Outline
              style={Css.merge(list{Styles.baseBtn, Styles.leftBtn(isMainnet, theme, isDarkMode)})}>
              {networkNames[0]  -> React.string}
            </Button>
          </AbsoluteLink>
          <AbsoluteLink 
            className=Styles.link
            href={isMainnet ? getLink(LaoziTestnet) ++ currentRouteString: ""} 
            noNewTab=true
          >
            <Button
              px=16
              py=8
              variant=Button.Outline
              style={Css.merge(list{Styles.baseBtn, Styles.rightBtn(isMainnet, theme, isDarkMode)})}>
              {networkNames[1] -> React.string}
            </Button>
          </AbsoluteLink>
        </div>
      }
      | _ =>  <div className=Styles.buttonContainer> 
        <LoadingCensorBar width={isMobile ? 310 : 310} height=30 />
      </div>
    }
  }
