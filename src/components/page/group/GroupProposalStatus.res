type t =
  | PROPOSAL_STATUS_UNSPECIFIED
  | PROPOSAL_STATUS_SUBMITTED
  | PROPOSAL_STATUS_ACCEPTED
  | PROPOSAL_STATUS_REJECTED
  | PROPOSAL_STATUS_ABORTED
  | PROPOSAL_STATUS_WITHDRAWN

let toString = status => {
  switch status {
  | PROPOSAL_STATUS_UNSPECIFIED => "Unspecified"
  | PROPOSAL_STATUS_SUBMITTED => "Submitted"
  | PROPOSAL_STATUS_ACCEPTED => "Accepted"
  | PROPOSAL_STATUS_REJECTED => "Rejected"
  | PROPOSAL_STATUS_ABORTED => "Aborted"
  | PROPOSAL_STATUS_WITHDRAWN => "Withdrawn"
  }
}

let parse = str => {
  switch str {
  | "PROPOSAL_STATUS_UNSPECIFIED" => PROPOSAL_STATUS_UNSPECIFIED
  | "PROPOSAL_STATUS_SUBMITTED" => PROPOSAL_STATUS_SUBMITTED
  | "PROPOSAL_STATUS_ACCEPTED" => PROPOSAL_STATUS_ACCEPTED
  | "PROPOSAL_STATUS_REJECTED" => PROPOSAL_STATUS_REJECTED
  | "PROPOSAL_STATUS_ABORTED" => PROPOSAL_STATUS_ABORTED
  | "PROPOSAL_STATUS_WITHDRAWN" => PROPOSAL_STATUS_WITHDRAWN
  | _ => PROPOSAL_STATUS_UNSPECIFIED
  }
}

module Styles = {
  open CssJs
  let chipStyles = (~status: t, theme: Theme.t) =>
    style(. [
      backgroundColor({
        switch status {
        | PROPOSAL_STATUS_ACCEPTED
        | PROPOSAL_STATUS_SUBMITTED =>
          theme.success_600
        | PROPOSAL_STATUS_REJECTED
        | PROPOSAL_STATUS_ABORTED =>
          theme.error_600
        | _ => theme.neutral_500
        }
      }),
      borderRadius(#px(50)),
      padding2(~v=#px(2), ~h=#px(8)),
      whiteSpace(#pre),
      display(#inlineFlex),
      selector("> p", [color(theme.neutral_000)]),
    ])
}

@react.component
let make = (~value, ~status=PROPOSAL_STATUS_UNSPECIFIED) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{
      CssHelper.flexBox(~wrap=#nowrap, ~justify=#center, ()),
      Styles.chipStyles(~status, theme),
    })}>
    <Text
      value
      size=Caption
      color={theme.neutral_900}
      transform=Text.Uppercase
      align=Text.Center
      weight={Semibold}
    />
  </div>
}
