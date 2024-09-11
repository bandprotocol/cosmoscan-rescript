module Styles = {
  open CssJs
  let container = style(. [
    width(#px(516)),
    padding3(~top=#px(32), ~h=#px(24), ~bottom=#px(24)),
    borderRadius(#px(4)),
  ])

  let tabGroup = (theme: Theme.t) =>
    style(. [display(#flex), width(#percent(100.)), borderBottom(#px(1), solid, theme.neutral_300)])

  let tabContainer = (theme: Theme.t, active) =>
    style(. [
      display(inlineFlex),
      justifyContent(center),
      alignItems(center),
      cursor(pointer),
      width(#percent(50.)),
      padding4(~top=#zero, ~right=#zero, ~bottom=#px(4), ~left=#zero),
      borderBottom(#px(4), solid, active ? theme.primary_600 : transparent),
      Media.mobile([whiteSpace(nowrap)]),
    ])

  let summaryContainer = style(. [padding2(~v=#px(24), ~h=#px(0))])
  let borderBottomLine = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_300)])
  let currentDelegateHeader = (theme: Theme.t) =>
    style(. [borderBottom(#px(1), solid, theme.neutral_200), margin2(~v=#px(4), ~h=#px(0))])

  let delegateAmountContainer = (theme: Theme.t) =>
    style(. [borderRadius(#px(8)), background(theme.neutral_100), padding2(~v=#px(12), ~h=#px(16))])

  let info = style(. [
    display(#flex),
    justifyContent(#spaceBetween),
    alignItems(#center),
    marginBottom(#px(24)),
  ])
  let divider = (theme: Theme.t) =>
    style(. [
      height(#px(1)),
      background(theme.neutral_300),
      width(#percent(100.)),
      marginTop(#px(24)),
      marginBottom(#px(24)),
    ])

  let buttonContainer = style(. [
    display(#flex),
    justifyContent(#spaceBetween),
    alignItems(center),
    columnGap(#px(16)),
  ])
  let confirmButton = style(. [flex(#num(1.))])
  let halfWidth = style(. [width(#percent(50.))])
  let fullWidth = style(. [width(#percent(100.)), margin2(~v=#px(24), ~h=#zero)])
}

@react.component
let make = (~rawTx, ~onBack, ~account: AccountContext.t, ~msgsOpt) => {
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let trackingSub = TrackingSub.use()

  let tab = (~name, ~active, ~setTab) => {
    <div key=name className={Styles.tabContainer(theme, active)} onClick={_ => setTab()}>
      <Text
        value=name
        weight={active ? Text.Semibold : Text.Regular}
        color={active ? theme.neutral_900 : theme.neutral_600}
        size=Text.Body1
      />
    </div>
  }

  <div className={Styles.container}>
    <div className={Styles.tabGroup(theme)}>
      {["summary", "json message"]
      ->Belt.Array.mapWithIndex((index, name) =>
        tab(~name, ~active=index == tabIndex, ~setTab=() => setTabIndex(_ => index))
      )
      ->React.array}
    </div>
    {switch msgsOpt->Belt.Option.getWithDefault(_, [])->Belt.Array.get(0) {
    | Some(msg) =>
      switch msg {
      | Msg.Input.DelegateMsg({delegatorAddress, validatorAddress, amount}) =>
        <DelegateSummary account validator={validatorAddress} amount />
      // TODO: handle properly
      | _ => <Text value={"fallback"} />
      }
    // TODO: handle properly
    | None => <Text value={"no message"} />
    }}
    <div className={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ())})}>
      <Text size={Body1} value="Chain" />
      {switch trackingSub {
      | Data({chainID}) => <Text size={Body1} color={theme.neutral_900} value={chainID} />
      | _ => <LoadingCensorBar width=100 height=20 />
      }}
    </div>
    <div className={Styles.divider(theme)} />
    <div className=Styles.info>
      <Text value="Transaction Fee" size=Text.Body2 weight=Text.Medium nowrap=true block=true />
      <Text value="0.005 BAND" />
    </div>
    <div className={Styles.buttonContainer}>
      <Button variant=Button.Outline style={Styles.confirmButton} onClick={_ => onBack()}>
        {"Back"->React.string}
      </Button>
      <Button style={Styles.confirmButton} onClick={_ => ()}> {"Confirm"->React.string} </Button>
    </div>
  </div>
}
