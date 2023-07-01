type transaction_t = {hash: Hash.t}

type internal_t = {
  council_proposal_id: int,
  option: string,
  transaction: transaction_t,
  txId: int,
  voterId: int,
}

module SingleConfig = %graphql(`
  subscription CouncilProposal($council_proposal_id: Int!) {
    council_votes(where: {council_proposal_id: {_eq: $council_proposal_id } }) {
      council_proposal_id
      option
      transaction {
        hash @ppxCustom(module: "GraphQLParserModule.Hash")
      }
      txId: tx_id
      voterId: voter_id
    }
  }
`)

let toExternal = ({council_proposal_id, option, transaction, txId, voterId}) => {
  {
    council_proposal_id,
    option,
    transaction,
    txId,
    voterId,
  }
}

let get = council_proposal_id => {
  let result = SingleConfig.use({council_proposal_id: council_proposal_id})

  result->Sub.fromData->Sub.map(internal => internal.council_votes)
}
