type account_t = {address: Address.t}

type council_member_t = {
  account: account_t,
  weight: int,
  metadata: string,
  since: MomentRe.Moment.t,
}

type council_t = {
  id: int,
  name: CouncilSub.council_name_t,
  account: account_t,
  councilMembers: array<council_member_t>,
}

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
  yesVote: option<float>,
  noVote: option<float>,
  noWithVetoVote: option<float>,
  abstainVote: option<float>,
  totalBondedTokens: option<float>,
}

module VetoProposal = {
  type status_t = Pass | Reject
  type t = {
    status: status_t,
    turnOut: float,
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
  }

  // percent of yes vote to win
  let passedTheshold = 50.

  let fromProposal = (proposal: proposal_t) => {
    let yesVote = proposal.yesVote->Belt.Option.getWithDefault(0.)
    let noVote = proposal.noVote->Belt.Option.getWithDefault(0.)
    let noWithVetoVote = proposal.noWithVetoVote->Belt.Option.getWithDefault(0.)
    let abstainVote = proposal.abstainVote->Belt.Option.getWithDefault(0.)
    let totalVote = yesVote +. noVote +. noWithVetoVote +. abstainVote
    let yesVotePercent = yesVote /. totalVote *. 100.
    let totalBondedTokens = proposal.totalBondedTokens->Belt.Option.getWithDefault(0.)

    {
      status: switch yesVotePercent > passedTheshold {
      | true => Pass
      | false => Reject
      },
      turnOut: totalVote,
      yesVote,
      noVote,
      noWithVetoVote,
      abstainVote,
      totalVote,
      yesVotePercent,
      noVotePercent: noVote /. totalVote *. 100.,
      noWithVetoVotePercent: noWithVetoVote /. totalVote *. 100.,
      abstainVotePercent: abstainVote /. totalVote *. 100.,
      totalBondedTokens,
    }
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
}

type proposal_type_t = Tech | Grant | BandDAO | Unknown

type internal_t = {
  id: ID.Proposal.t,
  title: string,
  council: council_t,
  councilId: int,
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
  status: Status.t,
  totalWeight: int,
  vetoId: option<int>,
  yesVote: float,
  yesVotePercent: float,
  noVote: float,
  submitTime: MomentRe.Moment.t,
  vetoEndTime: option<MomentRe.Moment.t>,
  votingEndTime: MomentRe.Moment.t,
  vetoProposal: option<VetoProposal.t>,
  metadata: string,
  messages: Js.Json.t,
  proposalType: proposal_type_t,
}

module SingleConfig = %graphql(`
  subscription CouncilProposal($id: Int!) {
    council_proposals_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.ProposalID")
      title
      council @ppxAs(type: "council_t") {
        id
        name @ppxCustom(module: "CouncilSub.CouncilName")
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
        yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        totalBondedTokens: total_bonded_tokens @ppxCustom(module: "GraphQLParserModule.FloatString")
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
        name @ppxCustom(module: "CouncilSub.CouncilName")
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
        yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        totalBondedTokens: total_bonded_tokens @ppxCustom(module: "GraphQLParserModule.FloatString")
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
  | "Tech Proposal" => "%Tech%"
  | "Grant Proposal" => "%Grant%"
  | "BandDAO Proposal" => "%BandDAO%"
  | _ => ""
  }

let parseProposalType = councilName =>
  switch councilName {
  | CouncilSub.BandDaoCouncil => BandDAO
  | GrantCouncil => Grant
  | TechCouncil => Tech
  | Unknown => Unknown
  }

let toExternal = (
  {
    id,
    title,
    council,
    councilId,
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
  {
    id,
    title,
    councilId,
    status,
    vetoId,
    vetoEndTime,
    council,
    yesVote: yesVote->Belt.Option.getWithDefault(0.),
    yesVotePercent: yesVote->Belt.Option.getWithDefault(0.) /.
    totalWeight->Belt.Int.toFloat *. 100.,
    noVote: noVote->Belt.Option.getWithDefault(0.),
    votingEndTime,
    vetoProposal: proposal->Belt.Option.map(VetoProposal.fromProposal),
    metadata,
    messages,
    submitTime,
    totalWeight,
    proposalType: council.name->parseProposalType,
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
