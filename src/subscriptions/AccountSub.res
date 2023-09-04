type council_t = {name: CouncilSub.council_name_t}

type t = {
  balance: list<Coin.t>,
  commission: list<Coin.t>,
  councilOpt: option<council_t>,
}

type validator_t = {commission: list<Coin.t>}

type internal_t = {
  balance: list<Coin.t>,
  validator: option<validator_t>,
  councilOpt: option<council_t>,
}

let toExternal = ({balance, validator, councilOpt}) => {
  balance,
  commission: switch validator {
  | Some(validator') => validator'.commission
  | None => list{}
  },
  councilOpt,
}

module SingleConfig = %graphql(`
  subscription Account($address: String!) {
    accounts_by_pk(address: $address) @ppxAs(type: "internal_t") {
      balance @ppxCustom(module: "GraphQLParserModule.Coins")
      validator @ppxAs(type: "validator_t"){
        commission: accumulated_commission @ppxCustom(module: "GraphQLParserModule.Coins")
      }
      councilOpt: council @ppxAs(type: "council_t") {
        name @ppxCustom(module: "CouncilSub.CouncilName")
      }
    }
  }
  `)

let get = address => {
  let result = SingleConfig.use({address: address->Address.toBech32})

  result
  ->Sub.fromData
  ->Sub.flatMap(({accounts_by_pk}) => {
    switch accounts_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.resolve({balance: list{}, commission: list{}, councilOpt: None})
    }
  })
}
