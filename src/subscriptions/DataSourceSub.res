type block_t = {timestamp: MomentRe.Moment.t}
type transaction_t = {block: block_t}
type request_stat_t = {count: int}
type internal_t = {
  id: ID.DataSource.t,
  owner: Address.t,
  treasury: Address.t,
  name: string,
  description: string,
  executable: JsBuffer.t,
  fee: list<Coin.t>,
  accumulatedRevenue: Coin.t,
  transaction: option<transaction_t>,
  requestStat: option<request_stat_t>,
}

type t = {
  id: ID.DataSource.t,
  owner: Address.t,
  treasury: Address.t,
  name: string,
  description: string,
  executable: JsBuffer.t,
  fee: list<Coin.t>,
  accumulatedRevenue: Coin.t,
  timestamp: MomentRe.Moment.t,
  requestCount: int,
}

let toExternal = ({
  id,
  owner,
  treasury,
  name,
  description,
  executable,
  fee,
  accumulatedRevenue,
  transaction: txOpt,
  requestStat: requestStatOpt,
}) => {
  id,
  owner,
  treasury,
  name,
  description,
  executable,
  fee,
  accumulatedRevenue,
  timestamp: {
    switch txOpt {
    | Some(tx) => tx.block.timestamp
    }
  },
  requestCount: requestStatOpt->Belt.Option.mapWithDefault(0, ({count}) => count),
}

module MultiConfig = %graphql(`
		subscription DataSources($limit: Int!, $offset: Int!, $searchTerm: String!) {
		data_sources(limit: $limit, offset: $offset, where: {name: {_ilike: $searchTerm}}, order_by: [{transaction: {block: {timestamp: desc_nulls_last}}, id: desc}]) @ppxAs(type: "internal_t") {
			id  @ppxCustom(module: "GraphQLParserModule.DataSourceID")
			owner @ppxCustom(module: "GraphQLParserModule.Address")
			treasury @ppxCustom(module: "GraphQLParserModule.Address")
			name
			description
			executable @ppxCustom(module: "GraphQLParserModule.Buffer")
			fee @ppxCustom(module: "GraphQLParserModule.Coins")
			accumulatedRevenue: accumulated_revenue @ppxCustom(module: "GraphQLParserModule.Coin")
			transaction @ppxAs(type: "transaction_t") {
				block @ppxAs(type: "block_t") {
					timestamp @ppxCustom(module: "GraphQLParserModule.Date")
				}
			}
			requestStat: request_stat @ppxAs(type: "request_stat_t") {
				count
			}
		}
	}
`)

module SingleConfig = %graphql(`
		subscription DataSource($id: Int!) {
				data_sources_by_pk(id: $id) @ppxAs(type: "internal_t"){
						id @ppxCustom(module: "GraphQLParserModule.DataSourceID")
						owner @ppxCustom(module: "GraphQLParserModule.Address")
						treasury @ppxCustom(module: "GraphQLParserModule.Address")
						name
						description
						executable @ppxCustom(module: "GraphQLParserModule.Buffer")
						fee @ppxCustom(module: "GraphQLParserModule.Coins")
						accumulatedRevenue: accumulated_revenue @ppxCustom(module: "GraphQLParserModule.Coin")
						transaction @ppxAs(type: "transaction_t")  {
							block @ppxAs(type: "block_t")  {
								timestamp @ppxCustom(module: "GraphQLParserModule.Date")
							}
						}
						requestStat: request_stat @ppxAs(type: "request_stat_t") {
							count
						}
				}
		},
`)

module DataSourcesCountConfig = %graphql(`
		subscription DataSourcesCount($searchTerm: String!) {
				data_sources_aggregate(where: {name: {_ilike: $searchTerm}}){
					aggregate{
							count @ppxCustom(module: "Belt_Option.getExn")
					}
				}
		}
`)

// let get = id => {
//   let (result, _) =
//     ApolloHooks.useSubscription(
//       SingleConfig.definition,
//       ~variables=SingleConfig.makeVariables(~id=id |> ID.DataSource.toInt, ()),
//     );
//   let%Sub x = result;
//   switch (x##data_sources_by_pk) {
//   | Some(data) => Sub.resolve(data |> toExternal)
//   | None => NoData
//   };
// };

// let getList = (~page, ~pageSize, ~searchTerm, ()) => {
//   let offset = (page - 1) * pageSize;
//   let keyword = {j|%$searchTerm%|j};
//   let (result, _) =
//     ApolloHooks.useSubscription(
//       MultiConfig.definition,
//       ~variables=MultiConfig.makeVariables(~limit=pageSize, ~offset, ~searchTerm=keyword, ()),
//     );
//   result |> Sub.map(_, x => x##data_sources->Belt_Array.map(toExternal));
// };

// let count = (~searchTerm, ()) => {
//   let keyword = {j|%$searchTerm%|j};
//   let (result, _) =
//     ApolloHooks.useSubscription(
//       DataSourcesCountConfig.definition,
//       ~variables=DataSourcesCountConfig.makeVariables(~searchTerm=keyword, ()),
//     );
//   result
//   |> Sub.map(_, x => x##data_sources_aggregate##aggregate |> Belt_Option.getExn |> (y => y##count));
// };
