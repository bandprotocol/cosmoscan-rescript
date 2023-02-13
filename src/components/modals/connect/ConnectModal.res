module Styles = {
  open CssJs

  let container = style(. [
    display(#flex),
    justifyContent(#center),
    position(#relative),
    width(#px(800)),
    height(#px(520)),
  ])

  let innerContainer = style(. [display(#flex), flexDirection(#column), width(#percent(100.))])

  let loginSelectionContainer = style(. [padding2(~v=#zero, ~h=#px(24)), height(#percent(100.))])

  let modalTitle = (theme: Theme.t) =>
    style(. [
      display(#flex),
      justifyContent(#center),
      flexDirection(#column),
      alignItems(#center),
      paddingTop(#px(30)),
      borderBottom(#px(1), #solid, theme.neutral_100),
    ])

  let row = style(. [height(#percent(100.))])
  let rowContainer = style(. [margin2(~v=#zero, ~h=#px(12)), height(#percent(100.))])

  let header = (theme: Theme.t, active) =>
    style(. [
      display(#flex),
      flexDirection(#row),
      alignSelf(#center),
      alignItems(#center),
      padding2(~v=#zero, ~h=#px(20)),
      fontSize(#px(14)),
      fontWeight(active ? #bold : #normal),
      color(active ? theme.neutral_900 : theme.neutral_600),
    ])

  let loginList = (theme: Theme.t, active) =>
    style(. [
      display(#flex),
      width(#percent(100.)),
      height(#px(50)),
      borderRadius(#px(8)),
      border(#px(2), #solid, active ? theme.primary_600 : #transparent),
      cursor(#pointer),
      overflow(#hidden),
    ])

  let loginSelectionBackground = (theme: Theme.t) => style(. [background(theme.neutral_100)])

  let ledgerIcon = style(. [height(#px(28)), width(#px(28)), transform(translateY(#px(3)))])
  let ledgerImageContainer = active => style(. [opacity(active ? 1.0 : 0.5), marginRight(#px(15))])
}

//Re-consider to remove ledgerWithBandChain
type login_method_t =
  | Mnemonic
  | LedgerWithCosmos
  | LedgerWithBandChain

@react.component
let make = (~chainID) => {
  Js.log(chainID)
  let (loginMethod, _) = React.useState(_ => Mnemonic)
  // let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  //TODO: will patch to modal component later
  <div>
    {switch loginMethod {
    | Mnemonic => "Connect Mnemonic Modal"->React.string
    | LedgerWithCosmos => "Connect LedgerWithCosmos"->React.string
    | LedgerWithBandChain => "Connect LedgerWithBandChain"->React.string
    }}
  </div>
}
