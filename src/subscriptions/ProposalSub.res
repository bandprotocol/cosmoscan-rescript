module Changes = {
  type changes_t = {
    subspace: string,
    key: string,
    value: string,
  }

  let decode = {
    open JsonUtils.Decode

    object(fields => {
      subspace: fields.required(. "subspace", string),
      key: fields.required(. "key", string),
      value: fields.required(. "value", string),
    })
  }
}

module Plan = {
  type plan_t = {
    name: string,
    time: MomentRe.Moment.t,
    height: int,
  }

  let decode = {
    open JsonUtils.Decode

    buildObject(json => {
      {
        name: json.required(list{"name"}, string),
        time: json.required(list{"time"}, moment),
        height: json.required(list{"height"}, int),
      }
    })
  }
}

// TODO: Create data type for each proposal type
module Content = {
  type t = {
    title: string,
    description: string,
    changes: option<array<Changes.changes_t>>,
    plan: option<Plan.plan_t>,
  }

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      {
        title: fields.required(. "title", string),
        description: fields.required(. "description", string),
        changes: fields.optional(. "changes", array(Changes.decode)),
        plan: fields.optional(. "plan", Plan.decode),
      }
    })
  }
}

type proposal_status_t =
  | Deposit
  | Voting
  | Passed
  | Rejected
  | Failed
  | Inactive

module ProposalStatus = {
  type t = proposal_status_t
  let parse = json => {
    exception NotFound(string)
    let status = json->Js.Json.decodeString->Belt.Option.getExn
    switch status {
    | "DepositPeriod" => Deposit
    | "VotingPeriod" => Voting
    | "Passed" => Passed
    | "Rejected" => Rejected
    | "Failed" => Failed
    | "Inactive" => Inactive
    | _ => raise(NotFound("The proposal status is not existing"))
    }
  }
  //TODO: implement for status
  let serialize = status =>
    switch status {
    | Deposit => "DepositPeriod"->Js.Json.string
    | Voting => "VotingPeriod"->Js.Json.string
    | Passed => "Passed"->Js.Json.string
    | Rejected => "Rejected"->Js.Json.string
    | Failed => "Failed"->Js.Json.string
    | Inactive => "Inactive"->Js.Json.string
    }
}

type account_t = {address: Address.t}

type deposit_t = {amount: list<Coin.t>}

type internal_t = {
  id: ID.Proposal.t,
  title: string,
  status: proposal_status_t,
  description: string,
  contentOpt: option<Js.Json.t>,
  submitTime: MomentRe.Moment.t,
  depositEndTime: MomentRe.Moment.t,
  votingStartTime: MomentRe.Moment.t,
  votingEndTime: MomentRe.Moment.t,
  accountOpt: option<account_t>,
  proposalType: string,
  yes_vote: option<float>,
  no_vote: option<float>,
  no_with_veto_vote: option<float>,
  abstain_vote: option<float>,
  total_bonded_tokens: option<float>,
  totalDeposit: list<Coin.t>,
}

type t = {
  id: ID.Proposal.t,
  name: string,
  status: proposal_status_t,
  description: string,
  content: Content.t,
  submitTime: MomentRe.Moment.t,
  depositEndTime: MomentRe.Moment.t,
  votingStartTime: MomentRe.Moment.t,
  votingEndTime: MomentRe.Moment.t,
  proposerAddressOpt: option<Address.t>,
  proposalType: string,
  endTotalYes: float,
  endTotalYesPercent: float,
  endTotalNo: float,
  endTotalNoPercent: float,
  endTotalNoWithVeto: float,
  endTotalNoWithVetoPercent: float,
  endTotalAbstain: float,
  endTotalAbstainPercent: float,
  endTotalVote: float,
  totalBondedTokens: option<float>,
  totalDeposit: list<Coin.t>,
}

let toExternal = ({
  id,
  title,
  status,
  description,
  contentOpt,
  submitTime,
  depositEndTime,
  votingStartTime,
  votingEndTime,
  accountOpt,
  proposalType,
  yes_vote,
  no_vote,
  no_with_veto_vote,
  abstain_vote,
  total_bonded_tokens,
  totalDeposit,
}) => {
  let yesVote = yes_vote->Belt.Option.getWithDefault(0.)
  let noVote = no_vote->Belt.Option.getWithDefault(0.)
  let noWithVetoVote = no_with_veto_vote->Belt.Option.getWithDefault(0.)
  let abstainVote = abstain_vote->Belt.Option.getWithDefault(0.)
  let totalVote = yesVote +. noVote +. noWithVetoVote +. abstainVote

  {
    id,
    name: title,
    status,
    description,
    // TODO: This field expect to exist on every proposals, will fix schema to be required field
    content: contentOpt->Belt.Option.getExn->JsonUtils.Decode.mustDecode(Content.decode),
    submitTime,
    depositEndTime,
    votingStartTime,
    votingEndTime,
    proposerAddressOpt: accountOpt->Belt.Option.map(({address}) => address),
    proposalType,
    endTotalYes: yesVote /. 1e6,
    endTotalYesPercent: yesVote /. totalVote *. 100.,
    endTotalNo: noVote /. 1e6,
    endTotalNoPercent: noVote /. totalVote *. 100.,
    endTotalNoWithVeto: noWithVetoVote /. 1e6,
    endTotalNoWithVetoPercent: noWithVetoVote /. totalVote *. 100.,
    endTotalAbstain: abstainVote /. 1e6,
    endTotalAbstainPercent: abstainVote /. totalVote *. 100.,
    endTotalVote: totalVote /. 1e6,
    totalBondedTokens: total_bonded_tokens->Belt.Option.map(d => d /. 1e6),
    totalDeposit,
  }
}

module SingleConfig = %graphql(`
  subscription Proposal($id: Int!) {
    proposals_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.ProposalID")
      title
      status @ppxCustom(module: "ProposalStatus")
      description
      contentOpt: content
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      depositEndTime: deposit_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingStartTime: voting_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      proposalType: type
      yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      accountOpt: account @ppxAs(type: "account_t") {
          address @ppxCustom(module: "GraphQLParserModule.Address")
      }
      total_bonded_tokens @ppxCustom(module: "GraphQLParserModule.FloatString")
      totalDeposit: total_deposit @ppxCustom(module: "GraphQLParserModule.Coins")
    }
  }
`)

module MultiConfig = %graphql(`
  subscription Proposals($limit: Int!, $offset: Int!) {
    proposals(limit: $limit, offset: $offset, order_by: [{id: desc}], where: {status: {_neq: "Inactive"}}) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.ProposalID")
      title
      status @ppxCustom(module: "ProposalStatus")
      description
      contentOpt: content
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      depositEndTime: deposit_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingStartTime: voting_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      proposalType: type
      yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      accountOpt: account @ppxAs(type: "account_t") {
        address @ppxCustom(module: "GraphQLParserModule.Address")
      }
      total_bonded_tokens @ppxCustom(module: "GraphQLParserModule.FloatString")
      totalDeposit: total_deposit @ppxCustom(module: "GraphQLParserModule.Coins")
    }
  }
`)

module ProposalsCountConfig = %graphql(`
  subscription ProposalsCount {
    proposals_aggregate{
      aggregate{
        count 
      }
    }
  }
`)

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.proposals->Belt.Array.map(toExternal))
}

let get = id => {
  let result = SingleConfig.use({id: id->ID.Proposal.toInt})

  result
  ->Sub.fromData
  ->Sub.flatMap(({proposals_by_pk}) => {
    switch proposals_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let count = () => {
  let result = ProposalsCountConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(x => x.proposals_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))
}
