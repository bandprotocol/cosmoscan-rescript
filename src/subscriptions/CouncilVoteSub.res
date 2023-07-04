type account_t = {address: Address.t}

type transaction_t = {hash: Hash.t}

type internal_t = {
  account: account_t,
  option: string,
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
      option
      transaction {
        hash @ppxCustom(module: "GraphQLParserModule.Hash")
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

  result->Sub.fromData->Sub.map(internal => internal.council_votes->Belt.Array.get(0))
}
