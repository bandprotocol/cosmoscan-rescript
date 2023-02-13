module Styles = {
  open CssJs
  open Emotion

  let chartContainer = style(. [position(#relative), maxWidth(#px(220)), maxHeight(#px(220))])

  let textContainer = (theme: Theme.t) =>
    style(. [
      background(theme.neutral_000),
      position(#absolute),
      top(#px(8)),
      left(#px(8)),
      right(#px(8)),
      bottom(#px(8)),
      borderRadius(#percent(50.)),
    ])

  let emoCircle = (percent, theme: Theme.t) => {
    css({
      "width": "100%",
      "height": "100%",
      "borderRadius": "50%",
      "& > circle": {
        "fill": theme.neutral_100 -> Css_AtomicTypes.Color.toString,
        "strokeWidth": "16px",
        "stroke": theme.primary_600 -> Css_AtomicTypes.Color.toString,
        "strokeDasharray": j`calc($percent * 653.45 / 100) 653.45`,
        "transform": "rotate(-90deg) translateX(-100%)",
      },
    })
  }
}

@react.component
let make = (~percent) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.chartContainer>
    <svg
      className={Styles.emoCircle(percent->int_of_float->Belt.Int.toString, theme)}
      viewBox="0 0 208 208">
      <circle r="104" cx="104" cy="104" />
    </svg>
    <div
      className={Css.merge(list{
        Styles.textContainer(theme),
        CssHelper.flexBox(~justify=#center, ~direction=#column, ()),
      })}>
      <Heading
        size=Heading.H5
        value="Turnout"
        align=Heading.Center
        marginBottom=8
        color={theme.neutral_600}
      />
      <Text
        size=Text.Xxxl
        value={percent->Format.fPercent(~digits=2)}
        block=true
        color={theme.neutral_900}
      />
    </div>
  </div>
}
