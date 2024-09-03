@react.component
let make = (~address, ~hashtag: Route.account_tab_t) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
  let currentTime =
    React.useContext(TimeContext.context)->MomentRe.Moment.format(Config.timestampUseFormat, _)
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  let infoSub = React.useContext(GlobalContext.context)
  let accountSub = AccountSub.get(address)
  let balanceAtStakeSub = DelegationSub.getTotalStakeByDelegator(address)
  let unbondingSub = UnbondingSub.getUnbondingBalance(address, currentTime)
  let trackingSub = TrackingSub.use()

  let topPartAllSub = Sub.all5(infoSub, accountSub, balanceAtStakeSub, unbondingSub, trackingSub)

  let sumBalance = (balance, amount, unbonding, reward, commission) => {
    let availableBalance = balance->Coin.getBandAmountFromCoins
    let balanceAtStakeAmount = amount->Coin.getBandAmountFromCoin
    let unbondingAmount = unbonding->Coin.getBandAmountFromCoin
    let rewardAmount = reward->Coin.getBandAmountFromCoin
    let commissionAmount = commission->Coin.getBandAmountFromCoins

    availableBalance +. balanceAtStakeAmount +. rewardAmount +. unbondingAmount +. commissionAmount
  }
  let send = (chainID, sender) => {
    let openSendModal = () =>
      SubmitMsg.Send(Some(address), IBCConnectionQuery.BAND)->SubmitTx->OpenModal->dispatchModal

    switch sender == address {
    | true =>
      open Webapi.Dom
      window->Window.confirm("Are you sure you want to send tokens to yourself?")
        ? openSendModal()
        : ()
    | false => openSendModal()
    }
  }

  let qrCode = () => address->QRCode->OpenModal->dispatchModal

  <Section>
    <div className=CssHelper.container>
      <Row marginBottom=24 marginBottomSm=24>
        <Col>
          <Heading value="Account Details" size=Heading.H1 />
        </Col>
      </Row>
      <Row marginBottom=16 marginBottomSm=24>
        <Col col=Col.Three mbSm=8>
          <Text value="Band Address" size=Body1 />
        </Col>
        <Col col=Col.Nine>
          <AddressRender address position=AddressRender.Subtitle copy=true clickable=false />
        </Col>
      </Row>
      <Row marginBottom=16 marginBottomSm=24>
        <Col col=Col.Three mbSm=8>
          <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
            <Text value="Operator Address" size=Body1 />
            <HSpacing size={#px(4)} />
            <CTooltip tooltipText="The address used to show the validator's entity status">
              <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
            </CTooltip>
          </div>
        </Col>
        <Col col=Col.Nine>
          <AddressRender address position=AddressRender.Subtitle copy=true accountType=#validator />
        </Col>
      </Row>
      // TODO: wire up
      <Row marginBottom=40 marginBottomSm=40>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
            <Text value="Counter Party Address" size=Body1 />
            <HSpacing size={#px(4)} />
            <CTooltip tooltipText="The address used to show the counter party's entity status">
              <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
            </CTooltip>
          </div>
        </Col>
        <Col col=Col.Nine>
          <AddressRender address position=AddressRender.Subtitle copy=true clickable=false />
        </Col>
      </Row>
      <Tab.Route
        tabs=[
          {name: "Portfolio", route: Route.AccountIndexPage(address, AccountPortfolio)},
          {name: "Transaction", route: Route.AccountIndexPage(address, AccountTransaction)},
        ]
        currentRoute=Route.AccountIndexPage(address, hashtag)>
        {switch hashtag {
        | AccountPortfolio => <AccountIndexPortfolio address />
        | AccountTransaction => <AccountIndexTransactions accountAddress=address />
        }}
      </Tab.Route>
    </div>
  </Section>
}
