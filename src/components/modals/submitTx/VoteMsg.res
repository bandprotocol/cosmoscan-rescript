module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(8))])

  let buttonGroup = (theme: Theme.t) => style(. [margin2(~v=#zero, ~h=#zero)])
}

module VoteInput = {
  @react.component
  let make = (~setAnswerOpt, ~answerOpt) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div className={Styles.buttonGroup(theme)}>
      {[Vote.YesNo.Yes, No]
      ->Belt.Array.map(option =>
        <React.Fragment key={option->Vote.YesNo.toString}>
          <VoteButton
            isActive={answerOpt->Belt.Option.getWithDefault(
              BandChainJS.VOTE_OPTION_COUNCIL_UNSPECIFIED,
            ) == option->Vote.YesNo.toBandChainJsCouncilVote}
            variant=option
            onClick={_ => setAnswerOpt(_ => Some(option->Vote.YesNo.toBandChainJsCouncilVote))}
          />
          <VSpacing size=Spacing.sm />
        </React.Fragment>
      )
      ->React.array}
    </div>
  }
}

@react.component
let make = (~address, ~proposalID, ~proposalName, ~setMsgsOpt) => {
  let (answerOpt, setAnswerOpt) = React.useState(_ => None)
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  React.useEffect1(_ => {
    let msgsOpt = Belt.Option.flatMap(answerOpt, answer => {
      Some([
        Msg.Input.VoteMsg({
          voterAddress: address,
          proposalID,
          option: answer,
        }),
      ])
    })

    setMsgsOpt(_ => msgsOpt)
    None
  }, [answerOpt])

  <>
    <div className=Styles.container>
      <Text
        value="Proposal Name"
        size=Text.Body2
        weight=Text.Regular
        color={theme.neutral_900}
        nowrap=true
        block=true
      />
      <VSpacing size=Spacing.xs />
      <Text
        value={`${proposalID->ID.Proposal.toString} ${proposalName}`}
        size=Text.Body1
        weight=Text.Semibold
        color=theme.neutral_900
        nowrap=true
        block=true
      />
      <VSpacing size=Spacing.md />
      <Text value="Answer" size=Text.Body2 weight=Text.Medium nowrap=true block=true />
    </div>
    <VoteInput answerOpt setAnswerOpt />
  </>
}
