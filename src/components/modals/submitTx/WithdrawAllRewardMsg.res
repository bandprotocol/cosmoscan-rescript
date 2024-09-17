module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(24)), width(#px(500))])
  let heading = style(. [paddingBottom(#px(8))])

  let delegationsContainer = (theme: Theme.t) =>
    style(. [
      borderTop(#px(1), #solid, theme.neutral_300),
      maxHeight(#px(276)),
      overflowY(#scroll),
      overflowX(#hidden),
    ])

  let rewardDetailContainer = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_300),
      marginTop(#px(16)),
      paddingBottom(#px(16)),
    ])
}

@react.component
let make = (~address, ~setMsgsOpt, ~delegations: array<DelegationSub.Stake.t>) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let delegationsSub = DelegationSub.getStakeList(address, ~pageSize=9999, ~page=1, ())
  let infoSub = React.useContext(GlobalContext.context)

  React.useEffect0(_ => {
    let msgsOpt = {
      Some(
        delegations->Belt.Array.map(d => Msg.Input.WithdrawRewardMsg({
          delegatorAddress: address,
          validatorAddress: d.operatorAddress,
          amount: (),
          moniker: (),
          identity: (),
        })),
      )
    }
    setMsgsOpt(_ => msgsOpt)

    None
  })

  <div className=Styles.container>
    <Row style={Styles.heading}>
      <Col col=Col.Six>
        <Text value="Withdraw Delegation Reward From" size={Body2} />
      </Col>
      <Col col=Col.Six>
        <Text value="Current Rewards (BAND)" size={Body2} />
      </Col>
    </Row>
    {switch delegationsSub {
    | Data(delegations) =>
      let totalReward =
        delegations->Belt.Array.reduce(0., (acc, delegation) =>
          acc +. delegation.reward->Coin.getBandAmountFromCoin
        )
      <>
        <div className={Styles.delegationsContainer(theme)}>
          {delegations
          ->Belt.Array.map(delegation =>
            <Row style={Styles.rewardDetailContainer(theme)}>
              <Col col=Col.Six>
                <div>
                  <Text
                    value={delegation.moniker}
                    size={Body1}
                    color={theme.neutral_900}
                    weight={Semibold}
                  />
                  <Text
                    value={delegation.operatorAddress->Address.toOperatorBech32}
                    size={Body2}
                    ellipsis=true
                  />
                </div>
              </Col>
              <Col col=Col.Six>
                <NumberCountUp
                  value={delegation.reward->Coin.getBandAmountFromCoin}
                  size={Text.Body1}
                  color={theme.neutral_900}
                  weight={Text.Semibold}
                  decimals=6
                />
              </Col>
            </Row>
          )
          ->React.array}
        </div>
        <div className={CssHelper.mt(~size=24, ())}>
          <Heading
            value="Total Reward Amount (BAND)"
            size=Heading.H5
            align=Heading.Left
            weight=Heading.Regular
            marginBottom=4
            color={theme.neutral_600}
          />
          <div>
            <NumberCountUp
              value={totalReward}
              size={Text.Xl}
              color={theme.neutral_900}
              weight={Text.Bold}
              decimals=6
            />
            <VSpacing size={#px(4)} />
            {switch infoSub {
            | Data({financial}) =>
              <Text
                size={Body2}
                code=true
                value={`$${(totalReward *. financial.usdPrice)->Format.fPretty(~digits=2)} USD`}
              />
            | _ => <LoadingCensorBar width=50 height=20 />
            }}
          </div>
        </div>
      </>
    | _ => <LoadingCensorBar.CircleSpin height=180 />
    }}
  </div>
}
