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
  | Yes => "Vote"
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
  transaction: transaction_t,
  txId: int,
  voterId: int,
}

module SingleConfig = %graphql(`
  subscription CouncilProposal($council_proposal_id: Int!) {
    council_votes(where: {council_proposal_id: {_eq: $council_proposal_id } }) {
      account @ppxAs(type: "account_t") {
        address @ppxCustom(module:"GraphQLParserModule.Address")
      }
      option @ppxCustom(module:"VoteOption")
      transaction {
        hash @ppxCustom(module: "GraphQLParserModule.Hash")
        block @ppxAs(type: "block_t")  {
          timestamp @ppxCustom(module: "GraphQLParserModule.Date")
        }
      }
      txId: tx_id
      voterId: voter_id
    }
  }
`)

let toExternal = ({account, option, transaction, txId, voterId}) => {
  {
    account,
    option,
    transaction,
    txId,
    voterId,
  }
}

let get = councilProposalId => {
  let result = SingleConfig.use({council_proposal_id: councilProposalId})

  result->Sub.fromData->Sub.map(internal => internal.council_votes)
}
