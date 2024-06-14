module Styles = {
  open CssJs

  let container = style(. [position(#relative)])

  let oval = (theme: Theme.t) =>
    style(. [
      display(#flex),
      width(#px(24)),
      height(#px(24)),
      justifyContent(#center),
      alignItems(#center),
      padding(#px(5)),
      backgroundColor(theme.primary_600),
      borderRadius(#percent(50.)),
    ])

  let logo = style(. [width(#px(12))])
  let fullWidth = style(. [width(#percent(100.))])

  let profileCard = (show, theme: Theme.t, isDarkMode) =>
    style(. [
      position(#absolute),
      top(#px(42)),
      right(#px(0)),
      transition(~duration=200, "all"),
      opacity(show ? 1. : 0.),
      pointerEvents(show ? #auto : #none),
      zIndex(5),
      width(#px(400)),
      padding2(~v=#px(24), ~h=#px(24)),
      background(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      borderRadius(#px(16)),
      border(#px(1), #solid, theme.neutral_200),
      boxShadows([Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(16, 18, 20, #num(0.15)))]),
    ])

  let innerProfileCard = (theme: Theme.t) =>
    style(. [
      padding(#px(16)),
      backgroundColor(theme.neutral_100),
      boxShadow(Shadow.box(~x=#zero, ~y=#zero, ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.08)))),
    ])

  let userInfoButton = (theme: Theme.t) =>
    style(. [
      width(#px(160)),
      padding2(~v=#px(10), ~h=#px(16)),
      borderRadius(#px(8)),
      border(#px(1), #solid, theme.neutral_600),
      backgroundColor(theme.neutral_000),
    ])

  let connect = style(. [padding2(~v=#px(10), ~h=#zero)])
  let disconnect = style(. [paddingTop(#px(16))])
}

module ConnectBtn = {
  @react.component
  let make = (~connect) =>
    <div id="connectButton" className={Styles.fullWidth}>
      <Button variant=Button.Secondary px=24 py=8 fullWidth=true onClick={_ => connect()}>
        {"Connect Wallet"->React.string}
      </Button>
    </div>
}

module DisconnectBtn = {
  @react.component
  let make = (~disconnect) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div
      className={Css.merge(list{
        CssHelper.flexBox(~justify=#center, ~align=#center, ()),
        CssHelper.clickable,
        Styles.disconnect,
      })}
      onClick={_ => disconnect()}>
      <Text value="Disconnect" weight=Text.Medium color=theme.primary_600 nowrap=true block=true />
    </div>
  }
}

module FaucetBtn = {
  @react.component
  let make = (~address) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let (isRequest, setIsRequest) = React.useState(_ => false)
    let (isFailed, setIsFailed) = React.useState(_ => false)

    isRequest
      ? <LoadingCensorBar.CircleSpin size=30 height=30 />
      : isFailed
      ? <Text size=Text.Caption color={theme.error_600} value="Too many Request. try again later" />
      : <div id="getFreeButton">
          <Button
            px=20
            py=5
            variant=Button.Outline
            onClick={_ => {
              setIsRequest(_ => true)
              setIsFailed(_ => false)
              AxiosFaucet.request({
                address: address->Address.toBech32,
                amount: 10_000_000,
              })
              ->Promise.then(response => {
                setIsRequest(_ => false)
                Js.log(response)
                Promise.resolve()
              })
              ->Promise.catch(err => {
                setIsRequest(_ => false)
                setIsFailed(_ => true)
                Promise.resolve()
              })
              ->ignore
            }}>
            {"Get 10 Testnet BAND"->React.string}
          </Button>
        </div>
  }
}

module SendBtn = {
  @react.component
  let make = (~send) =>
    <div id="sendToken">
      <Button px=20 py=5 onClick={_ => send()}> {"Send"->React.string} </Button>
    </div>
}

module Balance = {
  @react.component
  let make = (~address) => {
    let accountSub = AccountSub.get(address)
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
      <Text value="Balance" weight=Text.Medium color=theme.neutral_900 />
      <div className={CssHelper.flexBox()} id="bandBalance">
        <Text
          value={switch accountSub {
          | Data(account) => account.balance->Coin.getBandAmountFromCoins->Format.fPretty(~digits=6)
          | _ => "0"
          }}
          code=true
          color=theme.neutral_900
        />
        <HSpacing size=Spacing.sm />
        <Text value="BAND" weight=Text.Thin color=theme.neutral_900 />
      </div>
    </div>
  }
}

module AccountBox = {
  @react.component
  let make = (~setAccountBoxState) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)
    let trackingSub = TrackingSub.use()
    let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)

    let send = () => {
      SubmitMsg.Send(None, IBCConnectionQuery.BAND)->SubmitTx->OpenModal->dispatchModal
      setAccountBoxState(_ => "noShow")
    }

    let disconnect = () => {
      dispatchAccount(Disconnect)
      setAccountBoxState(_ => "noShow")
    }

    {
      switch accountOpt {
      | Some({address}) =>
        <div>
          <div onClick={_ => setAccountBoxState(_ => "account")}>
            <AddressRender address position=AddressRender.Text />
          </div>
          <VSpacing size=#px(16) />
          <div className={Styles.innerProfileCard(theme)}>
            <Balance address />
            <VSpacing size=#px(16) />
            <div className={CssHelper.flexBox(~direction=#row, ~justify=#spaceBetween, ())}>
              {switch trackingSub {
              | Data({chainID}) => {
                  let currentChainID = chainID->ChainIDBadge.parseChainID
                  currentChainID == LaoziTestnet ? <FaucetBtn address /> : React.null
                }

              | _ => React.null
              }}
              <SendBtn send />
            </div>
          </div>
          <DisconnectBtn disconnect />
        </div>
      | None => React.null
      }
    }
  }
}

@react.component
let make = () => {
  let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)
  let (accountBoxState, setAccountBoxState) = React.useState(_ => "noShow")
  let trackingSub = TrackingSub.use()
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let clickOutside = ClickOutside.useClickOutside(_ => setAccountBoxState(_ => "noShow"))

  let connect = () =>
    accountBoxState == "noShow"
      ? setAccountBoxState(_ => "connect")
      : setAccountBoxState(_ => "noShow")

  <div className={Css.merge(list{CssHelper.flexBox(~justify=#flexEnd, ()), Styles.container})}>
    <div ref={ReactDOM.Ref.domRef(clickOutside)}>
      {switch accountOpt {
      | Some({address}) =>
        <div
          id="userInfoButton"
          className={Css.merge(list{
            CssHelper.flexBox(),
            CssHelper.clickable,
            Styles.userInfoButton(theme),
          })}
          onClick={_ => setAccountBoxState(_ => "account")}>
          <Text
            value={address->Address.toBech32}
            color=theme.neutral_900
            ellipsis=true
            weight={Semibold}
          />
        </div>
      | None =>
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          {switch trackingSub {
          | Data(_) => <ConnectBtn connect={_ => connect()} />
          | Error(err) =>
            // log for err details
            Js.Console.log(err)
            <Text value="Invalid Chain ID" />
          | _ => <LoadingCensorBar width=150 height=30 />
          }}
        </div>
      }}
      <div className={Styles.profileCard(accountBoxState != "noShow", theme, isDarkMode)}>
        {switch accountBoxState {
        | "account" => <AccountBox setAccountBoxState />
        | "connect" => <SelectWallet setAccountBoxState />
        | "keplrNotfound" => <KeplrNotfound />
        | "keplrBandNotfound" => <KeplrBandNotfound />
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
