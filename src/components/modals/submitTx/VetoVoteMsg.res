module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(8))])

  let buttonGroup = (theme: Theme.t) => style(. [margin2(~v=#zero, ~h=#zero)])
  // let buttonGroup = (theme: Theme.t) =>
  //   style(. [
  //     margin4(~top=#px(0), ~right=#px(-12), ~bottom=#px(23), ~left=#px(-12)),
  //     selector(
  //       "> button",
  //       [
  //         flexGrow(0.),
  //         flexShrink(0.),
  //         flexBasis(#calc((#sub, #percent(50.), #px(24)))),
  //         margin2(~v=#zero, ~h=#px(12)),
  //         borderColor(theme.neutral_100),
  //         position(#relative),
  //         disabled([
  //           color(theme.neutral_900),
  //           opacity(1.),
  //           border(#px(1), #solid, theme.primary_600),
  //           hover([backgroundColor(#transparent)]),
  //           after([
  //             contentRule(#text("\f00c")),
  //             fontFamily(#custom("'Font Awesome 5 Pro'")),
  //             fontWeight(#light),
  //             borderRadius(#percent(50.)),
  //             fontSize(#px(10)),
  //             lineHeight(#em(1.8)),
  //             display(#block),
  //             position(#absolute),
  //             pointerEvents(#none),
  //             top(#px(-8)),
  //             right(#px(-8)),
  //             color(theme.white),
  //             backgroundColor(theme.primary_600),
  //             width(#px(20)),
  //             height(#px(20)),
  //           ]),
  //         ]),
  //       ],
  //     ),
  //   ])
}

module VoteInput = {
  @react.component
  let make = (~setAnswerOpt, ~answerOpt) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div className={Styles.buttonGroup(theme)}>
      {[Vote.Full.Yes, No, NoWithVeto, Abstain]
      ->Belt.Array.map(option =>
        <React.Fragment key={option->Vote.Full.toString}>
          <VetoVoteButton
            isActive={answerOpt == option} variant=option onClick={_ => setAnswerOpt(_ => option)}
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
  let (answerOpt, setAnswerOpt) = React.useState(_ => Vote.Full.Unknown)
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  // React.useEffect1(_ => {
  //   let msgsOpt = {
  //     let answer = answerOpt->Belt.Option.getWithDefault(1)
  //     Some([
  //       Msg.Input.VoteMsg({
  //         voterAddress: address,
  //         proposalID,
  //         option: answer,
  //       }),
  //     ])
  //   }
  //   setMsgsOpt(_ => msgsOpt)
  //   None
  // }, [answerOpt])

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
