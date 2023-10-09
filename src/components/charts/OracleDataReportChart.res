// Remark: Only for mock data purpose
module OracleStatus = {
  type t =
    | Active
    | Inactive
    | NoData

  type mock_t = {
    status: t,
    size: float,
  }

  let allActive = [{status: Active, size: 100.}]
  let someInactive = [{status: Inactive, size: 20.}, {status: Active, size: 80.}]
  let noData = [{status: NoData, size: 100.}]
  let allOf3 = [
    {status: NoData, size: 20.},
    {status: Inactive, size: 50.},
    {status: Active, size: 30.},
  ]
  let allNoData = [{status: NoData, size: 100.}]
}

module Styles = {
  open CssJs
  let chartWrapper = style(. [minHeight(px(160))])
  let chartContainer = style(. [
    width(#percent(80.)),
    minHeight(#px(156)),
    margin2(~v=#zero, ~h=#auto),
    Media.mobile([width(#px(240))]),
  ])
  let blockContainer = style(. [
    flexGrow(0.),
    flexShrink(0.),
    flexBasis(#calc((#sub, #percent(3.33), #px(2)))),
    margin(#px(1)),
    height(#px(32)),
    display(#block),
  ])

  let statusColor = (~theme: Theme.t, ~status, ()) =>
    switch status {
    | OracleStatus.Active => style(. [backgroundColor(theme.success_600)])
    | Inactive => style(. [backgroundColor(theme.error_600)])
    | NoData => style(. [backgroundColor(theme.neutral_300)])
    }

  let statusBar = style(. [
    width(#percent(100.)),
    height(#percent(100.)),
    borderRadius(#px(2)),
    overflow(#hidden),
  ])
  // use inside each status bar
  let partitionArea = (~h, ~theme: Theme.t, ~status, ()) => {
    let base = style(. [width(#percent(100.)), height(h)])

    merge2(. base, statusColor(~theme, ~status, ()))
  }

  let labelStatus = (~theme: Theme.t, ~status, ()) => {
    let base = style(. [
      height(#px(12)),
      width(#px(12)),
      borderRadius(#px(2)),
      borderRadius(#px(2)),
    ])

    merge2(. base, statusColor(~theme, ~status, ()))
  }
}

let getDayAgo = days => {
  MomentRe.momentNow()
  ->MomentRe.Moment.defaultUtc
  ->MomentRe.Moment.subtract(~duration=MomentRe.duration(days->Belt.Int.toFloat, #days))
}

module Item = {
  @react.component
  let make = (~statuses, ~timestamp) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

    <CTooltip
      width=100
      tooltipPlacement=CTooltip.Top
      tooltipPlacementSm=CTooltip.BottomLeft
      mobile=false
      align=#center
      pd=10
      tooltipText={MomentRe.Moment.format("YYYY-MM-DD", MomentRe.momentWithUnix(timestamp))}
      styles=Styles.blockContainer>
      <div
        className={Css.merge(list{
          Styles.statusBar,
          CssHelper.flexBox(~direction=#columnReverse, ()),
        })}>
        {statuses
        ->Belt.Array.mapWithIndex((i, {OracleStatus.status: status, size}) =>
          <div
            key={i->Belt.Int.toString ++ timestamp->Belt.Int.toString ++ size->Belt.Float.toString}
            className={Styles.partitionArea(~h=#percent(size), ~theme, ~status, ())}
          />
        )
        ->React.array}
      </div>
    </CTooltip>
  }
}

@react.component
let make = (~oracleStatus, ~operatorAddress) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
  let (prevDate, setPrevDate) = React.useState(_ => getDayAgo(90))
  React.useEffect0(() => {
    let timeOutID = Js.Global.setInterval(() => {setPrevDate(_ => getDayAgo(90))}, 60_000)
    Some(() => {Js.Global.clearInterval(timeOutID)})
  })

  let historicalOracleStatusSub = ValidatorSub.getHistoricalOracleStatus(
    operatorAddress,
    prevDate,
    oracleStatus,
  )

  <>
    <div className={Css.merge(list{CssHelper.flexBox(), Styles.chartWrapper})}>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.chartContainer})}>
        {switch historicalOracleStatusSub {
        | Data({oracleStatusReports}) =>
          oracleStatusReports
          ->Belt.Array.mapWithIndex((i, {timestamp, status}) =>
            <Item
              key={i->Belt.Int.toString ++ timestamp->Belt.Int.toString}
              // TODO: To be implemented
              statuses={OracleStatus.allOf3}
              timestamp
            />
          )
          ->React.array
        | _ => <LoadingCensorBar.CircleSpin height=90 />
        }}
      </div>
    </div>
    <VSpacing size=#px(24) />
    <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
      <div className={CssHelper.flexBox()}>
        <div className={Styles.labelStatus(~theme, ~status=OracleStatus.Active, ())} />
        <HSpacing size=Spacing.sm />
        <Text block=true value="Uptime" weight=Text.Semibold />
      </div>
      // TODO: wire up
      {switch historicalOracleStatusSub {
      | Data({uptimeCount}) => <Text block=true value="99.23%" weight=Bold size=Body1 />
      | _ => <LoadingCensorBar width=20 height=14 />
      }}
    </div>
    <VSpacing size={#px(10)} />
    <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
      <div className={CssHelper.flexBox()}>
        <div className={Styles.labelStatus(~theme, ~status=OracleStatus.Inactive, ())} />
        <HSpacing size=Spacing.sm />
        <Text block=true value="Downtime" weight=Text.Semibold />
        <HSpacing size=Spacing.sm />
        <CTooltip
          tooltipText="Downtime refers to the status of the oracle when the validator fails to submit a report within the last 100 blocks.">
          <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
        </CTooltip>
      </div>
      // TODO: wire up
      {switch historicalOracleStatusSub {
      | Data({downtimeCount}) => <Text block=true value="0.77%" weight=Bold size=Body1 />
      | _ => <LoadingCensorBar width=20 height=14 />
      }}
    </div>
    <VSpacing size={#px(10)} />
    <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
      <div className={CssHelper.flexBox()}>
        <div className={Styles.labelStatus(~theme, ~status=OracleStatus.NoData, ())} />
        <HSpacing size=Spacing.sm />
        <Text block=true value="No Data" weight=Text.Semibold />
      </div>
      // To be implemented NoData case
    </div>
  </>
}
