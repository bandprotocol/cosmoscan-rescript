type wallet_option_t = Leap | Keplr | Cosmostation | Ledger | Mnemonic

let wallet_option_string = (wallet: wallet_option_t) =>
  switch wallet {
  | Leap => "Leap"
  | Keplr => "Keplr"
  | Cosmostation => "Cosmostation"
  | Ledger => "Ledger"
  | Mnemonic => "Mnemonic"
  }

type t =
  | Mnemonic(Mnemonic.t)
  | Ledger(Ledger.t)
  | Leap(LeapWallet.t)
  | Keplr(KeplrWallet.t)
  | Cosmostation(CosmostationWallet.t)

let createFromMnemonic = mnemonic => Mnemonic(Mnemonic.create(mnemonic))

let createFromLedger = (ledgerApp, accountIndex) => {
  Ledger.create(ledgerApp, accountIndex)->Promise.then(ledger => Ledger(ledger)->Promise.resolve)
}

let createFromLeap = async chainId => Leap(await LeapWallet.connect(chainId))
let createFromKeplr = async chainId => Keplr(await KeplrWallet.connect(chainId))
let createFromCosmostation = async chainId => Cosmostation(
  await CosmostationWallet.connect(chainId),
)

let getAddressAndPubKey = x =>
  switch x {
  | Mnemonic(x) => x->Mnemonic.getAddressAndPubKey->Promise.resolve
  | Ledger(x) => x->Ledger.getAddressAndPubKey
  | Leap(x) => x->LeapWallet.getAddressAndPubKey
  | Keplr(x) => x->KeplrWallet.getAddressAndPubKey
  | Cosmostation(x) => x->CosmostationWallet.getAddressAndPubKey
  }

let sign = (msg, x) =>
  switch x {
  | Mnemonic(x) => x->Mnemonic.sign(msg)->Promise.resolve
  | Ledger(x) => x->Ledger.sign(msg)
  | Leap(x) => x->LeapWallet.sign(msg)
  | Keplr(x) => x->KeplrWallet.sign(msg)
  | Cosmostation(x) => x->CosmostationWallet.sign(msg)
  }

let disconnect = x =>
  switch x {
  | Mnemonic(_) => ()
  | Ledger({transport}) => transport->LedgerJS.close
  | Leap(_) => ()
  | Keplr(_) => ()
  | Cosmostation(_) => ()
  }
