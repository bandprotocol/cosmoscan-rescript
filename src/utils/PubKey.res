type t = PubKey(string) // string is hex (without 0x)

let fromHex = hexstr => PubKey(hexstr->HexUtils.normalizeHexString)

let fromBech32 = bech32str => PubKey(
  bech32str->Bech32.decode->Bech32.wordsGet->Bech32.fromWords->JsBuffer.arrayToHex,
)

let fromBase64 = base64str => base64str->JsBuffer.base64ToHex->fromHex

let toAddress = pubKey =>
  switch pubKey {
  | PubKey(hexstr) =>
    hexstr
    ->JsBuffer.hexToArray
    ->Belt_Array.sliceToEnd(-33)
    ->Sha256.digest
    ->RIPEMD160.hexDigest
    ->Address.fromHex
  }

let toHex = (~with0x=false, pubKey) =>
  switch pubKey {
  | PubKey(hexstr) => (with0x ? "0x" : "") ++ hexstr
  }

let toBase64 = pubKey =>
  switch pubKey {
  | PubKey(hexstr) => hexstr |> JsBuffer.hexToBase64
  }

let toPubKeyHexOnly = (~with0x=false, pubKey) =>
  switch pubKey {
  | PubKey(hexstr) =>
    (with0x ? "0x" : "") ++
    hexstr->JsBuffer.hexToArray->Belt_Array.sliceToEnd(-33)->JsBuffer.arrayToHex
  }

let toBech32 = pubKey =>
  switch pubKey {
  | PubKey(hexstr) =>
    hexstr |> JsBuffer.hexToArray |> Bech32.toWords |> Bech32.encode("bandvalconspub")
  }
