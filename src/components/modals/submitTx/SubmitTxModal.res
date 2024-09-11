module Styles = {
  open CssJs
  let container = style(. [
    flexDirection(#column),
    width(#px(468)),
    minHeight(#px(300)),
    height(#auto),
    padding(#px(32)),
    borderRadius(#px(5)),
    justifyContent(#flexStart),
  ])
}

module CreateTxFlow = {
  @react.component
  let make = (~account, ~msg) => {
    let (rawTx, setRawTx) = React.useState(_ => None)
    let (msgsOpt, setMsgsOpt) = React.useState(_ => None)
    <>
      // <SummaryStep onBack={_ => setRawTx(_ => None)} account msg />
      <SubmitTxStep account setRawTx isActive={rawTx->Belt.Option.isNone} msg msgsOpt setMsgsOpt />
      {rawTx->Belt.Option.mapWithDefault(React.null, tx =>
        <SummaryStep rawTx=tx onBack={_ => setRawTx(_ => None)} account msgsOpt />
      )}
    </>
  }
}

@react.component
let make = (~msg) => {
  let (account, _) = React.useContext(AccountContext.context)

  switch account {
  | Some(account') => <CreateTxFlow account=account' msg />
  | None =>
    <div className=Styles.container>
      <Text value="Please sign in" size=Text.Body1 />
    </div>
  }
}
