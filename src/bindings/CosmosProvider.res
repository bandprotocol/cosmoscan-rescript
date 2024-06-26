@react.component @module("@cosmostation/use-wallets")
external make: (~children: React.element) => React.element = "CosmosProvider"

type cosmos_wallet_t = {
  id: string,
  name: string,
  logo: string,
}

type use_cosmos_wallet_t = {cosmosWallets: array<cosmos_wallet_t>, selectWallet: string => unit}
type public_key_t = {
  _type: string,
  value: string,
}
type cosmos_request_account_t = {
  address: string,
  public_key: public_key_t,
  name: string,
  is_ledger: bool,
}

type use_cosmos_method_t = {
  disconnect: unit => unit,
  signAmino: (
    CosmostationClient.Cosmos.signAminoDoc,
    option<CosmostationClient.Cosmos.signOptions>,
  ) => Js.Promise.t<CosmostationClient.Cosmos.signAminoResponse>,
}
type use_cosmos_account_data_t = {account: cosmos_request_account_t, methods: use_cosmos_method_t}

type use_cosmos_account_t = {data: option<use_cosmos_account_data_t>, error: option<string>}

@module("@cosmostation/use-wallets")
external useCosmosWallets: unit => use_cosmos_wallet_t = "useCosmosWallets"

@module("@cosmostation/use-wallets")
external useCosmosAccount: string => use_cosmos_account_t = "useCosmosAccount"
