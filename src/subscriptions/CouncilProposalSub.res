open Council
module Status = {
  type t =
    | VotingPeriod
    | WaitingVeto
    | VetoPeriod
    | RejectedByCouncil
    | RejectedByVeto
    | Executed
    | ExecutionFailed
    | TallyingFailed
    | Unknown

  let parse = json =>
    switch json->GraphQLParser.string {
    | "VotingPeriod" => VotingPeriod
    | "WaitingVeto" => WaitingVeto
    | "VetoPeriod" => VetoPeriod
    | "RejectedByCouncil" => RejectedByCouncil
    | "RejectedByVeto" => RejectedByVeto
    | "Executed" => Executed
    | "ExecutionFailed" => ExecutionFailed
    | "TallyingFailed" => TallyingFailed
    | _ => Unknown
    }

  let serialize = status => {
    let str = switch status {
    | VotingPeriod => "VotingPeriod"
    | WaitingVeto => "WaitingVeto"
    | VetoPeriod => "VetoPeriod"
    | RejectedByCouncil => "RejectedByCouncil"
    | RejectedByVeto => "RejectedByVeto"
    | Executed => "Executed"
    | ExecutionFailed => "ExecutionFailed"
    | TallyingFailed => "TallyingFailed"
    | Unknown => "Unknown"
    }
    str->Js.Json.string
  }
}

type proposal_t = {
  id: ID.LegacyProposal.t,
  yesVote: option<float>,
  noVote: option<float>,
  noWithVetoVote: option<float>,
  abstainVote: option<float>,
  totalBondedTokens: option<float>,
  totalDeposit: list<Coin.t>,
}

module CurrentStatus = {
  type t = Pass | Reject

  let fromBool = bool =>
    switch bool {
    | true => Pass
    | false => Reject
    }

  let getStatusText = status =>
    switch status {
    | Pass => "Pass"
    | Reject => "Reject"
    }

  let getStatusColor = (status, theme: Theme.t) =>
    switch status {
    | Pass => theme.success_600
    | Reject => theme.error_600
    }

  let getStatusColorInverse = (status, theme: Theme.t) =>
    switch status {
    | Reject => theme.success_600
    | Pass => theme.error_600
    }
}

module VetoProposal = {
  type t = {
    id: ID.LegacyProposal.t,
    status: CurrentStatus.t,
    yesVote: float,
    noVote: float,
    noWithVetoVote: float,
    abstainVote: float,
    totalVote: float,
    yesVotePercent: float,
    noVotePercent: float,
    noWithVetoVotePercent: float,
    abstainVotePercent: float,
    totalBondedTokens: float,
    turnout: float,
    totalDeposit: list<Coin.t>,
    isYesPassed: CurrentStatus.t,
    isTurnoutPassed: CurrentStatus.t,
  }

  // percent of yes vote to win
  let yesTheshold = 50.
  let turnoutTheshold = 40.

  let fromProposal = (proposal: proposal_t) => {
    let yesVote = proposal.yesVote->Belt.Option.getWithDefault(0.)
    let noVote = proposal.noVote->Belt.Option.getWithDefault(0.)
    let noWithVetoVote = proposal.noWithVetoVote->Belt.Option.getWithDefault(0.)
    let abstainVote = proposal.abstainVote->Belt.Option.getWithDefault(0.)
    let totalVote = yesVote +. noVote +. noWithVetoVote +. abstainVote
    let yesVotePercent = totalVote == 0. ? 0. : yesVote /. totalVote *. 100.
    let totalBondedTokens = proposal.totalBondedTokens->Belt.Option.getWithDefault(1.)
    let turnout = totalVote /. totalBondedTokens *. 100.
    let isYesPassed = yesVotePercent >= yesTheshold
    let isTurnoutPassed = turnout >= turnoutTheshold

    {
      id: proposal.id,
      status: switch isYesPassed && isTurnoutPassed {
      | true => CurrentStatus.Pass
      | false => Reject
      },
      yesVote,
      noVote,
      noWithVetoVote,
      abstainVote,
      totalVote,
      yesVotePercent,
      noVotePercent: totalVote == 0. ? 0. : noVote /. totalVote *. 100.,
      noWithVetoVotePercent: totalVote == 0. ? 0. : noWithVetoVote /. totalVote *. 100.,
      abstainVotePercent: totalVote == 0. ? 0. : abstainVote /. totalVote *. 100.,
      totalBondedTokens,
      turnout,
      totalDeposit: proposal.totalDeposit,
      isYesPassed: isYesPassed->CurrentStatus.fromBool,
      isTurnoutPassed: isTurnoutPassed->CurrentStatus.fromBool,
    }
  }
}

