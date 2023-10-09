type internal_t = {
  id: ID.Group.t,
  admin: Address.t,
  totalWeight: int,
}

let toExternal = ({id, admin, totalWeight}) => {
  id,
  admin,
  totalWeight,
}

module MultiConfig = %graphql(`
  subscription Group($limit: Int!, $offset: Int!)  {
      groups(limit: $limit, offset: $offset) @ppxAs(type: "internal_t"){
          id @ppxCustom(module: "GraphQLParserModule.GroupID")
          admin @ppxCustom(module:"GraphQLParserModule.Address")
          totalWeight: total_weight @ppxCustom(module:"GraphQLParserModule.IntString")
      }
  }
`)

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.groups->Belt.Array.map(toExternal))
}
