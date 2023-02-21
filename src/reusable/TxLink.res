module Styles = {
  open CssJs
  let withWidth = (w, theme: Theme.t) =>
    style(. [
      display(#flex),
      maxWidth(px(w)),
      cursor(pointer),
      selector("> span:hover", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])
}

@react.component
let make = (~txHash: Hash.t, ~width: int, ~size=Text.Body2, ~weight=Text.Medium) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <Link className={Styles.withWidth(width, theme)} route={Route.TxIndexPage(txHash)}>
    <Text
      block=true
      mono=true
      spacing={Text.Em(0.02)}
      value={txHash->Hash.toHex(~upper=true)}
      weight
      ellipsis=true
      size
      color={theme.primary_600}
    />
  </Link>
}
