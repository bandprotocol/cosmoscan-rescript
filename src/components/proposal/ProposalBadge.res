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

let getTooltipText = status =>
  switch status {
  | CouncilProposalSub.Status.VotingPeriod => `This period lasts for 3 days. During this period, council members must vote on the proposal. If the proposal passes, the next period is "waiting for veto". During this period, BAND stakers can open a veto proposal.`
  | WaitingVeto => `This period lasts for 4 days. BAND stakers can open a veto proposal. If no veto is filed, the proposal passes. If a veto is filed, the status will change to "veto period" and last for 7 days.`
  | VetoPeriod => `BAND stakers have 7 days to vote veto a proposal. If the veto proposal has a quorum of more than 50% and the yes threshold exceeds 40%, The proposal is rejected.`
  | RejectedByCouncil
  | RejectedByVeto => `The proposal was rejected because there was not a quorum of more than 40%, or the yes vote did not exceed 50% of council members, or a veto was issued.`
  | Executed
  | ExecutionFailed
  | TallyingFailed => `The proposal passed with a quorum of more than 40% and a yes vote of more than 50% of council members. No vetoes were issued.`
  | Unknown => "UNKNOWN"
  }

@react.component
let make = (~status) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <>
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
    <HSpacing size=Spacing.xs />
    <CTooltip
      tooltipPlacement=CTooltip.Top
      tooltipPlacementSm=CTooltip.Top
      tooltipText={status->getTooltipText}>
      <Icon name="fal fa-info-circle" size=12 color={theme.neutral_600} />
    </CTooltip>
  </>
}
