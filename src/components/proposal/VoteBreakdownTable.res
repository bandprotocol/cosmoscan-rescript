module Styles = {
  open CssJs

  let chip = style(. [borderRadius(#px(20)), marginRight(#px(8))])
  let voteRowContainer = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      padding2(~v=#px(16), ~h=#px(32)),
      borderRadius(#px(16)),
      marginBottom(#px(8)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      border(#px(1), #solid, theme.neutral_100),
      Media.mobile([padding2(~v=#px(16), ~h=#px(16))]),
    ])
}

module VoteRow = {
  type t = {
    address: Address.t,
    transactionOpt: option<CouncilVoteSub.transaction_t>,
    optionOpt: option<Vote.YesNo.t>,
    timestampOpt: option<MomentRe.Moment.t>,
  }

  let voteToVoteRow = (vote: CouncilVoteSub.t) => {
    {
      address: vote.account.address,
      transactionOpt: vote.transactionOpt,
      optionOpt: Some(vote.option),
      timestampOpt: vote.timestampOpt,
    }
  }

  let memberToVoteRow = (member: CouncilProposalSub.council_member_t) => {
    {
      address: member.account.address,
      transactionOpt: None,
      optionOpt: None,
      timestampOpt: None,
    }
  }

  @react.component
  let make = (~vote: t) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

    <div
      key={vote.address->Address.toBech32} className={Styles.voteRowContainer(theme, isDarkMode)}>
      <Row>
        <Col col=Col.Three>
          <AddressRender address={vote.address} position={Subtitle} ellipsis=true />
        </Col>
        <Col col=Col.Four>
          {switch vote.transactionOpt {
          | Some(tx) =>
            <TxLink txHash=tx.hash width=110 size=Text.Body1 weight=Text.Regular fullHash=false />
          | None => React.null
          }}
        </Col>
        <Col col=Col.Two>
          {switch vote.optionOpt {
          | Some(option_) =>
            <Text
              value={option_->Vote.YesNo.toString}
              weight=Text.Medium
              color={switch option_ {
              | Yes => theme.success_600
              | _ => theme.error_600
              }}
              size={Body1}
            />
          | None => React.null
          }}
        </Col>
        <Col col=Col.Three style={CssHelper.flexBox(~justify=#end_, ())}>
          <Timestamp
            timeOpt=vote.timestampOpt
            size=Text.Body1
            weight=Text.Regular
            textAlign=Text.Right
            defaultText=""
          />
        </Col>
      </Row>
    </div>
  }
}

type filterChoice = All | Yes | No | DidNotVote

let choiceString = choice =>
  switch choice {
  | All => "ALL"
  | Yes => "YES"
  | No => "NO"
  | DidNotVote => "DID NOT VOTE"
  }

@react.component
let make = (
  ~members: array<CouncilProposalSub.council_member_t>,
  ~votes: array<CouncilVoteSub.t>,
) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (filter, setFilter) = React.useState(_ => All)

  let yesVotes = votes->Belt.Array.keep(vote => vote.option == Yes)
  let noVotes = votes->Belt.Array.keep(vote => vote.option == No)

  let choiceVoteCount = choice =>
    switch choice {
    | All => members->Belt.Array.length
    | Yes => yesVotes->Belt.Array.length
    | No => noVotes->Belt.Array.length
    | DidNotVote => members->Belt.Array.length - votes->Belt.Array.length
    }

  let voteAddressList = votes->Belt.Array.map(vote => vote.account.address)->Belt.List.fromArray

  let notVoteMember =
    members->Belt.Array.keep(member =>
      !(voteAddressList->Belt.List.has(member.account.address, (a, b) => Address.isEqual(a, b)))
    )

  <>
    <Row marginBottom=16>
      <Col>
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <Heading
            value={`Votes`}
            size=Heading.H4
            weight=Heading.Semibold
            color={theme.neutral_600}
            marginRight=24
          />
          <div className={CssHelper.flexBox()}>
            {[All, Yes, No, DidNotVote]
            ->Belt.Array.map(choice =>
              <React.Fragment key={choice->choiceString}>
                <ChipButton
                  variant={ChipButton.Primary}
                  onClick={_ => setFilter(_ => choice)}
                  isActive={filter == choice}
                  color=theme.neutral_700
                  activeColor=theme.white
                  bgColor=theme.neutral_100
                  activeBgColor=theme.neutral_700
                  style={Styles.chip}>
                  {`${choice->choiceString} (${choice
                    ->choiceVoteCount
                    ->Belt.Int.toString})`->React.string}
                </ChipButton>
              </React.Fragment>
            )
            ->React.array}
          </div>
        </div>
      </Col>
    </Row>
    <Row marginBottom=8 style={CssHelper.px(~size=32, ())}>
      <Col col=Col.Three>
        <Text block=true value="VOTERS" size=Text.Caption weight=Text.Semibold />
      </Col>
      <Col col=Col.Four>
        <Text block=true value="TX HASH" size=Text.Caption weight=Text.Semibold />
      </Col>
      <Col col=Col.Two>
        <Text block=true value="ANSWER" size=Text.Caption weight=Text.Semibold />
      </Col>
      <Col col=Col.Three>
        <Text block=true value="TIME" size=Text.Caption weight=Text.Semibold align=Text.Right />
      </Col>
    </Row>
    {switch filter {
    | All => votes->Belt.Array.map(vote => <VoteRow vote={vote->VoteRow.voteToVoteRow} />)
    | Yes => yesVotes->Belt.Array.map(vote => <VoteRow vote={vote->VoteRow.voteToVoteRow} />)
    | No => noVotes->Belt.Array.map(vote => <VoteRow vote={vote->VoteRow.voteToVoteRow} />)
    | DidNotVote =>
      notVoteMember->Belt.Array.map(vote => <VoteRow vote={vote->VoteRow.memberToVoteRow} />)
    }->React.array}
  </>
}
