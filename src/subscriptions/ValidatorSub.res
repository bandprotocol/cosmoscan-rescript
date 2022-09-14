// TODO: Some part implemented
module Mini = {
  type t = {
    consensusAddress: string,
    operatorAddress: Address.t,
    moniker: string,
    identity: string,
  }
}

module TotalBondedAmountConfig = %graphql(`
  subscription TotalBondedAmount{
    validators_aggregate{
      aggregate{
        sum{
          tokens
        }
      }
    }
  }
`)

let getTotalBondedAmount = () => {
  let result = TotalBondedAmountConfig.use()

  result
  -> Sub.fromData
  -> Sub.map(
    x => x.validators_aggregate.aggregate 
    |> Belt_Option.getExn 
    |> (y => y.sum) 
    |> Belt_Option.getExn
    |> (y => y.tokens) 
    |> GraphQLParser.coinWithDefault
  );
};

