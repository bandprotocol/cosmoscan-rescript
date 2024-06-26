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

type amount = {
  denom: string,
  amount: string,
}

type fee = {
  amount: array<amount>,
  gas: string,
}

type signAminoDoc = {
  chain_id: string,
  sequence: string,
  account_number: string,
  fee: fee,
  memo: string,
  msgs: array<Js.Json.t>,
}

type signAminoResponse = {
  signature: string,
  pub_key: {"type": string, "value": string},
  signed_doc: signAminoDoc,
}

type gasRateType = {
  tiny: string,
  low: string,
  average: string,
}

type edit_mode_t = {fee: bool, memo: bool}

type sign_options_t = {edit_mode: edit_mode_t}

type use_cosmos_method_t = {
  disconnect: unit => unit,
  signAmino: (signAminoDoc, option<sign_options_t>) => Js.Promise.t<signAminoResponse>,
}
type use_cosmos_account_data_t = {account: cosmos_request_account_t, methods: use_cosmos_method_t}

type use_cosmos_account_t = {data: option<use_cosmos_account_data_t>, error: option<string>}

@module("@cosmostation/use-wallets")
external useCosmosWallets: unit => use_cosmos_wallet_t = "useCosmosWallets"

@module("@cosmostation/use-wallets")
external useCosmosAccount: string => use_cosmos_account_t = "useCosmosAccount"

let getAminoSignDocFromTx = (tx: BandChainJS.Transaction.transaction_t) => {
  account_number: tx.accountNum->Belt.Option.getExn->Belt.Int.toString,
  chain_id: tx.chainId->Belt.Option.getExn,
  fee: {
    amount: tx.fee
    ->BandChainJS.Fee.getAmountList
    ->Belt.Array.map(coin => {
      amount: coin->BandChainJS.Coin.getAmount,
      denom: coin->BandChainJS.Coin.getDenom,
    }),
    gas: tx.fee->BandChainJS.Fee.getGasLimit->Belt.Int.toString,
  },
  memo: tx.memo,
  msgs: tx.msgs->Belt.Array.map(msg => msg->BandChainJS.Message.MsgSend.toJSON),
  sequence: tx.sequence->Belt.Option.getExn->Belt.Int.toString,
}