type proposal_type_t = Tech | Grant | BandDAO | Unknown

type internal_t = {
  id: ID.Proposal.t,
  title: string,
  council: council_t,
  councilId: int,
  account: account_t,
  status: Status.t,
  totalWeight: int,
  vetoId: option<int>,
  yesVote: option<float>,
  noVote: option<float>,
  submitTime: MomentRe.Moment.t,
  vetoEndTime: option<MomentRe.Moment.t>,
  votingEndTime: MomentRe.Moment.t,
  proposal: option<proposal_t>,
  metadata: string,
  messages: Js.Json.t,
}

type t = {
  id: ID.Proposal.t,
  title: string,
  council: council_t,
  councilId: int,
  account: account_t,
  status: Status.t,
  totalWeight: int,
  vetoId: option<int>,
  yesVote: float,
  yesVotePercent: float,
  noVote: float,
  noVotePercent: float,
  submitTime: MomentRe.Moment.t,
  vetoEndTime: option<MomentRe.Moment.t>,
  votingEndTime: MomentRe.Moment.t,
  vetoProposalOpt: option<VetoProposal.t>,
  metadata: string,
  messages: list<Msg.result_t>,
  proposalType: proposal_type_t,
  councilVoteStatus: CurrentStatus.t, // indicate is council yes vote passed
  currentStatus: CurrentStatus.t, // same as councilVoteStatus but check if veto pass or not
  isCurrentRejectByVeto: bool,
}

module SingleConfig = %graphql(`
  subscription CouncilProposal($id: Int!) {
    council_proposals_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.ProposalID")
      title
      council @ppxAs(type: "council_t") {
        id
        name @ppxCustom(module: "CouncilNameParser")
        account @ppxAs(type: "account_t") {
          address @ppxCustom(module:"GraphQLParserModule.Address")
        }
        councilMembers :council_members @ppxAs(type: "council_member_t") {
          account @ppxAs(type: "account_t") {
            address @ppxCustom(module:"GraphQLParserModule.Address")
          }
          weight @ppxCustom(module:"GraphQLParserModule.IntString")
          metadata
          since @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      account @ppxAs(type: "account_t") {
        address @ppxCustom(module:"GraphQLParserModule.Address")
      }
      councilId: council_id
      vetoId: veto_id
      status @ppxCustom(module: "Status")
      totalWeight: total_weight @ppxCustom(module: "GraphQLParserModule.IntString")
      yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      vetoEndTime: veto_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      proposal @ppxAs(type: "proposal_t") {
        id @ppxCustom(module: "GraphQLParserModule.LegacyProposalID")
        yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        totalBondedTokens: total_bonded_tokens @ppxCustom(module: "GraphQLParserModule.FloatString")
        totalDeposit: total_deposit @ppxCustom(module: "GraphQLParserModule.Coins")
      }
      metadata
      messages
    }
  }
`)

module MultiConfig = %graphql(`
  subscription CouncilProposals($filter: String!, $limit: Int!, $offset: Int!) {
    council_proposals(where: {council: { name: { _ilike: $filter}}}, limit: $limit, offset: $offset, order_by: [{id: desc}]) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.ProposalID")
      title
      council @ppxAs(type: "council_t") {
        id
        name @ppxCustom(module: "CouncilNameParser")
        account @ppxAs(type: "account_t") {
          address @ppxCustom(module:"GraphQLParserModule.Address")
        }
        councilMembers :council_members @ppxAs(type: "council_member_t") {
          account @ppxAs(type: "account_t") {
            address @ppxCustom(module:"GraphQLParserModule.Address")
          }
          weight @ppxCustom(module:"GraphQLParserModule.IntString")
          metadata
          since @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      account @ppxAs(type: "account_t") {
        address @ppxCustom(module:"GraphQLParserModule.Address")
      }
      councilId: council_id
      vetoId: veto_id
      status @ppxCustom(module: "Status")
      totalWeight: total_weight @ppxCustom(module: "GraphQLParserModule.IntString")
      yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      vetoEndTime: veto_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      proposal @ppxAs(type: "proposal_t") {
        id @ppxCustom(module: "GraphQLParserModule.LegacyProposalID")
        yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        totalBondedTokens: total_bonded_tokens @ppxCustom(module: "GraphQLParserModule.FloatString")
        totalDeposit: total_deposit @ppxCustom(module: "GraphQLParserModule.Coins")
      }
      metadata
      messages
    }
  }
`)

