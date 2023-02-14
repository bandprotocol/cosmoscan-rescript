open TxSub

module TxCountWithOffsetConfig = %graphql(`
  query TransactionsCount($greater: timestamp) {
    transactions_aggregate(where: {block: {timestamp: {_gt: $greater }}}) {
      aggregate {
        count
      }
    }
  }
`)


let countOffset = (~timestamp) => {
  let result = 
    TxCountWithOffsetConfig.use({
     greater: Some(timestamp -> Js.Json.string)
    })

  result
  -> Query.fromData
  -> Query.map(x => x.transactions_aggregate.aggregate->Belt.Option.mapWithDefault(0, x => x.count))
};
