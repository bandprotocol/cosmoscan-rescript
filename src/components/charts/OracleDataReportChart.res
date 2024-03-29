module Styles = {
  open CssJs
  let chartWrapper = style(. [minHeight(px(220))])
  let chartContainer = style(. [
    width(#percent(100.)),
    minHeight(#px(90)),
    margin2(~v=#zero, ~h=#px(-2)),
  ])
  let blockContainer = style(. [
    flexGrow(0.),
    flexShrink(0.),
    flexBasis(#calc((#sub, #percent(3.33), #px(2)))),
    margin(#px(1)),
    height(#px(40)),
    display(#block),
  ])
  let blockBase = style(. [width(#percent(100.)), height(#percent(100.))])
  let labelBox = style(. [
    margin2(~v=#zero, ~h=#auto),
    maxWidth(#px(300)),
    selector(
      "> div",
      [
        flexGrow(0.),
        flexShrink(0.),
        flexBasis(#calc((#sub, #percent(50.), #px(48)))),
        margin2(~v=#zero, ~h=#px(24)),
      ],
    ),
  ])
  let statusLabel = style(. [height(#px(8)), width(#px(8))])
  let status = status => style(. [backgroundColor(status ? hex("4520E6") : hex("937EF1"))])
}

let getDayAgo = days => {
  MomentRe.momentNow()
  ->MomentRe.Moment.defaultUtc
  ->MomentRe.Moment.subtract(~duration=MomentRe.duration(days->Belt.Int.toFloat, #days))
}

module Item = {
  @react.component
  let make = (~status, ~timestamp) => {
    <CTooltip
      width=100
      tooltipPlacement=CTooltip.Top
      tooltipPlacementSm=CTooltip.BottomLeft
      mobile=false
      align=#center
      pd=10
      tooltipText={MomentRe.Moment.format("YYYY-MM-DD", MomentRe.momentWithUnix(timestamp))}
      styles=Styles.blockContainer>
      <div className={Css.merge(list{Styles.blockBase, Styles.status(status)})} />
    </CTooltip>
  }
}

@react.component
let make = (~oracleStatus, ~operatorAddress) => {
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
    <Row marginBottom=24>
      <Col>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.chartWrapper})}>
          <div className={Css.merge(list{CssHelper.flexBox(), Styles.chartContainer})}>
            {switch historicalOracleStatusSub {
            | Data({oracleStatusReports}) =>
              oracleStatusReports
              ->Belt.Array.mapWithIndex((i, {timestamp, status}) =>
                <Item key={i->Belt.Int.toString ++ timestamp->Belt.Int.toString} status timestamp />
              )
              ->React.array
            | _ => <LoadingCensorBar.CircleSpin height=90 />
            }}
          </div>
        </div>
      </Col>
    </Row>
    <Row>
      <Col>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.labelBox})}>
          <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
            <div className={CssHelper.flexBox()}>
              <div className={Css.merge(list{Styles.status(true), Styles.statusLabel})} />
              <HSpacing size=Spacing.sm />
              <Text block=true value="Uptime" weight=Text.Semibold />
            </div>
            {switch historicalOracleStatusSub {
            | Data({uptimeCount}) => <Text block=true value={uptimeCount->Belt.Int.toString} />
            | _ => <LoadingCensorBar width=20 height=14 />
            }}
          </div>
          <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
            <div className={CssHelper.flexBox()}>
              <div className={Css.merge(list{Styles.status(false), Styles.statusLabel})} />
              <HSpacing size=Spacing.sm />
              <Text block=true value="Downtime" weight=Text.Semibold />
            </div>
            {switch historicalOracleStatusSub {
            | Data({downtimeCount}) => <Text block=true value={downtimeCount->Belt.Int.toString} />
            | _ => <LoadingCensorBar width=20 height=14 />
            }}
          </div>
        </div>
      </Col>
    </Row>
  </>
}
