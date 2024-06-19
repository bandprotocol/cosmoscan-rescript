type t =
  | Mnemonic(Mnemonic.t)
  | Ledger(Ledger.t)
  | Leap(LeapWallet.t)

let createFromMnemonic = mnemonic => Mnemonic(Mnemonic.create(mnemonic))

let createFromLedger = (ledgerApp, accountIndex) => {
  Ledger.create(ledgerApp, accountIndex)->Promise.then(ledger => Ledger(ledger)->Promise.resolve)
}

let createFromLeap = async chainId => Leap(await LeapWallet.connect(chainId))

let getAddressAndPubKey = x =>
  switch x {
  | Mnemonic(x) => x->Mnemonic.getAddressAndPubKey->Promise.resolve
  | Ledger(x) => x->Ledger.getAddressAndPubKey
  | Leap(x) => x->LeapWallet.getAddressAndPubKey
  }

let sign = (msg, x) =>
  switch x {
  | Mnemonic(x) => x->Mnemonic.sign(msg)->Promise.resolve
  | Ledger(x) => x->Ledger.sign(msg)
  | Leap(x) => x->LeapWallet.sign(msg)
  }

let disconnect = x =>
  switch x {
  | Mnemonic(_) => ()
  | Ledger({transport}) => transport->LedgerJS.close
  | Leap(_) => ()
  }
