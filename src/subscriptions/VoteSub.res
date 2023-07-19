type block_t = {timestamp: MomentRe.Moment.t}
type validator_t = {
  moniker: string,
  operatorAddress: Address.t,
  identity: string,
}
type account_t = {
  address: Address.t,
  validator: option<validator_t>,
}
type transaction_t = {
  hash: Hash.t,
  block: block_t,
}

type internal_t = {
  account: account_t,
  transactionOpt: option<transaction_t>,
}

type internal_all_t = {
  yes: int,
  no: int,
  noWithVeto: int,
  abstain: int,
  account: account_t,
  transactionOpt: option<transaction_t>,
}

type vote_t = Vote.Full.t

let toString = (~withSpace=false, x) =>
  switch x {
  | Vote.Full.Yes => "Yes"
  | No => "No"
  | NoWithVeto => withSpace ? "No With Veto" : "NoWithVeto"
  | Abstain => "Abstain"
  | Unknown => "Unknown"
  }

type t = {
  voter: Address.t,
  txHashOpt: option<Hash.t>,
  timestampOpt: option<MomentRe.Moment.t>,
  validator: option<validator_t>,
  option: vote_t,
}

let toExternal = (
  option: Vote.Full.t,
  {account: {address, validator}, transactionOpt}: internal_t,
) => {
  voter: address,
  txHashOpt: transactionOpt->Belt.Option.map(({hash}) => hash),
  timestampOpt: transactionOpt->Belt.Option.map(({block}) => block.timestamp),
  validator,
  option,
}

let toExternalAll = (
  {account: {address, validator}, transactionOpt, yes, no, noWithVeto, abstain}: internal_all_t,
) => {
  voter: address,
  txHashOpt: transactionOpt->Belt.Option.map(({hash}) => hash),
  timestampOpt: transactionOpt->Belt.Option.map(({block}) => block.timestamp),
  validator,
  option: switch (yes, no, noWithVeto, abstain) {
  | (1, 0, 0, 0) => Yes
  | (0, 1, 0, 0) => No
  | (0, 0, 1, 0) => NoWithVeto
  | (0, 0, 0, 1) => Abstain
  | _ => Yes
  },
}

type answer_vote_t = {
  validatorID: int,
  valPower: float,
  valVote: option<vote_t>,
  delVotes: vote_t => float,
  proposalID: ID.LegacyProposal.t,
}

type internal_vote_t = {
  yesVote: option<float>,
  noVote: option<float>,
  noWithVetoVote: option<float>,
  abstainVote: option<float>,
}

type result_val_t = {
  validatorID: int,
  validatorPower: float,
  validatorAns: option<vote_t>,
  proposalID: ID.LegacyProposal.t,
}

type vote_stat_t = {
  proposalID: ID.LegacyProposal.t,
  totalYes: float,
  totalYesPercent: float,
  totalNo: float,
  totalNoPercent: float,
  totalNoWithVeto: float,
  totalNoWithVetoPercent: float,
  totalAbstain: float,
  totalAbstainPercent: float,
  total: float,
}

type votePower = {
  totalYes: float,
  totalNo: float,
  totalNoWithVetoVote: float,
  totalAbstainVote: float,
}

let getAnswer = json => {
  exception NoChoice(string)
  let answer = json->GraphQLParser.jsonToStringExn
  switch answer {
  | "Yes" => Vote.Full.Yes
  | "No" => No
  | "NoWithVeto" => NoWithVeto
  | "Abstain" => Abstain
  | _ => raise(NoChoice("There is no choice"))
  }
}

