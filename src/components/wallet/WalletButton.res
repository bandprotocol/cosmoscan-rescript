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
      alignItems(#center),
      width(#percent(100.)),
      fontSize(#px(14)),
      fontWeight(#semiBold),
      color(theme.neutral_900),
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
      hover([backgroundColor(theme.neutral_100)]),
      active([backgroundColor(theme.primary_800), color(theme.white)]),
    ])

  let icon = {
    style(. [width(#px(24)), height(#px(24))])
  }
}

@react.component
let make = (~onClick=_ => (), ~disabled=false, ~wallet) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <button className={Styles.btn(theme, isDarkMode)} onClick disabled>
    <p> {wallet->Wallet.wallet_option_string->React.string} </p>
    <img
      alt={`$wallet icon`}
      src={switch wallet {
      | Wallet.Leap => Images.leap
      | Wallet.Keplr => Images.keplr
      | Wallet.Cosmostation => Images.cosmostation
      | Wallet.Ledger => Images.ledger
      | Wallet.Mnemonic => Images.mnemonic
      }}
      className=Styles.icon
    />
  </button>
}
