module Styles = {
  open CssJs

  let balanceBox = (theme: Theme.t) =>
    style(. [
      display(#flex),
      flexDirection(#column),
      justifyContent(#center),
      alignItems(#center),
      padding(#px(16)),
      marginTop(#px(16)),
      backgroundColor(theme.neutral_100),
      borderRadius(#px(8)),
    ])

  let btnIcon = style(. [width(#px(24)), height(#px(24)), marginRight(#px(8))])

  let actionContainer = style(. [marginTop(#px(16))])
  let bandBalance = style(. [
    display(#flex),
    marginTop(#px(8)),
    marginBottom(#px(4)),
    alignItems(#baseline),
  ])
}

module AccountDetailBtn = {
  @react.component
  let make = (~address, ~setAccountBoxState) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <Link
      className={Css.merge(list{
        CssHelper.flexBox(~justify=#flexStart, ~align=#center, ()),
        CssHelper.clickable,
        CssHelper.mt(~size=16, ()),
      })}
      route=Route.AccountIndexPage(address, Route.AccountDelegations)
      onClick={_ => setAccountBoxState(_ => "noShow")}>
      <ReactSvg src={Images.circleUser} className={Styles.btnIcon} />
      <Text
        value="Account Details" weight=Text.Medium color=theme.neutral_900 nowrap=true block=true
      />
    </Link>
  }
}

module SendBtn = {
  @react.component
  let make = (~send) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div
      id="sendToken"
      className={Css.merge(list{
        CssHelper.flexBox(~justify=#flexStart, ~align=#center, ()),
        CssHelper.clickable,
        CssHelper.mt(~size=16, ()),
      })}
      onClick={_ => send()}>
      <ReactSvg src={Images.arrowUpright} className={Styles.btnIcon} />
      <Text value="Send Token" weight=Text.Medium color=theme.neutral_900 nowrap=true block=true />
    </div>
  }
}

module FaucetBtn = {
  @react.component
  let make = (~address) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let (isRequest, setIsRequest) = React.useState(_ => false)
    let (isFailed, setIsFailed) = React.useState(_ => false)
    let trackingSub = TrackingSub.use()
    let getBandFaucet = () => {
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
    }

    {
      switch trackingSub {
      | Data({chainID}) => {
          let currentChainID = chainID->ChainIDBadge.parseChainID
          currentChainID == LaoziTestnet
            ? isRequest
                ? <LoadingCensorBar.CircleSpin size=30 height=30 />
                : isFailed
                ? <Text
                  size=Text.Caption
                  color={theme.error_600}
                  value="Too many Request. try again later"
                />
                : <div
                    id="getFreeButton"
                    className={Css.merge(list{
                      CssHelper.flexBox(~justify=#flexStart, ~align=#center, ()),
                      CssHelper.clickable,
                      CssHelper.mt(~size=16, ()),
                    })}
                    onClick={_ => getBandFaucet()}>
                    <ReactSvg src={Images.arrowBottomleft} className={Styles.btnIcon} />
                    <Text
                      value="Get 10 faucet BAND"
                      weight=Text.Medium
                      color=theme.neutral_900
                      nowrap=true
                      block=true
                    />
                  </div>
            : React.null
        }

      | _ => React.null
      }
    }
  }
}

module DisconnectBtn = {
  @react.component
  let make = (~disconnect) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div
      className={Css.merge(list{
        CssHelper.flexBox(~justify=#flexStart, ~align=#center, ()),
        CssHelper.clickable,
        CssHelper.mt(~size=16, ()),
      })}
      onClick={_ => disconnect()}>
      <ReactSvg src={Images.logOut} className={Styles.btnIcon} />
      <Text value="Disconnect" weight=Text.Medium color=theme.error_600 nowrap=true block=true />
    </div>
  }
}

module Balance = {
  @react.component
  let make = (~address) => {
    let accountSub = AccountSub.get(address)
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let infoSub = React.useContext(GlobalContext.context)

    {
      switch (accountSub, infoSub) {
      | (Data(account), Data({financial})) =>
        <div className={Styles.balanceBox(theme)}>
          <Text value="Available Balance" weight=Text.Semibold color=theme.neutral_600 />
          <div className=Styles.bandBalance>
            <Text
              value={account.balance->Coin.getBandAmountFromCoins->Format.fPretty(~digits=6)}
              code=true
              color=theme.neutral_900
              size={Xxxl}
            />
            <HSpacing size=Spacing.sm />
            <Text value="BAND" size={Body1} color=theme.neutral_900 />
          </div>
          <Text
            value={
              let usdPrice = account.balance->Coin.getBandAmountFromCoins *. financial.usdPrice

              `$${usdPrice->Format.fPretty(~digits=2)} USD`
            }
            size={Body2}
            color=theme.neutral_600
          />
        </div>
      | (Error(_), _) =>
        <Text value="Error occur while getting account" weight=Text.Medium color=theme.error_600 />
      | (_, Error(_)) =>
        <Text
          value="Error occur while getting BAND price" weight=Text.Medium color=theme.error_600
        />
      | (_, _) => <LoadingCensorBar mt=16 mb=16 fullWidth=true height=30 />
      }
    }
  }
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)
  let trackingSub = TrackingSub.use()
  let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)
  let (_, setAccountBoxState, _, _) = React.useContext(WalletPopupContext.context)

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
          <AddressRender address position=AddressRender.Text copy=true clickable=false />
        </div>
        <Balance address />
        <div className={Styles.actionContainer}>
          <AccountDetailBtn address setAccountBoxState />
          <FaucetBtn address />
          <SendBtn send />
        </div>
        <SeperatedLine />
        <DisconnectBtn disconnect />
      </div>
    | None => React.null
    }
  }
}
