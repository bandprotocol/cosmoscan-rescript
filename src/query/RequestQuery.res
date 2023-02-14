open RequestSub

module RequestCountWithOffsetConfig = %graphql(`
  query RequestCount($request_time: Int!) {
    requests_aggregate(where: {request_time: {_gte: $request_time}}) {
      aggregate {
        count
      }
    }
  }
`)

let countOffset = (~timestamp) => {
  let result = 
    RequestCountWithOffsetConfig.use({
     request_time: timestamp
    })

  result
  -> Query.fromData
  -> Query.map(x => x.requests_aggregate.aggregate->Belt.Option.mapWithDefault(0, x => x.count))
};
