module Styles = {
  open CssJs

  let timeContainer = style(. [display(#inlineFlex)])
}

let setMomentRelativeTimeThreshold: unit => unit = %raw(`
function() {
  const moment = require("moment");
  moment.updateLocale('en', {
    relativeTime : {
      future: "in %s",
      past:   "%s ago",
      s  : 'a few seconds',
      ss : '%d seconds',
      m:  "a min",
      mm: "%d min",
      h:  "an hr",
      hh: "%d hrs",
      d:  "a day",
      dd: "%d days",
      w:  "a week",
      ww: "%d weeks",
      M:  "a mo",
      MM: "%d mo",
      y:  "a y",
      yy: "%d y"
    }
  });
  
  moment.relativeTimeRounding(Math.floor);
  moment.relativeTimeThreshold('s', 60);
  moment.relativeTimeThreshold('ss', 0);
  moment.relativeTimeThreshold('m', 60);
  moment.relativeTimeThreshold('h', 24);
  moment.relativeTimeThreshold('d', 30);
  moment.relativeTimeThreshold('M', 12);
}
  `)

@react.component
let make = (
  ~time,
  ~prefix="",
  ~suffix="",
  ~size=Text.Caption,
  ~weight=Text.Regular,
  ~spacing=Text.Unset,
  ~color=?,
  ~code=false,
) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let (displayTime, setDisplayTime) = React.useState(_ =>
    time->MomentRe.Moment.fromNow(~withoutSuffix=None)
  )

  React.useEffect1(() => {
    let intervalId = Js.Global.setInterval(
      () => setDisplayTime(_ => time->MomentRe.Moment.fromNow(~withoutSuffix=None)),
      100,
    )
    Some(() => Js.Global.clearInterval(intervalId))
  }, [time])

  <div className=Styles.timeContainer>
    {prefix != ""
      ? <>
          <Text
            value=prefix
            size
            weight
            spacing
            color={color->Belt.Option.getWithDefault(theme.neutral_600)}
            code
            nowrap=true
          />
          <HSpacing size=Spacing.sm />
        </>
      : React.null}
    <Text
      value=displayTime
      size
      weight
      spacing
      color={color->Belt.Option.getWithDefault(theme.neutral_600)}
      code
      nowrap=true
    />
    {suffix != ""
      ? <>
          <HSpacing size=Spacing.sm />
          <Text
            value=suffix
            size
            weight
            spacing
            color={color->Belt.Option.getWithDefault(theme.neutral_600)}
            code
            nowrap=true
          />
        </>
      : React.null}
  </div>
}
