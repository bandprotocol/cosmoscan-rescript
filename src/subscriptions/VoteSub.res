type block_t = {timestamp: MomentRe.Moment.t};
type validator_t = {
  moniker: string,
  operatorAddress: Address.t,
  identity: string,
};
type account_t = {
  address: Address.t,
  validator: option<validator_t>,
};
type transaction_t = {
  hash: Hash.t,
  block: block_t,
};

type internal_t = {
  account: account_t,
  transactionOpt: option<transaction_t>,
};

type t = {
  voter: Address.t,
  txHashOpt: option<Hash.t>,
  timestampOpt: option<MomentRe.Moment.t>,
  validator: option<validator_t>,
};

let toExternal = ({account: {address, validator}, transactionOpt}) => {
  voter: address,
  txHashOpt: transactionOpt->Belt.Option.map(({hash}) => hash),
  timestampOpt: transactionOpt->Belt.Option.map(({block}) => block.timestamp),
  validator,
};

type vote_t =
  | Yes
  | No
  | NoWithVeto
  | Abstain;

let toString = (~withSpace=false) => x =>
  switch(x){
    | Yes => "Yes"
    | No => "No"
    | NoWithVeto => withSpace ? "No With Veto" : "NoWithVeto"
    | Abstain => "Abstain";
  }

type answer_vote_t = {
  validatorID: int,
  valPower: float,
  valVote: option<vote_t>,
  delVotes: vote_t => float,
  proposalID: ID.Proposal.t,
};

type internal_vote_t = {
  yesVote: option<float>,
  noVote: option<float>,
  noWithVetoVote: option<float>,
  abstainVote: option<float>,
};

type result_val_t = {
  validatorID: int,
  validatorPower: float,
  validatorAns: option<vote_t>,
  proposalID: ID.Proposal.t,
};

type vote_stat_t = {
  proposalID: ID.Proposal.t,
  totalYes: float,
  totalYesPercent: float,
  totalNo: float,
  totalNoPercent: float,
  totalNoWithVeto: float,
  totalNoWithVetoPercent: float,
  totalAbstain: float,
  totalAbstainPercent: float,
  total: float,
};

let getAnswer = json => {
  exception NoChoice(string);
  let answer = json |> GraphQLParser.jsonToStringExn;
  switch (answer) {
  | "Yes" => Yes
  | "No" => No
  | "NoWithVeto" => NoWithVeto
  | "Abstain" => Abstain
  | _ => raise(NoChoice("There is no choice"))
  };
};

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

let get = proposalID => {
  let result = ValidatorVoteByProposalIDConfig.use({proposalID: proposalID |> ID.Proposal.toInt})
  
  result |> Sub.fromData
  |> Sub.flatMap(_, ({validator_vote_proposals_view}) => {
    validator_vote_proposals_view -> Belt.Array.reduce(0. , (acc, {yesVote}) => acc +. yesVote -> Belt.Option.getExn) -> Sub.resolve
  })
};

// let getList = (proposalID, answer, ~page, ~pageSize, ()) => {
//   let offset = (page - 1) * pageSize;

//   let (result, _) =
//     switch (answer) {
//     | Yes =>
//       ApolloHooks.useSubscription(
//         YesVoteConfig.definition,
//         ~variables=
//           YesVoteConfig.makeVariables(
//             ~proposalID=proposalID |> ID.Proposal.toInt,
//             ~limit=pageSize,
//             ~offset,
//             (),
//           ),
//       )
//     | No =>
//       ApolloHooks.useSubscription(
//         NoVoteConfig.definition,
//         ~variables=
//           NoVoteConfig.makeVariables(
//             ~proposalID=proposalID |> ID.Proposal.toInt,
//             ~limit=pageSize,
//             ~offset,
//             (),
//           ),
//       )
//     | NoWithVeto =>
//       ApolloHooks.useSubscription(
//         NoWithVetoVoteConfig.definition,
//         ~variables=
//           NoWithVetoVoteConfig.makeVariables(
//             ~proposalID=proposalID |> ID.Proposal.toInt,
//             ~limit=pageSize,
//             ~offset,
//             (),
//           ),
//       )
//     | Abstain =>
//       ApolloHooks.useSubscription(
//         AbstainVoteConfig.definition,
//         ~variables=
//           AbstainVoteConfig.makeVariables(
//             ~proposalID=proposalID |> ID.Proposal.toInt,
//             ~limit=pageSize,
//             ~offset,
//             (),
//           ),
//       )
//     };

