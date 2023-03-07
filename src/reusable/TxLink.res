module Styles = {
  open CssJs
  let withWidth = (w, theme: Theme.t, fullHash) =>
    style(. [
      display(fullHash ? #flex : #inlineBlock),
      maxWidth(px(w)),
      cursor(pointer),
      selector("> span:hover", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])
}

@react.component
let make = (
  ~txHash: Hash.t,
  ~width: int,
  ~size=Text.Body2,
  ~weight=Text.Medium,
  ~fullHash=true,
) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  {
    switch fullHash {
    | false =>
      <Link className={Styles.withWidth(width, theme, fullHash)} route={Route.TxIndexPage(txHash)}>
        <Text
          block=true
          code=true
          spacing={Text.Em(0.02)}
          value={
            let startHash = txHash->Hash.toHex(~upper=true)->Js.String.slice(~from=0, ~to_=6)

            let endHash =
              txHash
              ->Hash.toHex(~upper=true)
              ->Js.String.slice(
                ~from=txHash->Hash.toHex->Js.String2.length - 6,
                ~to_=txHash->Hash.toHex->Js.String2.length,
              )

            startHash ++ "..." ++ endHash
          }
          weight
          ellipsis=false
          size
          color={theme.neutral_900}
        />
      </Link>
    | true =>
      <Link className={Styles.withWidth(width, theme, fullHash)} route={Route.TxIndexPage(txHash)}>
        <Text
          block=true
          spacing={Text.Em(0.02)}
          value={txHash->Hash.toHex(~upper=true)}
          weight
          ellipsis=true
          size
          color={theme.neutral_900}
        />
      </Link>
    }
  }
}
