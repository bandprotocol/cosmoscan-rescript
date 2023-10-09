type council_t = {name: Council.council_name_t}
type council_member_t = {since: MomentRe.Moment.t}

type t = {
  balance: list<Coin.t>,
  commission: list<Coin.t>,
  councilMembers: array<council_member_t>,
}

type validator_t = {commission: list<Coin.t>}

type internal_t = {
  balance: list<Coin.t>,
  validator: option<validator_t>,
  councilMembers: array<council_member_t>,
}

let toExternal = ({balance, validator, councilMembers}) => {
  balance,
  commission: switch validator {
  | Some(validator') => validator'.commission
  | None => list{}
  },
  councilMembers,
}

module SingleConfig = %graphql(`
  query Account($address: String!) {
    accounts_by_pk(address: $address) @ppxAs(type: "internal_t") {
      balance @ppxCustom(module: "GraphQLParserModule.Coins")
      validator @ppxAs(type: "validator_t"){
        commission: accumulated_commission @ppxCustom(module: "GraphQLParserModule.Coins")
      }
      councilMembers: council_members @ppxAs(type: "council_member_t") {
        since @ppxCustom(module: "GraphQLParserModule.Date")
      }
    }
  }
  `)

let get = address => {
  let result = SingleConfig.use({address: address->Address.toBech32})

  result
  ->Query.fromData
  ->Query.flatMap(({accounts_by_pk}) => {
    switch accounts_by_pk {
    | Some(data) => Query.resolve(data->toExternal)
    | None => Query.resolve({balance: list{}, commission: list{}, councilMembers: []})
    }
  })
}