module AllVoteConfig = %graphql(`
    subscription Votes($limit: Int!, $offset: Int!, $proposalID: Int! ) {
      votes(limit: $limit, offset: $offset, where: {proposal_id: {_eq: $proposalID}}, order_by: [{transaction: {block_height: desc}}]) @ppxAs(type: "internal_all_t")  {
        yes @ppxCustom(module:"GraphQLParserModule.IntString")
        no @ppxCustom(module:"GraphQLParserModule.IntString")
        noWithVeto: no_with_veto @ppxCustom(module:"GraphQLParserModule.IntString")
        abstain @ppxCustom(module:"GraphQLParserModule.IntString")
        account @ppxAs(type: "account_t")  {
          address @ppxCustom(module:"GraphQLParserModule.Address")
          validator @ppxAs(type: "validator_t")  {
            moniker
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            identity
          }
        }
        transactionOpt: transaction @ppxAs(type: "transaction_t")  {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          block @ppxAs(type: "block_t")  {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
        }
      }
    }
`)

module YesVoteConfig = %graphql(`
    subscription Votes($limit: Int!, $offset: Int!, $proposalID: Int! ) {
      votes(limit: $limit, offset: $offset, where: {proposal_id: {_eq: $proposalID}, yes: {_gt: "0"}}, order_by: [{transaction: {block_height: desc}}]) @ppxAs(type: "internal_t")  {
        account @ppxAs(type: "account_t")  {
          address @ppxCustom(module:"GraphQLParserModule.Address")
          validator @ppxAs(type: "validator_t")  {
            moniker
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            identity
          }
        }
        transactionOpt: transaction @ppxAs(type: "transaction_t")  {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          block @ppxAs(type: "block_t")  {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
        }
      }
    }
`)

module NoVoteConfig = %graphql(`
    subscription Votes($limit: Int!, $offset: Int!, $proposalID: Int!, ) {
      votes(limit: $limit, offset: $offset, where: {proposal_id: {_eq: $proposalID}, no: {_gt: "0"}}, order_by: [{transaction: {block_height: desc}}]) @ppxAs(type: "internal_t")  {
        account @ppxAs(type: "account_t")  {
          address @ppxCustom(module:"GraphQLParserModule.Address")
          validator @ppxAs(type: "validator_t")  {
            moniker
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            identity
          }
        }
        transactionOpt: transaction @ppxAs(type: "transaction_t")  {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          block @ppxAs(type: "block_t")  {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
        }
      }
    }
`)

module NoWithVetoVoteConfig = %graphql(`
    subscription Votes($limit: Int!, $offset: Int!, $proposalID: Int!, ) {
      votes(limit: $limit, offset: $offset, where: {proposal_id: {_eq: $proposalID}, no_with_veto: {_gt: "0"}}, order_by: [{transaction: {block_height: desc}}]) @ppxAs(type: "internal_t")  {
        account @ppxAs(type: "account_t")  {
          address @ppxCustom(module:"GraphQLParserModule.Address")
          validator @ppxAs(type: "validator_t")  {
            moniker
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            identity
          }
        }
        transactionOpt: transaction @ppxAs(type: "transaction_t")  {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          block @ppxAs(type: "block_t")  {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
        }
      }
    }
`)

module AbstainVoteConfig = %graphql(`
    subscription Votes($limit: Int!, $offset: Int!, $proposalID: Int!, ) {
      votes(limit: $limit, offset: $offset, where: {proposal_id: {_eq: $proposalID}, abstain: {_gt: "0"}}, order_by: [{transaction: {block_height: desc}}]) @ppxAs(type: "internal_t")  {
        account @ppxAs(type: "account_t")  {
          address @ppxCustom(module:"GraphQLParserModule.Address")
          validator @ppxAs(type: "validator_t")  {
            moniker
            operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
            identity
          }
        }
        transactionOpt: transaction @ppxAs(type: "transaction_t")  {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          block @ppxAs(type: "block_t")  {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
        }
      }
    }
`)

module YesVoteCountConfig = %graphql(`
    subscription DepositCount($proposalID: Int!) {
      votes_aggregate(where: {proposal_id: {_eq: $proposalID}, yes: {_gt: "0"}}) {
        aggregate {
          count
        }
      }
    }
`)

