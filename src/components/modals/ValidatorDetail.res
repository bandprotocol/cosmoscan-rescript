module Styles = {
  open CssJs

  let heading = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_300),
      paddingBottom(#px(4)),
      marginBottom(#px(4)),
    ])
}

@react.component
let make = (~heading, ~validator) => {
  let validatorInfoSub = ValidatorSub.get(validator)
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  switch validatorInfoSub {
  | Data(validator) =>
    <div className={CssHelper.mb(~size=24, ())}>
      <div className={Styles.heading(theme)}>
        <Text value={heading} size={Body2} />
      </div>
      <Text value={validator.moniker} size={Body1} color={theme.neutral_900} weight={Semibold} />
      <Text
        value={validator.operatorAddress->Address.toOperatorBech32} size={Body2} ellipsis=true
      />
    </div>
  | _ => <LoadingCensorBar width=150 height=30 mb=16 />
  }
}
