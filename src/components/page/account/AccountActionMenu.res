module Styles = {
  open CssJs

  let menuContainer = style(. [position(relative), display(#flex), justifyContent(#flexEnd)])
  let menuPanel = (show, theme: Theme.t) =>
    style(. [
      zIndex(2),
      display(show ? #block : #none),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.08)))),
      backgroundColor(Theme.white),
      position(absolute),
      right(#zero),
      top(#percent(100.)),
      width(#px(154)),
      padding2(~h=#zero, ~v=#px(8)),
      border(#px(1), #solid, theme.neutral_100),
      borderRadius(#px(8)),
    ])
  let menuItem = (theme: Theme.t) => {
    style(. [
      padding2(~v=#px(10), ~h=#px(16)),
      cursor(#pointer),
      hover([backgroundColor(theme.neutral_100)]),
    ])
  }
}

let toString = action =>
  switch action {
  | SubmitMsg.Delegate(_) => "Delegate"
  | Undelegate(_) => "Undelegate"
  | Redelegate(_) => "Redelegate"
  | WithdrawReward(_) => "Claim"
  | Reinvest(_) => "Reinvest"
  | _ => "Not implemented"
  }

module ActionItem = {
  @react.component
  let make = (~action) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
    let (_, dispatchModal) = ModalContext.use()

    let dispatchModalWithAction = React.useCallback1(() => {
      action->SubmitTx->OpenModal->dispatchModal
    }, [action])

    <div className={Styles.menuItem(theme)} onClick={_ => dispatchModalWithAction()}>
      <Text value={action->toString} weight=Semibold color=theme.neutral_900 />
    </div>
  }
}

@react.component
let make = (~operatorAddress, ~rewardAmount) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
  let (show, setShow) = React.useState(_ => false)
  let toggle = () => setShow(prev => !prev)
  let clickOutside = ClickOutside.useClickOutside(_ => setShow(_ => false))

  <div className=Styles.menuContainer ref={ReactDOM.Ref.domRef(clickOutside)}>
    <Button variant=Text({underline: false}) onClick={_ => toggle()}>
      <Icon name="fas fa-ellipsis-v" size=16 color=theme.neutral_600 />
    </Button>
    <div className={Styles.menuPanel(show, theme)}>
      {[
        SubmitMsg.Delegate(Some(operatorAddress)),
        Undelegate(operatorAddress),
        Redelegate(operatorAddress),
      ]
      ->Belt.Array.map(action => <ActionItem key={action->SubmitMsg.toString} action />)
      ->React.array}
      <SeperatedLine mt=4 mb=4 />
      {[SubmitMsg.WithdrawReward(operatorAddress), Reinvest(operatorAddress, rewardAmount)]
      ->Belt.Array.map(action => <ActionItem key={action->SubmitMsg.toString} action />)
      ->React.array}
    </div>
  </div>
}
