type t = Hash(string) // string is hex (without 0x)

let fromHex = hexstr => Hash(hexstr->HexUtils.normalizeHexString)

let fromBase64 = base64str => base64str->JsBuffer.base64ToHex->fromHex

let toBase64 = hash =>
  switch hash {
  | Hash(hexstr) => hexstr->JsBuffer.hexToBase64
  }

let toHex = (~with0x=false, ~upper=false, hash) =>
  switch hash {
  | Hash(hexstr) =>
    let lowercase = (with0x ? "0x" : "") ++ hexstr
    upper ? lowercase->String.uppercase_ascii : lowercase
  }
