type account_t = {address: Address.t}
type block_t = {timestamp: MomentRe.Moment.t}

type transaction_t = {
  hash: Hash.t,
  block: block_t,
}

type internal_t = {
  account: account_t,
  amount: list<Coin.t>,
  transactionOpt: option<transaction_t>,
}

type t = {
  depositor: Address.t,
  amount: list<Coin.t>,
  txHashOpt: option<Hash.t>,
  timestampOpt: option<MomentRe.Moment.t>,
}

let toExternal = ({account, amount, transactionOpt}) => {
  depositor: account.address,
  amount,
  txHashOpt: transactionOpt->Belt.Option.map(({hash}) => hash),
  timestampOpt: transactionOpt->Belt.Option.map(({block}) => block.timestamp),
}

module MultiConfig = %graphql(`
    subscription Deposits($limit: Int!, $offset: Int!, $proposal_id: Int!) {
      deposits(limit: $limit, offset: $offset,  where: {proposal_id: {_eq: $proposal_id}}, order_by: [{depositor_id: asc}]) @ppxAs(type: "internal_t") {
        account @ppxAs(type: "account_t") {
          address @ppxCustom(module: "GraphQLParserModule.Address")
        }
        amount @ppxCustom(module: "GraphQLParserModule.Coins")
        transactionOpt: transaction @ppxAs(type: "transaction_t") {
          hash @ppxCustom(module: "GraphQLParserModule.Hash")
          block @ppxAs(type: "block_t")  {
            timestamp @ppxCustom(module: "GraphQLParserModule.Date")
          }
        }
      }
    }
`)

module DepositCountConfig = %graphql(`
    subscription DepositCount($proposal_id: Int!) {
      deposits_aggregate(where: {proposal_id: {_eq: $proposal_id}}) {
        aggregate {
          count
        }
      }
    }
`)

let getList = (proposalID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({
    proposal_id: proposalID->ID.LegacyProposal.toInt,
    limit: pageSize,
    offset,
  })

  result->Sub.fromData->Sub.map(internal => internal.deposits->Belt.Array.map(toExternal))
}

let count = proposalID => {
  let result = DepositCountConfig.use({proposal_id: proposalID->ID.LegacyProposal.toInt})

  result
  ->Sub.fromData
  ->Sub.map(x => x.deposits_aggregate.aggregate->Belt.Option.mapWithDefault(0, a => a.count))
}
