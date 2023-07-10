type account_t = {address: Address.t}

type block_t = {timestamp: MomentRe.Moment.t}

type transaction_t = {
  hash: Hash.t,
  block: block_t,
}

type vote_t =
  | Yes
  | No
  | Unknown

let getVoteString = vote =>
  switch vote {
  | Yes => "Yes"
  | No => "No"
  | Unknown => "Unknown"
  }

module VoteOption = {
  type t = vote_t

  let parse = json =>
    switch json->Js.Json.decodeString {
    | Some(str) =>
      switch str {
      | "Yes" => Yes
      | "No" => No
      | _ => Unknown
      }
    | None => Unknown
    }

  let serialize = vote => vote->getVoteString->Js.Json.string
}

type internal_t = {
  account: account_t,
  option: VoteOption.t,
  transactionOpt: option<transaction_t>,
  voterId: int,
}

type vote_stat_t = {
  yes: float,
  no: float,
}

// type alias for good semantic
type t = {
  account: account_t,
  option: VoteOption.t,
  transactionOpt: option<transaction_t>,
  voterId: int,
  timestampOpt: option<MomentRe.Moment.t>,
}

module SingleConfig = %graphql(`
  subscription CouncilProposal($council_proposal_id: Int!) {
    council_votes(where: {council_proposal_id: {_eq: $council_proposal_id } }) @ppxAs(type: "internal_t") {
      account @ppxAs(type: "account_t") {
        address @ppxCustom(module:"GraphQLParserModule.Address")
      }
      option @ppxCustom(module:"VoteOption")
      transactionOpt: transaction @ppxAs(type: "transaction_t")  {
        hash @ppxCustom(module: "GraphQLParserModule.Hash")
        block @ppxAs(type: "block_t")  {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      voterId: voter_id
    }
  }
`)

let toExternal = ({account, option, transactionOpt, voterId}: internal_t) => {
  {
    account,
    option,
    transactionOpt,
    voterId,
    timestampOpt: transactionOpt->Belt.Option.map(tx => tx.block.timestamp),
  }
}

// TODO: calculate yes no with weight
let getVoteStat = vote => {
  None
}

let get = councilProposalId => {
  let result = SingleConfig.use({council_proposal_id: councilProposalId})

  result
  ->Sub.fromData
  ->Sub.map(({council_votes}) =>
    switch council_votes->Belt.Array.length > 0 {
    | true => council_votes->Belt.Array.map(toExternal)
    | false => []
    }
  )
}
