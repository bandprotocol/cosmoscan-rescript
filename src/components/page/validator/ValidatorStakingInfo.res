module Styles = {
  open CssJs

  let rewardContainer = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.neutral_100),
      padding2(~v=#px(16), ~h=#px(24)),
      borderRadius(#px(8)),
    ])

  let buttonContainer = style(. [
    selector("> button + button", [marginLeft(#px(15))]),
    selector("> div + div", [marginLeft(#px(15))]),
  ])
}

module ButtonSection = {
  @react.component
  let make = (~delegatorAddress, ~validatorAddress) => {
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let validatorInfoSub = ValidatorSub.get(validatorAddress)
    let accountSub = AccountSub.get(delegatorAddress)
    let balanceAtStakeSub = DelegationSub.getStakeByValidator(delegatorAddress, validatorAddress)
    let allSub = Sub.all3(validatorInfoSub, accountSub, balanceAtStakeSub)

    let delegate = () =>
      Some(validatorAddress)->SubmitMsg.Delegate->SubmitTx->OpenModal->dispatchModal
    let undelegate = () =>
      validatorAddress->SubmitMsg.Undelegate->SubmitTx->OpenModal->dispatchModal
    let redelegate = () =>
      validatorAddress->SubmitMsg.Redelegate->SubmitTx->OpenModal->dispatchModal

    switch allSub {
    | Data((validatorInfo, {balance}, {amount: {amount}})) =>
      let disableNoBalance = balance->Coin.getBandAmountFromCoins == 0.
      let disableNoStake = amount == 0.
      <div
        className={Css.merge(list{CssHelper.flexBox(), Styles.buttonContainer})}
        id="validatorDelegationinfoDlegate">
        <Button
          px=20
          py=8
          disabled=disableNoBalance
          variant=Button.Text({underline: true})
          onClick={_ => {
            open Webapi.Dom
            validatorInfo.commission == 100.
              ? window->Window.alert("Delegation to foundation validator nodes is not advised.")
              : delegate()
          }}>
          {"Delegate"->React.string}
        </Button>
        <Button
          px=20
          py=8
          variant=Button.Text({underline: true})
          disabled=disableNoStake
          onClick={_ => undelegate()}>
          {"Undelegate"->React.string}
        </Button>
        <Button
          px=20
          py=8
          variant=Button.Text({underline: true})
          disabled=disableNoStake
          onClick={_ => redelegate()}>
          {"Redelegate"->React.string}
        </Button>
      </div>
    | _ =>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.buttonContainer})}>
        <LoadingCensorBar width=75 height=20 />
        <LoadingCensorBar width=75 height=20 />
        <LoadingCensorBar width=75 height=20 />
      </div>
    }
  }
}

module DisplayBalance = {
  module Loading = {
    @react.component
    let make = () => {
      <>
        <LoadingCensorBar width=120 height=15 />
        <VSpacing size=Spacing.sm />
        <LoadingCensorBar width=80 height=15 />
      </>
    }
  }

  @react.component
  let make = (~amount, ~usdPrice, ~isCountup=false) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <>
      <div className={CssHelper.flexBox()}>
        {isCountup
          ? <NumberCountUp
              value={amount->Coin.getBandAmountFromCoin}
              size=Text.Xl
              weight=Text.Bold
              color={theme.neutral_900}
              spacing={Text.Em(0.)}
              code=false
            />
          : <Text
              value={amount->Coin.getBandAmountFromCoin->Format.fPretty(~digits=6)}
              size=Text.Xl
              weight=Text.Bold
              color={theme.neutral_900}
              block=true
            />}
        <HSpacing size=Spacing.sm />
        <Text value="BAND" size=Text.Xl color={theme.neutral_900} weight=Text.Bold block=true />
      </div>
      <VSpacing size={Spacing.sm} />
      <div className={CssHelper.flexBox()}>
        <Text value="$" size=Text.Body2 color={theme.neutral_600} block=true />
        {isCountup
          ? <NumberCountUp
              value={amount->Coin.getBandAmountFromCoin *. usdPrice}
              size=Text.Body1
              weight=Text.Regular
              color={theme.neutral_600}
              code=false
              spacing={Text.Em(0.)}
            />
          : <Text
              value={(amount->Coin.getBandAmountFromCoin *. usdPrice)->Format.fPretty(~digits=6)}
              size=Text.Body1
              color={theme.neutral_600}
              block=true
            />}
      </div>
    </>
  }
}

module StakingInfo = {
  @react.component
  let make = (~delegatorAddress, ~validatorAddress) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let currentTime =
      React.useContext(TimeContext.context)->MomentRe.Moment.format(Config.timestampUseFormat, _)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let infoSub = React.useContext(GlobalContext.context)
    let balanceAtStakeSub = DelegationSub.getStakeByValidator(delegatorAddress, validatorAddress)
    let unbondingSub = UnbondingSub.getUnbondingBalanceByValidator(
      delegatorAddress,
      validatorAddress,
      currentTime,
    )

    let allSub = Sub.all3(infoSub, balanceAtStakeSub, unbondingSub)

    let withdrawReward = () => {
      validatorAddress->SubmitMsg.WithdrawReward->SubmitTx->OpenModal->dispatchModal
    }

    let reinvest = () => validatorAddress->SubmitMsg.Reinvest->SubmitTx->OpenModal->dispatchModal
    <>
      <Row>
        <Col col=Col.Six>
          <div className={CssHelper.flexBox()}>
            <Heading value="Delegated Amount (BAND)" size=Heading.H5 color={theme.neutral_600} />
            <HSpacing size=Spacing.xs />
            <CTooltip tooltipText="Delegated Amount.">
              <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
            </CTooltip>
          </div>
          <VSpacing size={Spacing.md} />
          {switch allSub {
          | Data(({financial: {usdPrice}}, balanceAtStake, _)) =>
            <DisplayBalance amount={balanceAtStake.amount} usdPrice />
          | _ => <DisplayBalance.Loading />
          }}
          <VSpacing size=Spacing.sm />
          <ButtonSection validatorAddress delegatorAddress />
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox()}>
            <Heading value="Unbonding Amount (BAND)" size=Heading.H5 color={theme.neutral_600} />
            <HSpacing size=Spacing.xs />
            <CTooltip tooltipText="Unbonding Amount.">
              <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
            </CTooltip>
          </div>
          <VSpacing size={Spacing.md} />
          {switch allSub {
          | Data(({financial: {usdPrice}}, _, unbonding)) =>
            <DisplayBalance amount=unbonding usdPrice />
          | _ => <DisplayBalance.Loading />
          }}
          <VSpacing size=Spacing.sm />
          // TODO: wire up
          <Text value="4d 18h:29m:17s" size=Text.Body1 weight=Text.Thin color={theme.neutral_900} />
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox()}>
            <Heading value="Reward (BAND)" size=Heading.H5 color={theme.neutral_600} />
            <HSpacing size=Spacing.xs />
            <CTooltip tooltipText="Reward.">
              <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
            </CTooltip>
          </div>
          <VSpacing size=Spacing.md />
          {switch allSub {
          | Data(({financial: {usdPrice}}, balanceAtStake, _)) =>
            <DisplayBalance amount={balanceAtStake.reward} usdPrice isCountup=true />
          | _ => <DisplayBalance.Loading />
          }}
          <VSpacing size=Spacing.sm />
          <div
            className={Css.merge(list{CssHelper.flexBox(), Styles.buttonContainer})}
            id="withdrawRewardContainer">
            {
              let (disable, reward) = switch allSub {
              | Data((_, balanceAtStake, _)) => (
                  balanceAtStake.reward.amount <= 0.,
                  balanceAtStake.reward.amount,
                )
              | _ => (true, 0.)
              }

              <>
                <Button
                  px=20
                  py=8
                  variant=Button.Text({underline: true})
                  onClick={_ => withdrawReward()}
                  disabled=disable>
                  {"Claim"->React.string}
                </Button>
                <Button
                  px=20
                  py=8
                  variant=Button.Text({underline: true})
                  onClick={_ => reinvest()}
                  disabled=disable>
                  {"Reinvest"->React.string}
                </Button>
              </>
            }
          </div>
        </Col>
      </Row>
    </>
  }
}