//   result |> Sub.map(_, x => x##votes->Belt.Array.map(toExternal));
// };

// let count = (proposalID, answer) => {
//   let (result, _) =
//     switch (answer) {
//     | Yes =>
//       ApolloHooks.useSubscription(
//         YesVoteCountConfig.definition,
//         ~variables=
//           YesVoteCountConfig.makeVariables(~proposalID=proposalID |> ID.Proposal.toInt, ()),
//       )
//     | No =>
//       ApolloHooks.useSubscription(
//         NoVoteCountConfig.definition,
//         ~variables=
//           NoVoteCountConfig.makeVariables(~proposalID=proposalID |> ID.Proposal.toInt, ()),
//       )
//     | NoWithVeto =>
//       ApolloHooks.useSubscription(
//         NoWithVetoVoteCountConfig.definition,
//         ~variables=
//           NoWithVetoVoteCountConfig.makeVariables(
//             ~proposalID=proposalID |> ID.Proposal.toInt,
//             (),
//           ),
//       )
//     | Abstain =>
//       ApolloHooks.useSubscription(
//         AbstainVoteCountConfig.definition,
//         ~variables=
//           AbstainVoteCountConfig.makeVariables(~proposalID=proposalID |> ID.Proposal.toInt, ()),
//       )
//     };

//   result
//   |> Sub.map(_, x =>
//        x##votes_aggregate##aggregate |> Belt_Option.getExn |> (y => y##count) |> Belt.Option.getExn
//      );
// };

// TODO: mess a lot with option need to clean
let getVoteStatByProposalID = proposalID => {
  let validatorVotes = ValidatorVoteByProposalIDConfig.use({proposalID: proposalID |> ID.Proposal.toInt})
  let delegatorVotes = DelegatorVoteByProposalIDConfig.use({proposalID: proposalID |> ID.Proposal.toInt})
  
  let val_votes = (validatorVotes.data -> Belt.Option.getExn).validator_vote_proposals_view
  let del_votes = (delegatorVotes.data -> Belt.Option.getExn).non_validator_vote_proposals_view

  let validatorVotePower = {
    yesVote: val_votes -> Belt.Array.reduce(Some(0.) , (acc, {yesVote}) => yesVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn)),
    noVote: val_votes -> Belt.Array.reduce(Some(0.) , (acc, {noVote}) => noVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn)),
    noWithVetoVote: val_votes -> Belt.Array.reduce(Some(0.) , (acc, {noWithVetoVote}) => noWithVetoVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn)),
    abstainVote: val_votes -> Belt.Array.reduce(Some(0.) , (acc, {abstainVote}) => abstainVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn))
  }

  let delegatorVotePower = {
    yesVote: del_votes -> Belt.Array.reduce(Some(0.) , (acc, {yesVote}) => yesVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn)),
    noVote: del_votes -> Belt.Array.reduce(Some(0.) , (acc, {noVote}) => noVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn)),
    noWithVetoVote: del_votes -> Belt.Array.reduce(Some(0.) , (acc, {noWithVetoVote}) => noWithVetoVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn)),
    abstainVote: del_votes -> Belt.Array.reduce(Some(0.) , (acc, {abstainVote}) => abstainVote -> Belt.Option.map(x => x +. acc -> Belt.Option.getExn))
  }


  let totalYesPower = (validatorVotePower.yesVote -> Belt.Option.getExn) +. (delegatorVotePower.yesVote -> Belt.Option.getExn);
  let totalNoPower = (validatorVotePower.noVote -> Belt.Option.getExn) +. (delegatorVotePower.noVote -> Belt.Option.getExn);
  let totalNoWithVetoPower =
      (validatorVotePower.noWithVetoVote -> Belt.Option.getExn) +. (delegatorVotePower.noWithVetoVote -> Belt.Option.getExn);
  let totalAbstainPower = (validatorVotePower.abstainVote -> Belt.Option.getExn) +. (delegatorVotePower.abstainVote -> Belt.Option.getExn);
  let totalPower = totalYesPower +. totalNoPower +. totalNoWithVetoPower +. totalAbstainPower;

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
  });
};
