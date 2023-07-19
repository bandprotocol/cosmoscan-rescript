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
    txHashOpt: option<Hash.t>,
    optionOpt: option<VoteSub.vote_t>,
    timestampOpt: option<MomentRe.Moment.t>,
  }

  let voteToVoteRow = (vote: VoteSub.t, option) => {
    {
      address: vote.voter,
      txHashOpt: vote.txHashOpt,
      optionOpt: Some(option),
      timestampOpt: vote.timestampOpt,
    }
  }

  let allVoteToVoteRow = (vote: VoteSub.t) => {
    {
      address: vote.voter,
      txHashOpt: vote.txHashOpt,
      optionOpt: Some(vote.option),
      timestampOpt: vote.timestampOpt,
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
          {switch vote.txHashOpt {
          | Some(txHash) =>
            <TxLink txHash width=110 size=Text.Body1 weight=Text.Regular fullHash=false />
          | None => React.null
          }}
        </Col>
        <Col col=Col.Two>
          {switch vote.optionOpt {
          | Some(option_) =>
            <Text
              value={option_->Vote.Full.toString}
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

module VoteRowLoading = {
  @react.component
  let make = (~reserveIndex) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)
    <div key=reserveIndex className={Styles.voteRowContainer(theme, isDarkMode)}>
      <LoadingCensorBar width=1000 height=22 />
    </div>
  }
}

type filter_choice_t = All | Yes | No | NoWithVeto | Abstain

let toVote = choice =>
  switch choice {
  | All => Vote.Full.Yes
  | Yes => Vote.Full.Yes
  | No => Vote.Full.No
  | NoWithVeto => Vote.Full.NoWithVeto
  | Abstain => Vote.Full.Abstain
  }

let choiceString = choice =>
  switch choice {
  | All => "ALL"
  | Yes => "YES"
  | No => "NO"
  | NoWithVeto => "NoWithVeto"
  | Abstain => "Abstain"
  }

@react.component
let make = (~proposalID, ~members: array<CouncilProposalSub.council_member_t>) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (filter, setFilter) = React.useState(_ => All)

  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5
  let votesSub = VoteSub.getList(proposalID, filter->toVote, ~pageSize, ~page, ())
  let votesSubAll = VoteSub.getListAll(proposalID, ~pageSize, ~page, ())
  let allVoteSub = Sub.all2(votesSub, votesSubAll)

  let voteCountSub = VoteSub.countAll(proposalID)

  let pageCount = switch voteCountSub {
  | Data((yes, no, noWithVeto, abstain)) =>
    let count = switch filter {
    | All => yes + no + noWithVeto + abstain
    | Yes => yes
    | No => no
    | NoWithVeto => noWithVeto
    | Abstain => abstain
    }
    Js.Math.ceil_int(count->Belt.Int.toFloat /. pageSize->Belt.Int.toFloat)
  | _ => 0
  }

  <>
    <Row marginTop=40 marginBottom=16>
      <Col>
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <Heading
            value={`Votes`}
            size=Heading.H4
            weight=Heading.Semibold
            color={theme.neutral_600}
            marginRight=24
          />
          {switch voteCountSub {
          | Data(yesVote, noVote, noWithVetoVote, abstainVote) => {
              let totalVoteCount = yesVote + noVote + noWithVetoVote + abstainVote
              let votesArray = [totalVoteCount, yesVote, noVote, noWithVetoVote, abstainVote]

              <div className={CssHelper.flexBox()}>
                {[All, Yes, No, NoWithVeto, Abstain]
                ->Belt.Array.mapWithIndex((index, choice) =>
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
                      {`${choice->choiceString} (${votesArray
                        ->Belt.Array.get(index)
                        ->Belt.Option.getExn
                        ->Belt.Int.toString})`->React.string}
                    </ChipButton>
                  </React.Fragment>
                )
                ->React.array}
              </div>
            }

          | _ => React.null
          }}
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
    {switch allVoteSub {
    | Data(votes, allVotes) =>
      <>
        {switch filter {
        | All =>
          allVotes
          ->Belt.Array.map(vote => <VoteRow vote={vote->VoteRow.allVoteToVoteRow} />)
          ->React.array
        | _ =>
          votes
          ->Belt.Array.map(vote => <VoteRow vote={vote->VoteRow.voteToVoteRow(filter->toVote)} />)
          ->React.array
        }}
        <Pagination currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)} />
      </>
    | _ =>
      [1, 2, 3, 4, 5]
      ->Belt.Array.mapWithIndex((index, _) =>
        <VoteRowLoading reserveIndex={index->Belt.Int.toString} />
      )
      ->React.array
    }}
  </>
}
