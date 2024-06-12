type btn_style_t =
  | Primary
  | Secondary
  | Outline
  | Text

module Styles = {
  open CssJs

  let btn = (theme: Theme.t, isDarkMode) =>
    style(. [
      display(#flex),
      justifyContent(#spaceBetween),
      width(#percent(100.)),
      padding2(~v=#px(10), ~h=#px(24)),
      transition(~duration=200, "all"),
      borderRadius(#px(8)),
      cursor(#pointer),
      outlineStyle(#none),
      margin(#zero),
      disabled([cursor(#default)]),
      backgroundColor(#transparent),
      border(#px(1), #solid, theme.neutral_200),
      hover([backgroundColor(theme.primary_100)]),
      disabled([
        borderColor(theme.neutral_600),
        color(theme.neutral_600),
        hover([backgroundColor(#transparent)]),
        opacity(0.5),
      ]),
    ])

  let icon = {
    style(. [width(#px(24)), height(#px(24))])
  }
}

@react.component
let make = (~onClick=_ => (), ~disabled=false, ~wallet) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <button className={Styles.btn(theme, isDarkMode)} onClick disabled>
    <Text size=Text.Body1 weight=Text.Semibold color={theme.neutral_900} value={wallet} />
    <img
      alt="Fail Icon"
      src={switch wallet {
      | "Keplr" => Images.keplr
      | "Cosmostation" => Images.cosmostation
      | "Ledger" => Images.ledger
      | "Mnemonic" => Images.mnemonic
      | _ => Images.fail
      }}
      className=Styles.icon
    />
  </button>
}