module CountConfig = %graphql(`
    subscription CouncilProposalCount {
      council_proposals_aggregate {
        aggregate {
          count
        }
      }
    }
`)

let proposalsTypeStr = ["All", "Tech Proposal", "Grant Proposal", "BandDAO Proposal"]
let getFilter = str =>
  switch str {
  | "All" => "%%"
  | "Tech Proposal" => "%TECH%"
  | "Grant Proposal" => "%GRANT%"
  | "BandDAO Proposal" => "%BAND_DAO%"
  | _ => ""
  }

let parseProposalType = councilName =>
  switch councilName {
  | BandDaoCouncil => BandDAO
  | GrantCouncil => Grant
  | TechCouncil => Tech
  | Unspecified => Unknown
  }

// percent of yes vote required for proposal to win
let passedTheshold = 50.

let toExternal = (
  {
    id,
    title,
    council,
    councilId,
    account,
    status,
    vetoId,
    vetoEndTime,
    yesVote,
    noVote,
    votingEndTime,
    proposal,
    metadata,
    messages,
    submitTime,
    totalWeight,
  }: internal_t,
) => {
  let yesVotePercent =
    yesVote->Belt.Option.getWithDefault(0.) /. totalWeight->Belt.Int.toFloat *. 100.
  let noVotePercent =
    noVote->Belt.Option.getWithDefault(0.) /. totalWeight->Belt.Int.toFloat *. 100.
  let vetoProposalOpt = proposal->Belt.Option.map(VetoProposal.fromProposal)

  {
    id,
    title,
    councilId,
    account,
    status,
    vetoId,
    vetoEndTime,
    council,
    yesVote: yesVote->Belt.Option.getWithDefault(0.),
    yesVotePercent,
    noVote: noVote->Belt.Option.getWithDefault(0.),
    noVotePercent,
    votingEndTime,
    vetoProposalOpt,
    metadata,
    messages: {
      let msg = messages->Js.Json.decodeArray
      switch msg {
      | Some(msg) => msg->Belt.List.fromArray
      | None => []->Belt.List.fromArray
      }->Belt.List.map(each => Msg.decodeMsg(each, false))
    },
    submitTime,
    totalWeight,
    proposalType: council.name->parseProposalType,
    councilVoteStatus: switch yesVotePercent >= passedTheshold {
    | true => Pass
    | false => Reject
    },
    currentStatus: switch yesVotePercent >= passedTheshold {
    | true =>
      switch vetoProposalOpt {
      | Some(vetoProposal) =>
        switch vetoProposal.status {
        | Pass => Reject
        | Reject => Pass
        }
      | None => Pass
      }
    | false => Reject
    },
    isCurrentRejectByVeto: switch yesVotePercent >= passedTheshold {
    | true =>
      switch vetoProposalOpt {
      | Some(vetoProposal) =>
        switch vetoProposal.status {
        | Pass => true
        | Reject => false
        }
      | None => false
      }
    | false => false
    },
  }
}

let get = id => {
  let result = SingleConfig.use({id: id->ID.Proposal.toInt})

  result
  ->Sub.fromData
  ->Sub.flatMap(({council_proposals_by_pk}) => {
    switch council_proposals_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~filter, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({filter: filter->getFilter, limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.council_proposals->Belt.Array.map(toExternal))
}

let count = () => {
  let result = CountConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.council_proposals_aggregate.aggregate->Belt.Option.mapWithDefault(0, a => a.count)
  )
}
