module Styles = {
  open CssJs

  let typeContainer = w => style(. [marginRight(#px(20)), width(w)])

  let resolveIcon = style(. [width(#px(20)), height(#px(20)), marginLeft(Spacing.sm)])

  let hashContainer = style(. [maxWidth(#px(220))])
  let feeContainer = style(. [display(#flex), justifyContent(#flexEnd)])
  let timeContainer = style(. [display(#flex), alignItems(#center), maxWidth(#px(150))])
  let textContainer = style(. [display(#flex)])
  let countContainer = style(. [maxWidth(#px(80))])
  let proposerBox = style(. [maxWidth(#px(270)), display(#flex), flexDirection(#column)])
  let idContainer = style(. [display(#flex), maxWidth(#px(200))])
  let dataSourcesContainer = style(. [display(#flex)])
  let dataSourceContainer = style(. [display(#flex), width(#px(170))])
  let oracleScriptContainer = style(. [display(#flex), width(#px(170))])
  let resolveStatusContainer = style(. [
    display(#flex),
    alignItems(#center),
    justifyContent(#flexEnd),
  ])
}
