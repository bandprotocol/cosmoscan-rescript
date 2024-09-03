module Styles = {
  open CssJs

  let squareIcon = color =>
    style(. [width(#px(8)), marginRight(#px(8)), height(#px(8)), backgroundColor(color)])

  let balance = style(. [minWidth(#px(150)), justifyContent(#flexEnd)])

  let allBalancesContainer = (~theme: Theme.t, ()) =>
    style(. [
      selector("> div", [padding2(~v=#px(16), ~h=zero)]),
      selector("> div + div", [borderTop(#px(1), solid, theme.neutral_200)]),
    ])
}

module BalanceDetailLoading = {
  @react.component
  let make = () =>
    <Row>
      <Col col=Col.Six colSm=Col.Five>
        <LoadingCensorBar width=130 height=20 />
        <VSpacing size=Spacing.xs />
        <LoadingCensorBar width=60 height=16 />
      </Col>
      <Col col=Col.Six colSm=Col.Seven>
        <div className={CssHelper.flexBox(~direction=#column, ~align=#flexEnd, ())}>
          <LoadingCensorBar width=120 height=20 />
          <VSpacing size=Spacing.xs />
          <LoadingCensorBar width=120 height=16 />
        </div>
      </Col>
    </Row>
}

module BalanceDetails = {
  @react.component
  let make = (
    ~title,
    ~description,
    ~amount,
    ~percent,
    ~usdPrice,
    ~color,
    ~isCountup=false,
    ~showZero=false,
  ) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

    <Row>
      <Col col=Col.Six colSm=Col.Five>
        <div className={CssHelper.flexBox()}>
          <div className={Styles.squareIcon(color)} />
          <Text value=title size=Text.Body1 weight=Text.Semibold color=theme.neutral_900 />
          <HSpacing size=Spacing.xs />
          <CTooltip tooltipPlacementSm=CTooltip.BottomLeft tooltipText=description>
            <Icon name="fal fa-info-circle" size=16 />
          </CTooltip>
        </div>
        <div className={CssHelper.ml(~size=24, ())}>
          <Text
            value={percent != 0. ? percent->Format.fPercent : "-"} color=theme.neutral_600 code=true
          />
        </div>
      </Col>
      <Col col=Col.Six colSm=Col.Seven>
        <div className={CssHelper.flexBox(~direction=#column, ~align=#flexEnd, ())}>
          <div className={CssHelper.flexBox()}>
            {amount == 0. && !showZero
              ? <Text value="-" size=Body1 weight=Bold />
              : isCountup
              ? <NumberCountUp
                value=amount size=Text.Body1 weight=Text.Bold color=theme.neutral_900 decimals=6
              />
              : <Text
                  value={amount->Format.fPretty(~digits=6)}
                  size=Text.Body1
                  weight=Text.Bold
                  nowrap=true
                  code=true
                  color=theme.neutral_900
                />}
            <HSpacing size=Spacing.sm />
            <Text
              value="BAND"
              size=Text.Caption
              weight=Text.Thin
              nowrap=true
              color=theme.neutral_900
              height={Px(19)}
            />
          </div>
          <VSpacing size=Spacing.xs />
          <div className={CssJs.merge(. [CssHelper.flexBox(), Styles.balance])}>
            {
              let amountInUsdPrice = amount *. usdPrice

              amountInUsdPrice === 0. && !showZero
                ? <Text value="-" code=true />
                : <>
                    <Text value="$" weight=Text.Thin nowrap=true />
                    {isCountup
                      ? <NumberCountUp
                          value={amountInUsdPrice}
                          size=Text.Body2
                          weight=Text.Thin
                          spacing=Text.Em(0.02)
                          color=theme.neutral_600
                        />
                      : <Text
                          value={amountInUsdPrice->Format.fPretty(~digits=2)}
                          size=Text.Body2
                          spacing=Text.Em(0.02)
                          weight=Text.Thin
                          nowrap=true
                          code=true
                        />}
                  </>
            }
          </div>
        </div>
      </Col>
    </Row>
  }
}

@react.component
let make = (~address) => {
  // tab
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let setTab = index => setTabIndex(_ => index)

  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let qrCode = () => address->QRCode->OpenModal->dispatchModal
  let (accountBoxState, setAccountBoxState, _, _) = React.useContext(WalletPopupContext.context)

  let connect = () =>
    accountBoxState == "noShow"
      ? setAccountBoxState(_ => "connect")
      : setAccountBoxState(_ => "noShow")

  let (accountOpt, _) = AccountContext.use()
  let send = chainID =>
    switch accountOpt {
    | Some({address: sender}) =>
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
    | None => connect()
    }

  let currentTime =
    React.useContext(TimeContext.context)->MomentRe.Moment.format(Config.timestampUseFormat, _)

  let accountSub = AccountSub.get(address)
  let trackingSub = TrackingSub.use()
  let balanceAtStakeSub = DelegationSub.getTotalStakeByDelegator(address)
  let infoSub = React.useContext(GlobalContext.context)
  let unbondingSub = UnbondingSub.getUnbondingBalance(address, currentTime)

  let topPartAllSub = Sub.all5(infoSub, accountSub, balanceAtStakeSub, unbondingSub, trackingSub)

  let calculateRatioAndTotal = React.useCallback0((
    balance,
    delegated,
    unbonding,
    reward,
    commission,
  ) => {
    let availableBalance = balance->Coin.getBandAmountFromCoins
    let delegatedAmount = delegated->Coin.getBandAmountFromCoin
    let unbondingAmount = unbonding->Coin.getBandAmountFromCoin
    let rewardAmount = reward->Coin.getBandAmountFromCoin
    let commissionAmount = commission->Coin.getBandAmountFromCoins

    let totalBalance =
      availableBalance +. delegatedAmount +. rewardAmount +. unbondingAmount +. commissionAmount

    let availableBalancePercent = totalBalance == 0. ? 0. : 100. *. availableBalance /. totalBalance
    let delegatedPercent = totalBalance == 0. ? 0. : 100. *. delegatedAmount /. totalBalance
    let unbondingPercent = totalBalance == 0. ? 0. : 100. *. unbondingAmount /. totalBalance
    let rewardPercent = totalBalance == 0. ? 0. : 100. *. rewardAmount /. totalBalance
    let commissionPercent = totalBalance == 0. ? 0. : 100. *. commissionAmount /. totalBalance

    (
      [
        availableBalancePercent,
        commissionPercent,
        delegatedPercent,
        rewardPercent,
        unbondingPercent,
      ],
      totalBalance,
    )
  })

  let colors = [
    theme.primary_600,
    theme.primary_800,
    theme.success_600,
    theme.success_800,
    theme.warning_600,
  ]

  <>
    <Row marginTop=40 marginTopSm=24 marginBottom=40 marginBottomSm=24>
      <Col>
        <InfoContainer>
          <Row>
            <Col col=Col.Six>
              <Heading
                value="Total Balance" size=Heading.H4 color=theme.neutral_600 marginBottom=8
              />
              {switch topPartAllSub {
              | Data(({financial}, {balance, commission}, {amount, reward}, unbonding, _)) => {
                  let (allPercents, totalBalanceBAND) = calculateRatioAndTotal(
                    balance,
                    amount,
                    unbonding,
                    reward,
                    commission,
                  )
                  let totalBalanceUSD = totalBalanceBAND *. financial.usdPrice

                  <>
                    <TotalBalanceBandRender totalBalanceBAND />
                    <VSpacing size=Spacing.xs />
                    <div className={CssHelper.flexBox()}>
                      <Text value="$" size=Body1 code=true />
                      <NumberCountUp
                        value={totalBalanceUSD}
                        size=Text.Body1
                        weight=Text.Regular
                        color=theme.neutral_600
                      />
                    </div>
                    <VSpacing size=Spacing.xl />
                    <AccountBalanceChart data=allPercents colors />
                  </>
                }

              | _ =>
                <>
                  <LoadingCensorBar width=200 height=30 mb=8 mt=8 mbSm=8 />
                  <LoadingCensorBar width=150 height=20 />
                  <VSpacing size=Spacing.xl />
                  <LoadingCensorBar.CircleSpin size={180} height={200} />
                </>
              }}
            </Col>
            <Col col=Col.Six mtSm=24>
              <Heading value="BAND Distribution" color=theme.neutral_600 size=Heading.H4 />
              <div className={Styles.allBalancesContainer(~theme, ())}>
                <div>
                  {switch topPartAllSub {
                  | Data((
                      {financial},
                      {balance, commission},
                      {amount, reward},
                      unbonding,
                      {chainID},
                    )) => {
                      let (allPercents, _) = calculateRatioAndTotal(
                        balance,
                        amount,
                        unbonding,
                        reward,
                        commission,
                      )
                      <>
                        <BalanceDetails
                          title="Available"
                          description="Balance available to send, delegate, etc"
                          amount={balance->Coin.getBandAmountFromCoins}
                          usdPrice=financial.usdPrice
                          color={colors[0]}
                          percent={allPercents[0]}
                          showZero=true
                        />
                        {isMobile || accountOpt->Belt.Option.isNone
                          ? React.null
                          : <div
                              className={Css.merge(list{
                                CssHelper.flexBox(~cGap=#px(16), ~justify=#flexEnd, ()),
                                CssHelper.mt(~size=8, ()),
                              })}>
                              <Button variant=Button.Outline onClick={_ => send(chainID)} fsize=14>
                                {"Send"->React.string}
                              </Button>
                              // TODO: wire up
                              <Button variant=Button.Outline fsize=14>
                                {"Delegate"->React.string}
                              </Button>
                            </div>}
                      </>
                    }

                  | _ => <BalanceDetailLoading />
                  }}
                </div>
                {switch topPartAllSub {
                | Data((
                    {financial},
                    {balance, commission},
                    {amount, reward},
                    unbonding,
                    {chainID},
                  )) => {
                    let (allPercents, _) = calculateRatioAndTotal(
                      balance,
                      amount,
                      unbonding,
                      reward,
                      commission,
                    )
                    let commissionAmount = commission->Coin.getBandAmountFromCoins
                    commissionAmount == 0.
                      ? React.null
                      : <div>
                          <BalanceDetails
                            title="Commission"
                            description="Reward commission from delegator's reward"
                            amount=commissionAmount
                            usdPrice=financial.usdPrice
                            isCountup=true
                            color={colors[1]}
                            percent={allPercents[1]}
                          />
                        </div>
                  }

                | _ => React.null
                }}
                <div>
                  {switch topPartAllSub {
                  | Data((
                      {financial},
                      {balance, commission},
                      {amount, reward},
                      unbonding,
                      {chainID},
                    )) => {
                      let (allPercents, _) = calculateRatioAndTotal(
                        balance,
                        amount,
                        unbonding,
                        reward,
                        commission,
                      )
                      <BalanceDetails
                        title="Delegated"
                        description="Balance currently delegated to validators"
                        amount={amount->Coin.getBandAmountFromCoin}
                        usdPrice=financial.usdPrice
                        color={colors[2]}
                        percent={allPercents[2]}
                      />
                    }

                  | _ => <BalanceDetailLoading />
                  }}
                </div>
                <div>
                  {switch topPartAllSub {
                  | Data((
                      {financial},
                      {balance, commission},
                      {amount, reward},
                      unbonding,
                      {chainID},
                    )) => {
                      let (allPercents, _) = calculateRatioAndTotal(
                        balance,
                        amount,
                        unbonding,
                        reward,
                        commission,
                      )
                      <BalanceDetails
                        title="Reward"
                        description="Reward from staking to validators"
                        amount={reward->Coin.getBandAmountFromCoin}
                        usdPrice=financial.usdPrice
                        color={colors[3]}
                        percent={allPercents[3]}
                        isCountup=true
                      />
                    }

                  | _ => <BalanceDetailLoading />
                  }}
                </div>
                <div>
                  {switch topPartAllSub {
                  | Data((
                      {financial},
                      {balance, commission},
                      {amount, reward},
                      unbonding,
                      {chainID},
                    )) => {
                      let (allPercents, _) = calculateRatioAndTotal(
                        balance,
                        amount,
                        unbonding,
                        reward,
                        commission,
                      )
                      <BalanceDetails
                        title="Unbonding"
                        description="Amount undelegated from validators awaiting 21 days lockup period"
                        amount={unbonding->Coin.getBandAmountFromCoin}
                        usdPrice=financial.usdPrice
                        color={colors[4]}
                        percent={allPercents[4]}
                      />
                    }

                  | _ => <BalanceDetailLoading />
                  }}
                </div>
              </div>
            </Col>
          </Row>
        </InfoContainer>
      </Col>
    </Row>
    <Row marginBottom=24 marginBottomSm=16>
      <Col>
        <InfoContainer>
          <Tab.State tabs=["Delegations", "Unbonding", "Redelegate"] tabIndex setTab>
            {switch tabIndex {
            | 1 => <AccountIndexUnbonding address />
            // Remark: The design doesn't include this table.
            | 2 => <AccountIndexRedelegate address />
            | _ => <AccountIndexDelegations address />
            }}
          </Tab.State>
        </InfoContainer>
      </Col>
    </Row>
  </>
}
