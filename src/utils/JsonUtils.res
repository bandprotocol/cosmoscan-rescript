module Decode = {
  include Json.Decode

  let intstr = string->map((. a) => Belt.Int.fromString(a)->Belt.Option.getExn)
  let hashFromHex = string->map((. a) => Hash.fromHex(a))
  let address = string->map((. a) => Address.fromBech32(a))
  let moment = string->map((. a) => a->MomentRe.moment)
  let floatstr = string->map((. a) => a->float_of_string)
  let intWithDefault = v => int->option->map((. a) => a->Belt.Option.getWithDefault(v))
  let bufferWithDefault =
    string->option->map((. a) => a->Belt.Option.getWithDefault(_, "")->JsBuffer.fromBase64)
  let strWithDefault = string->option->map((. a) => a->Belt.Option.getWithDefault(_, ""))
  let bufferFromHex = string->map((. a) => JsBuffer.fromHex(a))
  let bufferFromBase64 = string->map((. a) => JsBuffer.fromBase64(a))

  let rec at = (fields, decoder) => {
    switch fields {
    | list{} => decoder
    | list{x, ...xs} => field(x, at(xs, decoder))
    }
  }

  let mustDecode = (json, decoder) => json->decode(decoder)->Belt.Result.getExn

  type fd_type = {
    required: 'a. (list<string>, t<'a>) => 'a,
    optional: 'a. (list<string>, t<'a>) => option<'a>,
  }

  let buildObject = builder =>
    custom((. json) =>
      builder({
        required: (keys, decode) => mustDecode(json, at(keys, decode)),
        optional: (keys, decoder) =>
          switch json->decode(at(keys, decoder)) {
          | Ok(decoded) => Some(decoded)
          | Error(_) => None
          },
      })
    )

  // function to get data from json (Should not be used)
  let mustGet = (json, key, decode) => {
    json->mustDecode(field(key, decode))
  }

  // function to get data from json (Should not be used)
  let mustAt = (json, keys, decode) => {
    json->mustDecode(at(keys, decode))
  }
}

// Example how to use
type t = {
  a: int,
  b: option<string>,
}

let decode_t = Decode.buildObject(access => {
  a: access.required(list{"a"}, Decode.int),
  b: access.optional(list{"b"}, Decode.string),
})

// Or decode to value on specific field
// let decode_field_a_to_int = Decode.buildObject(access => access.at(list{"a"}, Decode.int))

// How does builderObject work
// type magic_t = {
//   lefthand: int,
//   righthand: int,
// }

// let give_me_magic = builder =>
//   builder({
//     lefthand: 42,
//     righthand: 100,
//   })

// type hello = {
//   a: int,
//   b: int,
// }

// let magicHello = give_me_magic(wizard => {
//   a: wizard.lefthand + 10,
//   b: wizard.righthand * 10,
// })
