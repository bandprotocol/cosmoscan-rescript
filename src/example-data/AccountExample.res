//  Note.
// the BAND amount string is in uband, you can use Coin.newUBANDFromAmount to convert it to Coin
//

type raw_transactions = {
  id: int,
  txHash: string,
  blockHeight: int,
  success: bool,
  gasFee: string,
  gasLimit: int,
  gasUsed: int,
  sender: string,
  block: Transaction.block_t,
  messages: Js.Json.t,
  memo: string,
  errMsg: option<string>,
}

type imported = {
  address: string,
  operatorAddress: option<string>,
  counterpartyAddress: option<string>,
  balances: string,
  delegated: string,
  reward: string,
  unbonding: string,
  transactions: array<raw_transactions>,
}

// import from account.json
@module external importedJSON: imported = "./account.json"
