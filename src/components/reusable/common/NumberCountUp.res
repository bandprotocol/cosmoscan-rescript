@react.component
let make = (~value, ~size, ~weight, ~spacing=?, ~color=?, ~code=true, ~smallNumber=false) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let countUp = CountUp.context(
    CountUp.props(
      ~start=value,
      ~end=value,
      ~delay=0,
      ~decimals=2,
      ~duration=4,
      ~useEasing=false,
      ~separator=",",
    ),
  )

  React.useEffect1(_ => {
    CountUp.updateGet(countUp, value)
    None
  }, [value])
  let newVal = CountUp.countUpGet(countUp)->Js.Float.toString
  let color_ = color->Belt.Option.getWithDefault(theme.neutral_900)

  smallNumber
    ? {
        let adjustedText = newVal->Js.String2.split(".")
        <div className={CssHelper.flexBox(~align=#flexEnd, ())}>
          <Text
            value={adjustedText->Belt.Array.get(0)->Belt.Option.getWithDefault("0")}
            size
            weight
            spacing={spacing->Belt.Option.getWithDefault(Text.Em(0.))}
            code
            nowrap=true
            color=color_
          />
          <Text
            value={"." ++ adjustedText->Belt.Array.get(1)->Belt.Option.getWithDefault("0")}
            size=Text.Body1
            weight
            spacing={spacing->Belt.Option.getWithDefault(Text.Em(0.))}
            code
            nowrap=true
            color=color_
          />
        </div>
      }
    : <Text
        value=newVal
        size
        weight
        spacing={spacing->Belt.Option.getWithDefault(Text.Em(0.))}
        code
        nowrap=true
        color=color_
      />
}
