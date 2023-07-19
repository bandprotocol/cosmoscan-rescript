module ProposalType = {
  type t =
    | SoftwareUpgrade
    | ParameterChange
    | CommunityPoolSpend
    | Undefined

  let parse = proposalType => {
    switch proposalType {
    | "SoftwareUpgrade" => SoftwareUpgrade
    | "ParameterChange" => ParameterChange
    | "CommunityPoolSpend" => CommunityPoolSpend
    | _ => Undefined
    }
  }

  let getBadgeText = proposalT => {
    switch proposalT {
    | CommunityPoolSpend => "Community Pool Spend"
    | SoftwareUpgrade => "Software Upgrade"
    | ParameterChange => "Parameter Change"
    | Undefined => "Undefined"
    }
  }
}

module Content = {
  type parameter_change_t = {
    subspace: string,
    key: string,
    value: string,
  }

  type sofeware_upgrade_t = {
    name: string,
    time: MomentRe.Moment.t,
    height: int,
  }

  type community_pool_spend_t = {
    recipient: Address.t,
    amount: list<Coin.t>,
  }

  let decodeParameterChangeContent = {
    open JsonUtils.Decode

    object(fields => {
      subspace: fields.required(. "subspace", string),
      key: fields.required(. "key", string),
      value: fields.required(. "value", string),
    })
  }

  let decodeSoftwareUpgradeContent = {
    open JsonUtils.Decode

    buildObject(json => {
      {
        name: json.required(list{"name"}, string),
        time: json.required(list{"time"}, moment),
        height: json.required(list{"height"}, int),
      }
    })
  }

  let decodeCommunityPoolSpendContent = {
    open JsonUtils.Decode

    buildObject(json => {
      {
        recipient: json.required(list{"recipient"}, address),
        amount: json.required(list{"amount"}, list(Coin.decodeCoin)),
      }
    })
  }
}

type content_t =
  | SoftwareUpgrade(Content.sofeware_upgrade_t)
  | ParameterChange(array<Content.parameter_change_t>)
  | CommunityPoolSpend(Content.community_pool_spend_t)
  | Unknown

type proposal_status_t =
  | Deposit
  | Voting
  | Passed
  | Rejected
  | Failed
  | Inactive

let getStatusColor = (status, theme: Theme.t) =>
  switch status {
  | Passed => theme.success_600
  | _ => theme.error_600
  }

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
  let serialize = status => {
    let str = switch status {
    | Deposit => "DepositPeriod"
    | Voting => "VotingPeriod"
    | Passed => "Passed"
    | Rejected => "Rejected"
    | Failed => "Failed"
    | Inactive => "Inactive"
    }
    str->Js.Json.string
  }
}

type account_t = {address: Address.t}

type deposit_t = {amount: list<Coin.t>}

type total_deposit_t = {deposits: array<deposit_t>}

type internal_t = {
  id: ID.LegacyProposal.t,
  title: string,
  status: proposal_status_t,
  description: string,
  contentOpt: option<Js.Json.t>,
  submitTime: MomentRe.Moment.t,
  depositEndTime: MomentRe.Moment.t,
  votingStartTime: option<MomentRe.Moment.t>,
  votingEndTime: option<MomentRe.Moment.t>,
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
  id: ID.LegacyProposal.t,
  title: string,
  status: proposal_status_t,
  description: string,
  content: content_t,
  submitTime: MomentRe.Moment.t,
  depositEndTime: MomentRe.Moment.t,
  votingStartTime: option<MomentRe.Moment.t>,
  votingEndTime: option<MomentRe.Moment.t>,
  proposerAddressOpt: option<Address.t>,
  proposalType: ProposalType.t,
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

let decodeContent = (json, proposalType) => {
  let content = {
    open JsonUtils.Decode
    switch proposalType {
    | ProposalType.ParameterChange => {
        let contentObj = json->mustGet("changes", array(Content.decodeParameterChangeContent))
        ParameterChange(contentObj)
      }

    | SoftwareUpgrade => {
        let contentObj = json->mustGet("plan", Content.decodeSoftwareUpgradeContent)
        SoftwareUpgrade(contentObj)
      }

    | CommunityPoolSpend => {
        let contentObj = json->mustDecode(Content.decodeCommunityPoolSpendContent)
        CommunityPoolSpend(contentObj)
      }

    | _ => Unknown
    }
  }
  content
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
    title,
    status,
    description,
    // TODO: This field expect to exist on every proposals, will fix schema to be required field
    content: contentOpt->Belt.Option.getExn->decodeContent(proposalType->ProposalType.parse),
    proposalType: proposalType->ProposalType.parse,
    submitTime,
    depositEndTime,
    votingStartTime,
    votingEndTime,
    proposerAddressOpt: accountOpt->Belt.Option.map(({address}) => address),
    endTotalYes: yesVote /. 1e6,
    endTotalYesPercent: totalVote != 0. ? yesVote /. totalVote *. 100. : 0.,
    endTotalNo: noVote /. 1e6,
    endTotalNoPercent: totalVote != 0. ? noVote /. totalVote *. 100. : 0.,
    endTotalNoWithVeto: noWithVetoVote /. 1e6,
    endTotalNoWithVetoPercent: totalVote != 0. ? noWithVetoVote /. totalVote *. 100. : 0.,
    endTotalAbstain: abstainVote /. 1e6,
    endTotalAbstainPercent: totalVote != 0. ? abstainVote /. totalVote *. 100. : 0.,
    endTotalVote: totalVote /. 1e6,
    totalBondedTokens: total_bonded_tokens->Belt.Option.map(d => d /. 1e6),
    totalDeposit,
  }
}

module SingleConfig = %graphql(`
  subscription Proposal($id: Int!) {
    proposals_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.LegacyProposalID")
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
    proposals(limit: $limit, offset: $offset, order_by: [{id: desc}], where: {status: {_neq: "Inactive"}, type: {_neq: "CouncilVeto"}}) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.LegacyProposalID")
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
    proposals_aggregate( where: {status: {_neq: "Inactive"}, type: {_neq: "CouncilVeto"}}){
      aggregate{
        count 
      }
    }
  }
`)

module DepositAmountConfig = %graphql(`
  subscription DepositAmount($id: Int!) {
    proposals( where: {id: {_eq: $id}}) @ppxAs(type: "total_deposit_t"){
      deposits @ppxAs(type: "deposit_t") {
        amount @ppxCustom(module: "GraphQLParserModule.Coins")
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
  let result = SingleConfig.use({id: id->ID.LegacyProposal.toInt})

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

let totalDeposit = id => {
  let result = DepositAmountConfig.use({id: id})

  result
  ->Sub.fromData
  ->Sub.map(x => {
    x.proposals
    ->Belt.Array.get(0)
    ->Belt.Option.map(proposal =>
      proposal.deposits->Belt.Array.reduce(
        0.,
        (acc, deposit) => acc +. deposit.amount->Coin.getBandAmountFromCoins,
      )
    )
  })
}
