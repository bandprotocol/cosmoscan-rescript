module Styles = {
  open CssJs

  let container = style(. [position(#relative)])
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

  let userInfoButton = (theme: Theme.t) =>
    style(. [
      width(#px(160)),
      padding2(~v=#px(10), ~h=#px(16)),
      borderRadius(#px(8)),
      border(#px(1), #solid, theme.neutral_600),
      backgroundColor(theme.neutral_000),
    ])

  let connect = style(. [padding2(~v=#px(10), ~h=#zero)])
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

@react.component
let make = () => {
  let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)
  let (accountBoxState, setAccountBoxState, _, _) = React.useContext(WalletPopupContext.context)
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
      {switch trackingSub {
      | Data({chainID}) =>
        <div className={Styles.profileCard(accountBoxState != "noShow", theme, isDarkMode)}>
          {switch accountBoxState {
          | "account" => <AccountBox />
          | "connect" => <SelectWallet />
          | "leapNotfound" => <LeapNotfound />
          | "leapBandNotfound" => <LeapBandNotfound chainID />
          | "keplrNotfound" => <KeplrNotfound />
          | "keplrBandNotfound" => <KeplrBandNotfound />
          | "cosmostationNotfound" => <CosmostationNotfound />
          | "error" => <ErrorConnection />
          | "connectMnemonic" => <ConnectMnemonic chainID />
          | "connectLedger" => <ConnectLedger chainID />
          | _ => React.null
          }}
        </div>
      | _ => React.null
      }}
    </div>
  </div>
}