module NoVoteCountConfig = %graphql(`
    subscription DepositCount($proposalID: Int!) {
      votes_aggregate(where: {proposal_id: {_eq: $proposalID}, no: {_gt: "0"}}) {
        aggregate {
          count
        }
      }
    }
`)

module NoWithVetoVoteCountConfig = %graphql(`
    subscription DepositCount($proposalID: Int!) {
      votes_aggregate(where: {proposal_id: {_eq: $proposalID}, no_with_veto: {_gt: "0"}}) {
        aggregate {
          count
        }
      }
    }
`)

module AbstainVoteCountConfig = %graphql(`
    subscription DepositCount($proposalID: Int!) {
      votes_aggregate(where: {proposal_id: {_eq: $proposalID}, abstain: {_gt: "0"}}) {
        aggregate {
          count
        }
      }
    }
`)

module ValidatorVoteByProposalIDConfig = %graphql(`
    subscription ValidatorVoteByProposalID($proposalID: Int!) {
      validator_vote_proposals_view(where: {proposal_id: {_eq: $proposalID}}) @ppxAs(type: "internal_vote_t")  {
        yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      }
    }
`)

module DelegatorVoteByProposalIDConfig = %graphql(`
    subscription DelegatorVoteByProposalID($proposalID: Int!) {
      non_validator_vote_proposals_view(where: {proposal_id: {_eq: $proposalID}}) @ppxAs(type: "internal_vote_t")  {
        yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
        abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      }
    }
`)

// module ValidatorVotesConfig = %graphql(`
//     subscription ValidatorVoteByProposalID {
//       validator_vote_proposals_view @ppxAs(type: "internal_vote_t")  {
//         yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//         noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//         noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//         abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//       }
//     }
// `)

// module DelegatorVotesConfig = %graphql(`
//     subscription DelegatorVoteByProposalID {
//       non_validator_vote_proposals_view @ppxAs(type: "internal_vote_t")  {
//         yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//         noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//         noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//         abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatExn")
//       }
//     }
// `)

let count = (proposalID, answer) => {
  switch answer {
  | Vote.Full.Yes =>
    YesVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))

  | No =>
    NoVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))

  | NoWithVeto =>
    NoWithVetoVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))

  | Abstain =>
    AbstainVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))
  | Unknown => Sub.NoData
  }
}

let getListAll = (proposalID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  AllVoteConfig.use({
    proposalID: proposalID->ID.LegacyProposal.toInt,
    limit: pageSize,
    offset,
  })
  ->Sub.fromData
  ->Sub.map(x => x.votes->Belt.Array.map(toExternalAll))
}

let getList = (proposalID, answer, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize

  switch answer {
  | Vote.Full.Yes =>
    YesVoteConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
      limit: pageSize,
      offset,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes->Belt.Array.map(toExternal(Vote.Full.Yes)))

  | No =>
    NoVoteConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
      limit: pageSize,
      offset,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes->Belt.Array.map(toExternal(Vote.Full.No)))

  | NoWithVeto =>
    NoWithVetoVoteConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
      limit: pageSize,
      offset,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes->Belt.Array.map(toExternal(Vote.Full.NoWithVeto)))

  | Abstain =>
    AbstainVoteConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
      limit: pageSize,
      offset,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes->Belt.Array.map(toExternal(Vote.Full.Abstain)))
  | Unknown => Sub.NoData
  }
}

let countAll = proposalID => {
  let yesVoteSub =
    YesVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))

  let noVoteSub =
    NoVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))

  let noWithVetoVoteSub =
    NoWithVetoVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))

  let abstainVoteSub =
    AbstainVoteCountConfig.use({
      proposalID: proposalID->ID.LegacyProposal.toInt,
    })
    ->Sub.fromData
    ->Sub.map(x => x.votes_aggregate.aggregate->Belt.Option.mapWithDefault(0, y => y.count))

  Sub.all4(yesVoteSub, noVoteSub, noWithVetoVoteSub, abstainVoteSub)
}

