type t = Hash(string) // string is hex (without 0x)

let fromHex = hexStr => Hash(hexStr->HexUtils.normalizeHexString)

let fromBase64 = base64str => base64str->JsBuffer.base64ToHex->fromHex

let toBase64 = hash =>
  switch hash {
  | Hash(hexStr) => hexStr->JsBuffer.hexToBase64
  }

let toHex = (~with0x=false, ~upper=false, hash) =>
  switch hash {
  | Hash(hexStr) =>
    let lowercase = (with0x ? "0x" : "") ++ hexStr
    upper ? lowercase->String.uppercase_ascii : lowercase
  }
