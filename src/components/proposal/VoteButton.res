module Styles = {
  open CssJs
  let yesnoImg = style(. [width(#px(16)), height(#px(16)), marginRight(#px(8))])

  let btn = (~isActive, theme: Theme.t, isDarkMode, variant) => {
    let base = style(. [
      display(#block),
      width(#percent(100.)),
      padding2(~v=#px(10), ~h=#px(24)),
      transition(~duration=200, "all"),
      borderRadius(#px(8)),
      cursor(#pointer),
      outlineStyle(#none),
      borderStyle(#none),
      margin(#zero),
      disabled([cursor(#default)]),
      Media.mobile([padding2(~v=#px(10), ~h=#px(24))]),
    ])

    let activeBackgroundColor = switch variant {
    | Vote.YesNo.Yes => theme.success_100
    | Vote.YesNo.No => theme.error_100
    | _ => #transparent
    }

    let custom = switch isActive {
    | true =>
      style(. [
        backgroundColor(activeBackgroundColor),
        color(theme.neutral_900),
        border(#px(1), #solid, variant->Vote.YesNo.getColor(theme)),
      ])
    | false =>
      style(. [backgroundColor(theme.neutral_100), border(#px(1), #solid, theme.neutral_100)])
    }

    merge(. [base, custom])
  }
}

@react.component
let make = (~onClick=_ => (), ~style="", ~isActive, ~variant) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <button
    className={CssJs.merge(. [
      Styles.btn(~isActive, theme, isDarkMode, variant),
      CssHelper.flexBox(~align=#center, ~justify=#flexStart, ()),
      style,
    ])}
    onClick>
    <img
      src={switch (variant, isActive) {
      | (Yes, true) => Images.yesGreen
      | (No, true) => Images.noRed
      | (Yes, false) => Images.yesGray
      | (No, false) => Images.noGray
      | (Unknown, true) => Images.question
      | (Unknown, false) => Images.question
      }}
      alt={`${variant->Vote.YesNo.toString} Vote Button`}
      className=Styles.yesnoImg
    />
    <Text
      value={variant->Vote.YesNo.toString}
      size=Text.Xl
      weight=Text.Semibold
      color={isActive ? variant->Vote.YesNo.getColor(theme) : theme.neutral_400}
    />
    <HSpacing size=Spacing.sm />
    <Text
      value={switch variant {
      | Yes => " - I support the proposal"
      | No => " - I oppose the proposal"
      | Unknown => " "
      }}
      size=Text.Body1
      weight=Text.Regular
      color={isActive ? theme.neutral_900 : theme.neutral_600}
    />
  </button>
}