@react.component
let make = (~validatorAddress) => {
  let trackingSub = TrackingSub.use()
  let (accountOpt, _) = React.useContext(AccountContext.context)
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (accountBoxState, setAccountBoxState, _, _) = React.useContext(WalletPopupContext.context)

  let connect = () =>
    accountBoxState == "noShow"
      ? setAccountBoxState(_ => "connect")
      : setAccountBoxState(_ => "noShow")

  <InfoContainer py=40>
    <Heading value="My Delegation" size=Heading.H4 />
    <SeperatedLine mt=16 mb=16 />
    {switch accountOpt {
    | Some({address: delegatorAddress}) => <StakingInfo validatorAddress delegatorAddress />
    | None =>
      switch trackingSub {
      | Data(_) =>
        <div
          className={Css.merge(list{CssHelper.flexBox(~direction=#column, ~justify=#center, ())})}>
          <Icon name="fal fa-link" size=32 color={isDarkMode ? theme.white : theme.black} />
          <VSpacing size=Spacing.sm />
          <Text value="Connect Wallet to see Delegation Info" size=Text.Body1 nowrap=true />
          <VSpacing size=Spacing.sm />
          <Button px=24 py=7 variant=Outline onClick={_ => connect()}>
            {"Connect Wallet"->React.string}
          </Button>
        </div>
      | Error(err) =>
        // log for err details
        Js.Console.log(err)
        <Text value="chain id not found" />
      | _ => <LoadingCensorBar.CircleSpin height=200 />
      }
    }}
  </InfoContainer>
}
