type t

type transport_t

type addr_pukey_response_t = {
  bech32_address: string,
  return_code: int,
  error_message: string,
  compressed_pk: array<int>,
}

type pubkey_response_t = {
  return_code: int,
  error_message: string,
  compressed_pk: PubKey.t,
}

type version_t = {
  return_code: int,
  error_message: string,
  test_mode: bool,
  major: int,
  minor: int,
  patch: int,
  device_locked: bool,
}

type app_info_t = {
  return_code: int,
  error_message: string,
  appName: string,
  appVersion: string,
}

type sign_response_t = {
  return_code: string,
  error_message: string,
  signature: array<int>,
}

@module("@ledgerhq/hw-transport-webhid") @scope("default") @val
external createTransportWebHID: int => promise<transport_t> = "create"

@module("@ledgerhq/hw-transport-webusb") @scope("default") @val
external createTransportWebUSB: int => promise<transport_t> = "create"

@module("ledger-cosmos-js") @new external createApp: transport_t => t = "default"
@send
external getAddressAndPubKey: (t, array<int>, string) => promise<addr_pukey_response_t> =
  "getAddressAndPubKey"
@send external publicKey: (t, array<int>) => promise<pubkey_response_t> = "publicKey"
@send external sign: (t, array<int>, string) => promise<sign_response_t> = "sign"
@send external getVersion: t => promise<version_t> = "getVersion"
@send external appInfo: t => promise<app_info_t> = "appInfo"
// TODO: It should return promise
@send external close: transport_t => unit = "close"
