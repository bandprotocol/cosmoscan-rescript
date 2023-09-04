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
    | Vote.Full.Yes => theme.error_100
    | Vote.Full.No => theme.success_100
    | Vote.Full.NoWithVeto => theme.success_100
    | Vote.Full.Abstain => #transparent
    | _ => #transparent
    }

    let custom = switch isActive {
    | true =>
      style(. [
        backgroundColor(activeBackgroundColor),
        color(theme.neutral_900),
        border(#px(1), #solid, variant->Vote.Full.getColorInvert(theme)),
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
      | (Yes, true) => Images.yesRed
      | (No, true) => Images.noGreen
      | (NoWithVeto, true) => Images.noDarkGreen
      | (Abstain, true) => Images.abstain
      | (Yes, false) => Images.yesGray
      | (No, false) => Images.noGray
      | (NoWithVeto, false) => Images.noGray
      | (Abstain, false) => Images.abstainGray
      | (Unknown, true) => Images.question
      | (Unknown, false) => Images.question
      }}
      alt={`${variant->Vote.Full.toString} Vote Button`}
      className=Styles.yesnoImg
    />
    <Text
      value={variant->Vote.Full.toString}
      size=Text.Xl
      weight=Text.Semibold
      color={isActive ? variant->Vote.Full.getColorInvert(theme) : theme.neutral_400}
    />
    <HSpacing size=Spacing.sm />
    <Text
      value={switch variant {
      | Yes => " - I agree to reject this proposal."
      | No => " - I disagree to reject this proposal."
      | NoWithVeto => " - disagree, no deposit return."
      | Abstain => " - I choose not to vote on this proposal."
      | Unknown => " "
      }}
      size=Text.Body1
      weight=Text.Regular
      color={isActive ? theme.neutral_900 : theme.neutral_600}
    />
  </button>
}
