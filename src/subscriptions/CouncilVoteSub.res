type account_t = {address: Address.t}

type block_t = {timestamp: MomentRe.Moment.t}

type transaction_t = {
  hash: Hash.t,
  block: block_t,
}

type internal_t = {
  account: account_t,
  option: Vote.YesNo.t,
  transactionOpt: option<transaction_t>,
  voterId: int,
}

type vote_stat_t = {
  yes: int,
  no: int,
}

// type alias for good semantic
type t = {
  account: account_t,
  option: Vote.YesNo.t,
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
      option @ppxCustom(module:"Vote.YesNo.Parser")
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

// calculate yes no vote count
let getVoteCount = (votes, option: Vote.YesNo.t) =>
  votes->Belt.Array.keep(vote => vote.option == option)->Belt.Array.length

let get = councilProposalId => {
  let result = SingleConfig.use({council_proposal_id: councilProposalId->ID.Proposal.toInt})

  result
  ->Sub.fromData
  ->Sub.map(({council_votes}) =>
    switch council_votes->Belt.Array.length > 0 {
    | true => council_votes->Belt.Array.map(toExternal)
    | false => []
    }
  )
}
