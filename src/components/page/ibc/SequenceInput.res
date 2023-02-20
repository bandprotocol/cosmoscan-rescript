module Styles = {
  open CssJs
  let searchContainer = style(. [
    maxWidth(#percent(100.)),
    display(#flex),
    alignItems(#center),
    position(#relative),
  ])
  let iconContainer = style(. [
    position(#absolute),
    left(#px(16)),
    top(#percent(50.)),
    transform(#translateY(#percent(-50.))),
  ])
  let searchBar = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      height(#px(37)),
      paddingLeft(#px(9)),
      paddingRight(#px(9)),
      borderRadius(#px(4)),
      fontSize(#px(14)),
      fontWeight(#light),
      border(#px(1), #solid, theme.neutral_200),
      backgroundColor(theme.neutral_000),
      outlineStyle(#none),
      color(theme.neutral_900),
      fontFamilies([#custom("Montserrat"), #custom("sans-serif")]),
    ])
}

@react.component
let make = (~placeholder, ~onChange, ~value, ~disabled) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div>
    <div className={Styles.searchContainer}>
      <input
        disabled
        type_="number"
        className={Styles.searchBar(theme)}
        placeholder
        value
        onChange={event => {
          let newVal = ReactEvent.Form.target(event)["value"]->String.lowercase_ascii->String.trim
          onChange(_ => newVal)
        }}
      />
    </div>
  </div>
}
