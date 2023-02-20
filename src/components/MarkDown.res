module Styles = {
  open CssJs

  let container = (theme: Theme.t) =>
    style(. [
      selector(
        "a",
        [
          wordBreak(#breakAll),
          color(theme.neutral_900),
          textDecoration(#none),
          transition(~duration=200, "all"),
          hover([color(theme.primary_600)]),
        ],
      ),
      selector("p", [color(theme.neutral_600), marginBottom(#em(1.))]),
      selector("p + p", [marginTop(#em(1.))]),
      selector("p:last-child", [color(theme.neutral_600), marginBottom(#em(0.))]),
      selector(
        "h2,h3,h4,h5,h6",
        [color(theme.neutral_600), marginBottom(#px(10)), fontSize(#px(16))],
      ),
    ])
}

@react.component
let make = (~value) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div className={Styles.container(theme)}> {value->MarkedJS.marked->MarkedJS.parse} </div>
}
