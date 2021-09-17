type t = {
  balance: list<Coin.t>,
  commission: list<Coin.t>,
}

type validator_t = {commission: list<Coin.t>}

type internal_t = {
  balance: list<Coin.t>,
  validator: option<validator_t>,
}

let toExternal = ({balance, validator}) => {
  balance: balance,
  commission: switch validator {
  | Some(validator') => validator'.commission
  | None => list{}
  },
}

module SingleConfig = %graphql(`
  subscription Account($address: String!) {
    accounts_by_pk(address: $address) @ppxAs(type: "internal_t") {
      balance @ppxCustom(module: "GraphQLParserModule.Coins")
      validator @ppxAs(type: "validator_t"){
        commission: accumulated_commission @ppxCustom(module: "GraphQLParserModule.Coins")
      }
    }
  }
  `)

let get = address => {
  let result = SingleConfig.use({address: address |> Address.toBech32})

  result
  |> Sub.fromData
  |> Sub.flatMap(_, ({accounts_by_pk}) => {
    switch accounts_by_pk {
    | Some(data) => Sub.resolve(data |> toExternal)
    | None => Sub.resolve({balance: list{}, commission: list{}})
    }
  })
}
