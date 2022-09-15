type proposal_status_t =
  | Deposit
  | Voting
  | Passed
  | Rejected
  | Failed;

module ProposalStatus = {
  type t = proposal_status_t
  let parse = json => {
    exception NotFound(string);
    let status = json -> Js.Json.decodeString -> Belt.Option.getExn;
    switch (status) {
    | "DepositPeriod" => Deposit
    | "VotingPeriod" => Voting
    | "Passed" => Passed
    | "Rejected" => Rejected
    | "Failed" => Failed
    | _ => raise(NotFound("The proposal status is not existing"))
    };
  };
  //TODO: implement for status
  let serialize = status => "status" -> Js.Json.string
}



type account_t = {address: Address.t};

type deposit_t = {amount: list<Coin.t>};

type internal_t = {
  id: ID.Proposal.t,
  title: string,
  status: proposal_status_t,
  description: string,
  submitTime: MomentRe.Moment.t,
  depositEndTime: MomentRe.Moment.t,
  votingStartTime: MomentRe.Moment.t,
  votingEndTime: MomentRe.Moment.t,
  accountOpt: option<account_t>,
  proposalType: string,
  totalDeposit: list<Coin.t>,
};

type t = {
  id: ID.Proposal.t,
  name: string,
  status: proposal_status_t,
  description: string,
  submitTime: MomentRe.Moment.t,
  depositEndTime: MomentRe.Moment.t,
  votingStartTime: MomentRe.Moment.t,
  votingEndTime: MomentRe.Moment.t,
  proposerAddressOpt: option<Address.t>,
  proposalType: string,
  totalDeposit: list<Coin.t>,
};

let toExternal =
    (
      {
        id,
        title,
        status,
        description,
        submitTime,
        depositEndTime,
        votingStartTime,
        votingEndTime,
        accountOpt,
        proposalType,
        totalDeposit,
      },
    ) => {
  id,
  name: title,
  status,
  description,
  submitTime,
  depositEndTime,
  votingStartTime,
  votingEndTime,
  proposerAddressOpt: accountOpt->Belt.Option.map(({address}) => address),
  proposalType,
  totalDeposit,
};

module SingleConfig = %graphql(`
  subscription Proposal($id: Int!) {
    proposals_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.ProposalID")
      title
      status @ppxCustom(module: "ProposalStatus")
      description
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      depositEndTime: deposit_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingStartTime: voting_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      proposalType: type
      accountOpt: account @ppxAs(type: "account_t") {
          address @ppxCustom(module: "GraphQLParserModule.Address")
      }
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
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      depositEndTime: deposit_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingStartTime: voting_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      proposalType: type
      accountOpt: account @ppxAs(type: "account_t") {
        address @ppxCustom(module: "GraphQLParserModule.Address")
      }
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
  let offset = (page - 1) * pageSize;
  let result = MultiConfig.use({limit: pageSize, offset: offset})

  result
  -> Sub.fromData
  -> Sub.map(internal => internal.proposals->Belt_Array.map(toExternal));
};

let get = id => {
  let result = SingleConfig.use({id: id -> ID.Proposal.toInt})
  
  result -> Sub.fromData
  -> Sub.flatMap(({proposals_by_pk}) => {
    switch proposals_by_pk {
    | Some(data) => Sub.resolve(data -> toExternal)
    | None => Sub.NoData
    }
  })
};

let count = () => {
  let result = ProposalsCountConfig.use()

  result
  -> Sub.fromData
  -> Sub.map(x => x.proposals_aggregate.aggregate |> Belt.Option.getExn |> (y => y.count));
};
