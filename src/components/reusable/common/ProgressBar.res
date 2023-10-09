module Styles = {
  open CssJs

  let barContainer = style(. [
    position(relative),
    paddingTop(px(20)),
    Media.mobile([display(#flex), alignItems(#center), paddingTop(#zero)]),
  ])
  let progressOuter = (theme: Theme.t) =>
    style(. [
      position(relative),
      width(#percent(100.)),
      height(px(12)),
      borderRadius(px(7)),
      border(px(1), solid, theme.neutral_100),
      padding(px(1)),
      overflow(hidden),
    ])
  let progressInner = (p, success, theme: Theme.t) =>
    style(. [
      width(#percent(p)),
      height(#percent(100.)),
      borderRadius(px(7)),
      transition(~duration=200, "all"),
      background(success ? theme.primary_600 : theme.error_600),
    ])
  let leftText = style(. [
    position(absolute),
    top(zero),
    left(zero),
    Media.mobile([
      position(static),
      flexGrow(0.),
      flexShrink(0.),
      flexBasis(px(50)),
      paddingRight(px(10)),
    ]),
  ])
  let rightText = style(. [
    position(absolute),
    top(zero),
    right(zero),
    Media.mobile([
      position(static),
      flexGrow(0.),
      flexShrink(0.),
      flexBasis(px(70)),
      paddingLeft(px(10)),
    ]),
  ])

  // uptimeBar
  let progressUptimeOuter = (theme: Theme.t) =>
    style(. [
      position(relative),
      width(#percent(100.)),
      height(px(10)),
      borderRadius(px(7)),
      border(px(1), solid, theme.neutral_100),
      overflow(hidden),
      backgroundColor(theme.neutral_300),
    ])
  let progressUptimeInner = (value, color) =>
    style(. [
      width(#percent(value)),
      height(#percent(100.)),
      borderRadius(px(7)),
      background(color),
      transition(~duration=200, "all"),
    ])
}

@react.component
let make = (~reportedValidators, ~minimumValidators, ~requestValidators) => {
  let progressPercentage =
    (reportedValidators * 100)->Belt.Int.toFloat /. requestValidators->Belt.Int.toFloat
  let success = reportedValidators >= minimumValidators

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.barContainer>
    <div className=Styles.leftText>
      <Text
        value={"Min " ++ minimumValidators->Format.iPretty}
        transform=Text.Uppercase
        weight=Text.Semibold
        size=Text.Caption
        color={theme.neutral_900}
      />
    </div>
    <div className={Styles.progressOuter(theme)}>
      <div className={Styles.progressInner(progressPercentage, success, theme)} />
    </div>
    <div className=Styles.rightText>
      <Text
        value={reportedValidators->Format.iPretty ++ " of " ++ requestValidators->Format.iPretty}
        size=Text.Caption
        transform=Text.Uppercase
        weight=Text.Semibold
        color={theme.neutral_900}
      />
    </div>
  </div>
}

module Uptime = {
  @react.component
  let make = (~percent) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let color = if percent >= 80. {
      theme.primary_600
    } else {
      theme.warning_600
    }

    <div className={Styles.progressUptimeOuter(theme)}>
      <div className={Styles.progressUptimeInner(percent, color)} />
    </div>
  }
}

module Deposit = {
  @react.component
  let make = (~totalDeposit) => {
    // TODO: remove hard-coded later.
    let minDeposit = 1000.
    let totalDeposit_ = totalDeposit->Coin.getBandAmountFromCoins
    let percent = totalDeposit_ /. minDeposit *. 100.
    let formatedMinDeposit = minDeposit->Format.fPretty(~digits=0)
    let formatedTotalDeposit = totalDeposit_->Format.fPretty(~digits=0)

    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div>
      <div
        className={CssJs.merge(. [
          CssHelper.mb(~size=8, ()),
          CssHelper.flexBox(~justify=#spaceBetween, ()),
        ])}>
        <Text
          value={`Min Deposit ${formatedMinDeposit} BAND`} color=theme.neutral_200 size=Text.Body1
        />
        <Text
          value={`${formatedTotalDeposit} / ${formatedMinDeposit}`}
          color=theme.neutral_200
          size=Text.Body1
        />
      </div>
      <div className={Styles.progressOuter(theme)}>
        <div className={Styles.progressUptimeInner(percent, theme.primary_600)} />
      </div>
    </div>
  }
}

module Voting = {
  @react.component
  let make = (~percent, ~label, ~amount) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div>
      <div
        className={CssJs.merge(. [
          CssHelper.flexBox(~justify=#spaceBetween, ()),
          CssHelper.mb(~size=8, ()),
        ])}>
        <Heading
          value={VoteSub.toString(label, ~withSpace=true)} size=Heading.H4 weight=Heading.Thin
        />
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          <Text value={percent->Format.fPercent(~digits=2)} size=Text.Body1 block=true />
          {isMobile
            ? React.null
            : <>
                <HSpacing size=Spacing.sm />
                <Text value="/" size=Text.Body1 block=true />
                <HSpacing size=Spacing.sm />
                <Text
                  value={amount->Format.fPretty(~digits=2) ++ " BAND"}
                  size=Text.Body1
                  block=true
                  color={theme.neutral_900}
                />
              </>}
        </div>
      </div>
      <div className={Styles.progressOuter(theme)}>
        <div className={Styles.progressInner(percent, true, theme)} />
      </div>
    </div>
  }
}
