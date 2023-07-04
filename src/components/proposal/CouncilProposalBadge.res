module Styles = {
  open CssJs

  let badge = color =>
    style(. [backgroundColor(color), padding2(~v=#px(3), ~h=#px(10)), borderRadius(#px(50))])
}

let getBadgeText = status =>
  switch status {
  | CouncilProposalSub.Status.VotingPeriod => "VOTING PERIOD"
  | WaitingVeto => "WAITING FOR VETO"
  | VetoPeriod => "VETO PERIOD"
  | RejectedByCouncil
  | RejectedByVeto => "REJECTED"
  | Executed
  | ExecutionFailed
  | TallyingFailed => "PASSED"
  | Unknown => "UNKNOWN"
  }

let getBadgeColor = (theme: Theme.t, status) =>
  switch status {
  | CouncilProposalSub.Status.VotingPeriod => theme.primary_600
  | WaitingVeto => theme.neutral_500
  | VetoPeriod => theme.warning_600
  | RejectedByCouncil
  | RejectedByVeto =>
    theme.error_600
  | Executed
  | ExecutionFailed
  | TallyingFailed =>
    theme.success_600
  | Unknown => theme.neutral_900
  }

@react.component
let make = (~status) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{
      Styles.badge(getBadgeColor(theme, status)),
      CssHelper.flexBox(~justify=#center, ()),
    })}>
    <Text
      value={getBadgeText(status)}
      size=Text.Caption
      weight=Text.Semibold
      transform=Text.Uppercase
      color=theme.white
    />
  </div>
}
