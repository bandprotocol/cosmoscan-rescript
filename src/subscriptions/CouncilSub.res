type transaction_t = {hash: Hash.t}

type account_t = {address: Address.t}

type aggregate_t = {count: int}

type council_member_aggregate_t = {aggregate: option<aggregate_t>}

type council_member_t = {
  account: account_t,
  weight: int,
  metadata: string,
  since: MomentRe.Moment.t,
}

type internal_t = {
  id: int,
  name: Council.council_name_t,
  account: account_t,
  councilMembers: array<council_member_t>,
  council_members_aggregate: council_member_aggregate_t,
  version: int,
  percentageThreshold: int,
  lastUpdate: MomentRe.Moment.t,
  createdAt: MomentRe.Moment.t,
}

module SingleConfig = %graphql(`
  subscription Councils($id: Int!) {
    councils_by_pk(id: $id) @ppxAs(type: "internal_t") {
      id
      name @ppxCustom(module: "Council.CouncilNameParser")
      account @ppxAs(type: "account_t") {
        address @ppxCustom(module:"GraphQLParserModule.Address")
      }
      councilMembers :council_members @ppxAs(type: "council_member_t") {
        account @ppxAs(type: "account_t") {
          address @ppxCustom(module:"GraphQLParserModule.Address")
        }
        weight @ppxCustom(module:"GraphQLParserModule.IntString")
        metadata
        since @ppxCustom(module: "GraphQLParserModule.Date")
      }
      council_members_aggregate @ppxAs(type: "council_member_aggregate_t"){
        aggregate @ppxAs(type: "aggregate_t"){
          count
        }
      }
      version
      percentageThreshold: percentage_threshold @ppxCustom(module:"GraphQLParserModule.IntString")
      lastUpdate: last_update @ppxCustom(module: "GraphQLParserModule.Date")
      createdAt: created_at @ppxCustom(module: "GraphQLParserModule.Date")
    }
  }
`)

module MultiConfig = %graphql(`
  subscription Councils($limit: Int!, $offset: Int!)  {
    councils(limit: $limit, offset: $offset) @ppxAs(type: "internal_t") {
      id
      name @ppxCustom(module: "Council.CouncilNameParser")
      account @ppxAs(type: "account_t") {
        address @ppxCustom(module:"GraphQLParserModule.Address")
      }
      councilMembers :council_members @ppxAs(type: "council_member_t") {
        account @ppxAs(type: "account_t") {
          address @ppxCustom(module:"GraphQLParserModule.Address")
        }
        weight @ppxCustom(module:"GraphQLParserModule.IntString")
        metadata
        since @ppxCustom(module: "GraphQLParserModule.Date")
      }
      council_members_aggregate @ppxAs(type: "council_member_aggregate_t"){
        aggregate @ppxAs(type: "aggregate_t"){
          count
        }
      }
      
      version
      percentageThreshold: percentage_threshold @ppxCustom(module:"GraphQLParserModule.IntString")
      lastUpdate: last_update @ppxCustom(module: "GraphQLParserModule.Date")
      createdAt: created_at @ppxCustom(module: "GraphQLParserModule.Date")
    }
  }
`)

let toExternal = ({
  id,
  name,
  account,
  councilMembers,
  council_members_aggregate,
  version,
  percentageThreshold,
  lastUpdate,
  createdAt,
}) => {
  id,
  name,
  account,
  councilMembers,
  council_members_aggregate,
  version,
  percentageThreshold,
  lastUpdate,
  createdAt,
}

let get = id => {
  let result = SingleConfig.use({id: id})

  result
  ->Sub.fromData
  ->Sub.flatMap(({councils_by_pk}) => {
    switch councils_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.councils->Belt.Array.map(toExternal))
}
