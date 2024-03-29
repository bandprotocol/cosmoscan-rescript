module Styles = {
  open CssJs
  let barChart = style(. [
    width(#percent(100.)),
    height(#px(10)),
    borderRadius(#px(50)),
    overflow(#hidden),
  ])
  let barItem = (width_, color_) =>
    style(. [width(#percent(width_)), height(#percent(100.)), backgroundColor(color_)])
}

@react.component
let make = (~availableBalance, ~balanceAtStake, ~reward, ~unbonding, ~commission) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let totalBalance = availableBalance +. balanceAtStake +. unbonding +. reward +. commission
  let availableBalancePercent = totalBalance == 0. ? 0. : 100. *. availableBalance /. totalBalance
  let balanceAtStakePercent = totalBalance == 0. ? 0. : 100. *. balanceAtStake /. totalBalance
  let unbondingPercent = totalBalance == 0. ? 0. : 100. *. unbonding /. totalBalance
  let rewardPercent = totalBalance == 0. ? 0. : 100. *. reward /. totalBalance
  let commissionPercent = totalBalance == 0. ? 0. : 100. *. commission /. totalBalance

  <div className={CssJs.merge(. [Styles.barChart, CssHelper.flexBox()])}>
    <div className={Styles.barItem(availableBalancePercent, theme.primary_600)} />
    <div className={Styles.barItem(balanceAtStakePercent, theme.primary_500)} />
    <div className={Styles.barItem(unbondingPercent, theme.primary_200)} />
    <div className={Styles.barItem(rewardPercent, theme.primary_800)} />
    {commission == 0.
      ? React.null
      : <div className={Styles.barItem(commissionPercent, theme.neutral_200)} />}
  </div>
}
