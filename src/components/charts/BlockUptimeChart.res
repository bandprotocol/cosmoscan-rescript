module Styles = {
  open CssJs
  let chartWrapper = style(. [minHeight(px(160))])
  let chartContainer = style(. [
    maxWidth(#px(156)),
    columnGap(#px(4)),
    rowGap(#px(4)),
    margin2(~v=#zero, ~h=#auto),
  ])

  let blockContainer = style(. [display(#block), Media.smallMobile([height(#px(10))])])

  let block = (theme: Theme.t, status) => {
    let blockBase = style(. [width(#px(12)), height(#px(12)), borderRadius(#px(2))])

    let statusColor = switch status {
    | Validator.Missed => style(. [backgroundColor(theme.error_600)])
    | Proposed => style(. [backgroundColor(theme.success_800)])
    | Signed => style(. [backgroundColor(theme.success_600)])
    }

    merge2(. blockBase, statusColor)
  }
}

module UptimeBlock = {
  @react.component
  let make = (~status, ~height) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
    let blockRoute = height->ID.Block.getRoute

    <CTooltip
      width=90
      tooltipPlacement=CTooltip.Top
      tooltipPlacementSm=CTooltip.BottomLeft
      mobile=false
      align=#center
      pd=10
      tooltipText={height->ID.Block.toString}
      styles=Styles.blockContainer>
      <Link route=blockRoute className=Styles.blockContainer>
        <div className={Styles.block(theme, status)} />
      </Link>
    </CTooltip>
  }
}

@react.component
let make = (~consensusAddress) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
  let getUptimeSub = ValidatorSub.getBlockUptimeByValidator(consensusAddress)

  <>
    <div className={Css.merge(list{CssHelper.flexBox(), Styles.chartWrapper})}>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.chartContainer})}>
        {switch getUptimeSub {
        | Data({validatorVotes}) =>
          validatorVotes
          ->Belt.Array.map(({blockHeight, status}) =>
            <UptimeBlock key={blockHeight->ID.Block.toString} status height=blockHeight />
          )
          ->React.array
        | _ => <LoadingCensorBar.CircleSpin height=90 />
        }}
      </div>
    </div>
    <VSpacing size=#px(24) />
    <div className={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ())})}>
      <div className={CssHelper.flexBox()}>
        <div className={Styles.block(theme, Validator.Proposed)} />
        <HSpacing size=Spacing.sm />
        <Text block=true value="Proposed" weight=Text.Semibold />
      </div>
      {switch getUptimeSub {
      | Data({proposedCount}) =>
        <Text block=true value={proposedCount->Belt.Int.toString} weight=Bold size=Body1 />
      | _ => <LoadingCensorBar width=20 height=14 />
      }}
    </div>
    <VSpacing size={#px(10)} />
    <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
      <div className={CssHelper.flexBox()}>
        <div className={Styles.block(theme, Validator.Signed)} />
        <HSpacing size=Spacing.sm />
        <Text block=true value="Signed" weight=Text.Semibold />
      </div>
      {switch getUptimeSub {
      | Data({signedCount}) =>
        <Text block=true value={signedCount->Belt.Int.toString} weight=Bold size=Body1 />
      | _ => <LoadingCensorBar width=20 height=14 />
      }}
    </div>
    <VSpacing size={#px(10)} />
    <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
      <div className={CssHelper.flexBox()}>
        <div className={Styles.block(theme, Validator.Missed)} />
        <HSpacing size=Spacing.sm />
        <Text block=true value="Missed" weight=Text.Semibold />
      </div>
      {switch getUptimeSub {
      | Data({missedCount}) =>
        <Text block=true value={missedCount->Belt.Int.toString} weight=Bold size=Body1 />
      | _ => <LoadingCensorBar width=20 height=14 />
      }}
    </div>
  </>
}