// TODO: mess a lot with option need to clean
let getVoteStatByProposalID = proposalID => {
  let validatorVotes = ValidatorVoteByProposalIDConfig.use({
    proposalID: proposalID->ID.LegacyProposal.toInt,
  })
  let delegatorVotes = DelegatorVoteByProposalIDConfig.use({
    proposalID: proposalID->ID.LegacyProposal.toInt,
  })

  let val_votes =
    validatorVotes
    ->Sub.fromData
    ->Sub.flatMap(({validator_vote_proposals_view}) => {
      Sub.resolve({
        totalYes: validator_vote_proposals_view->Belt.Array.reduce(0., (acc, {yesVote}) =>
          acc +. yesVote->Belt.Option.getExn
        ),
        totalNo: validator_vote_proposals_view->Belt.Array.reduce(0., (acc, {noVote}) =>
          acc +. noVote->Belt.Option.getExn
        ),
        totalNoWithVetoVote: validator_vote_proposals_view->Belt.Array.reduce(0., (
          acc,
          {noWithVetoVote},
        ) => acc +. noWithVetoVote->Belt.Option.getExn),
        totalAbstainVote: validator_vote_proposals_view->Belt.Array.reduce(0., (
          acc,
          {abstainVote},
        ) => acc +. abstainVote->Belt.Option.getExn),
      })
    })

  let del_votes =
    delegatorVotes
    ->Sub.fromData
    ->Sub.flatMap(({non_validator_vote_proposals_view}) => {
      Sub.resolve({
        totalYes: non_validator_vote_proposals_view->Belt.Array.reduce(0., (acc, {yesVote}) =>
          acc +. yesVote->Belt.Option.getExn
        ),
        totalNo: non_validator_vote_proposals_view->Belt.Array.reduce(0., (acc, {noVote}) =>
          acc +. noVote->Belt.Option.getExn
        ),
        totalNoWithVetoVote: non_validator_vote_proposals_view->Belt.Array.reduce(0., (
          acc,
          {noWithVetoVote},
        ) => acc +. noWithVetoVote->Belt.Option.getExn),
        totalAbstainVote: non_validator_vote_proposals_view->Belt.Array.reduce(0., (
          acc,
          {abstainVote},
        ) => acc +. abstainVote->Belt.Option.getExn),
      })
    })

  let allSub = Sub.all2(val_votes, del_votes)

  allSub->Sub.flatMap(_, ((validatorVoteSub, delegatorVoteSub)) => {
    let totalYesPower = validatorVoteSub.totalYes +. delegatorVoteSub.totalYes
    let totalNoPower = validatorVoteSub.totalNo +. delegatorVoteSub.totalNo
    let totalNoWithVetoPower =
      validatorVoteSub.totalNoWithVetoVote +. delegatorVoteSub.totalNoWithVetoVote
    let totalAbstainPower = validatorVoteSub.totalAbstainVote +. delegatorVoteSub.totalAbstainVote
    let totalPower = totalYesPower +. totalNoPower +. totalNoWithVetoPower +. totalAbstainPower

    Sub.resolve({
      proposalID,
      totalYes: totalYesPower /. 1e6,
      totalYesPercent: totalPower == 0. ? 0. : totalYesPower /. totalPower *. 100.,
      totalNo: totalNoPower /. 1e6,
      totalNoPercent: totalPower == 0. ? 0. : totalNoPower /. totalPower *. 100.,
      totalNoWithVeto: totalNoWithVetoPower /. 1e6,
      totalNoWithVetoPercent: totalPower == 0. ? 0. : totalNoWithVetoPower /. totalPower *. 100.,
      totalAbstain: totalAbstainPower /. 1e6,
      totalAbstainPercent: totalPower == 0. ? 0. : totalAbstainPower /. totalPower *. 100.,
      total: totalPower /. 1e6,
    })
  })
}
