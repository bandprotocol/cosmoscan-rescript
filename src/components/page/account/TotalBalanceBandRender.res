@react.component
let make = (~totalBalanceBAND) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let countUp = CountUp.context(
    CountUp.props(
      ~start=totalBalanceBAND,
      ~end=totalBalanceBAND,
      ~delay=0,
      ~decimals=6,
      ~duration=4,
      ~useEasing=false,
      ~separator=",",
    ),
  )

  React.useEffect1(_ => {
    CountUp.updateGet(countUp, totalBalanceBAND)
    None
  }, [totalBalanceBAND])

  let newVal = CountUp.countUpGet(countUp)->Js.Float.toString
  let adjustedText = newVal->Js.String2.split(".")

  <>
    <div className={CssHelper.flexBox(~align=#baseline, ())}>
      <div className={CssHelper.flexBox(~align=#baseline, ())}>
        <Text
          value={adjustedText->Belt.Array.get(0)->Belt.Option.getWithDefault("0")}
          size=Huge
          color=theme.neutral_900
          weight=Bold
          code=true
        />
        <Text
          value={"." ++ adjustedText->Belt.Array.get(1)->Belt.Option.getWithDefault("0")}
          size=Xl
          weight=Bold
          code=true
          color=theme.neutral_900
        />
      </div>
      <HSpacing size=Spacing.sm />
      <Text value="BAND" size=Text.Body1 code=false weight=Text.Thin color=theme.neutral_900 />
    </div>
  </>
}
