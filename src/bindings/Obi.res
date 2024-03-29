type field_key_type_t = {
  fieldName: string,
  fieldType: string,
}

type field_key_value_t = {
  fieldName: string,
  fieldValue: string,
}

type data_type_t =
  | Params
  | Result

let dataTypeToString = dataType =>
  switch dataType {
  | Params => "Params"
  | Result => "Result"
  }

let dataTypeToSchemaField = dataType =>
  switch dataType {
  | Params => "input"
  | Result => "output"
  }

let extractFields: (string, string) => option<array<field_key_type_t>> = %raw(`
function(schema, t) {
    try {
        const normalizedSchema = schema.replace(/\s+/g, '')
        const tokens = normalizedSchema.split('/')
        let val
        if (t === 'input') {
            val = tokens[0]
        } else if (t === 'output') {
            val = tokens[1]
        } else {
            return undefined
        }
        let specs = val.slice(1, val.length - 1).split(',')
        return specs.map((spec) => {
            let x = spec.split(':')
            return {fieldName: x[0], fieldType: x[1]}
        })
    } catch {
        return undefined
    }
}
`)

let encode: (string, string, array<field_key_value_t>) => option<JsBuffer.t> = %raw(`
function(schema, t, data) {
  const { Obi } = require('obi.js')

  try {
    const obi = new Obi(schema)

    let payload = {}
    for (let x of data) {
      let value = x.fieldValue
      if (x.fieldValue.startsWith("[") || x.fieldValue.startsWith("{")) {
        value = JSON.parse(x.fieldValue)
      } else if (x.fieldValue.startsWith("0x")) {
        value = Buffer.from(x.fieldValue.slice(2), "hex")
      }
      payload = {...payload, [x.fieldName]: value}
    }

    let buf
    if (t === 'input') {
      buf = obi.encodeInput(payload)
    } else if (t === 'output') {
      buf = obi.encodeOutput(payload)
    } else {
      return undefined
    }

    return Buffer.from(buf)
  } catch(err) {
    console.error("Error encode " + t, err)
    return undefined
  }
}
`)

let decode: (string, string, JsBuffer.t) => option<array<field_key_value_t>> = %raw(`
function(schema, t, data) {
  const { Obi } = require('obi.js')

  function stringify(data) {
    if (Array.isArray(data)) {
      return "[" + [...data].map(stringify).join(",") + "]"
    } else if (typeof(data) === "bigint") {
      return data.toString()
    } else if (Buffer.isBuffer(data)) {
      return "0x" + data.toString('hex')
    } else if (typeof(data) === "object") {
      return "{" + Object.entries(data).map(([k,v]) => JSON.stringify(k)+ ":" + stringify(v)).join(",") + "}"
    } else {
      return JSON.stringify(data)
    }
  }

  try {
    const obi = new Obi(schema)
    let rawResult
    if (t === 'input') {
      rawResult = obi.decodeInput(data)
    } else if (t === 'output') {
      rawResult = obi.decodeOutput(data)
    } else {
      return undefined
    }

    let result = []
    for (let x of Object.entries(rawResult)) {
      let value = stringify(x[1])
      result = [...result, {fieldName: x[0], fieldValue: value}]
    }

    return result
  } catch(err) {
    console.error("Error decode " + t, err)
    return undefined
  }
}
`)

type primitive_t =
  | String
  | U64
  | U32
  | U8

type variable_t =
  | Single(primitive_t)
  | Array(primitive_t)

type field_t = {
  name: string,
  varType: variable_t,
}

let parse = ({fieldName, fieldType}) => {
  let v = {
    switch fieldType {
    | "string" => Some(Single(String))
    | "u64" => Some(Single(U64))
    | "u32" => Some(Single(U32))
    | "u8" => Some(Single(U8))
    | "[string]" => Some(Array(String))
    | "[u64]" => Some(Array(U64))
    | "[u32]" => Some(Array(U32))
    | "[u8]" => Some(Array(U8))
    | _ => None
    }
  }

  v->Belt.Option.map(varType' => {name: fieldName, varType: varType'})
}

let declarePrimitiveSol = primitive =>
  switch primitive {
  | String => "string"
  | U64 => "uint64"
  | U32 => "uint32"
  | U8 => "uint8"
  }

let declareSolidity = ({name, varType}) => {
  let type_ = switch varType {
  | Single(x) => declarePrimitiveSol(x)
  | Array(x) => {
      let declareType = declarePrimitiveSol(x)
      `${declareType}[]`
    }
  }
  `${type_} ${name};`
}

let assignSolidity = ({name, varType}) => {
  let decode = primitive =>
    switch primitive {
    | String => "string(data.decodeBytes());"
    | U64 => "data.decodeU64();"
    | U32 => "data.decodeU32();"
    | U8 => "data.decodeU8();"
    }

  switch varType {
  | Single(x) => {
      let decodeFunction = decode(x)
      `result.${name} = ${decodeFunction}`
    }

  | Array(x) => {
      let type_ = declarePrimitiveSol(x)
      let decodeFunction = decode(x)

      `uint32 length = data.decodeU32();
        ${type_}[] memory ${name} = new ${type_}[](length);
        for (uint256 i = 0; i < length; i++) {
          ${name}[i] = ${decodeFunction}
        }
        result.${name} = ${name}`
    }
  }
}

// TODO: abstract it out
let optionsAll = options =>
  options->Belt.Array.reduce(_, Some([]), (acc, obj) => {
    switch (acc, obj) {
    | (Some(acc'), Some(obj')) => Some(acc'->Js.Array.concat([obj']))
    | (_, _) => None
    }
  })

let generateDecodeLibSolidity = (schema, dataType) => {
  let dataTypeString = dataType->dataTypeToString
  let name = dataType->dataTypeToSchemaField
  let template = (structs, functions) =>
    `library ${dataTypeString}Decoder {
    using Obi for Obi.Data;

    struct ${dataTypeString} {
        ${structs}
    }

    function decode${dataTypeString}(bytes memory _data)
        internal
        pure
        returns (${dataTypeString} memory result)
    {
        Obi.Data memory data = Obi.from(_data);
        ${functions}
    }
}

`

  let fieldPairsOpt = extractFields(schema, name)

  fieldPairsOpt->Belt.Option.flatMap(fieldsPairs => {
    let fieldsOpt = fieldsPairs->Belt.Array.map(parse)->optionsAll
    fieldsOpt->Belt.Option.flatMap(fields => {
      let indent = "\n        "
      Some(
        template(
          fields->Belt.Array.map(declareSolidity)->Js.Array.joinWith(indent, _),
          fields->Belt.Array.map(assignSolidity)->Js.Array.joinWith(indent, _),
        ),
      )
    })
  })
}

let generateDecoderSolidity = schema => {
  let template = `pragma solidity ^0.5.0;

import "./Obi.sol";

`
  let paramsCodeOpt = generateDecodeLibSolidity(schema, Params)
  let resultCodeOpt = generateDecodeLibSolidity(schema, Result)

  paramsCodeOpt->Belt.Option.flatMap(paramsCode => {
    resultCodeOpt->Belt.Option.flatMap(resultCode => Some(template ++ paramsCode ++ resultCode))
  })
}

// TODO: revisit when using this.
let declareGo = ({name, varType}) => {
  let capitalizedName = name->ChangeCase.pascalCase
  let type_ = switch varType {
  | Single(String) => "string"
  | Single(U64) => "uint64"
  | Single(U32) => "uint32"
  | Single(U8) => "uint8"
  | Array(String) => "[]string"
  | Array(U64) => "[]uint64"
  | Array(U32) => "[]uint32"
  | Array(U8) => "[]uint8"
  }
  j`$capitalizedName $type_`
}

let assignGo = ({name, varType}) => {
  switch varType {
  | Single(String) => j`$name, err := decoder.DecodeString()
	if err !== nil {
		return Result{}, err
	}`
  | Single(U64) => j`$name, err := decoder.DecodeU64()
	if err !== nil {
		return Result{}, err
	}`
  | Single(U32) => j`$name, err := decoder.DecodeU32()
	if err !== nil {
		return Result{}, err
	}`
  | Single(U8) => j`$name, err := decoder.DecodeU8()
	if err !== nil {
		return Result{}, err
	}`
  | _ => "// TODO: implement later"
  }
}

let resultGo = ({name}) => {
  let capitalizedName = name->ChangeCase.pascalCase
  j`$capitalizedName: $name`
}

// TODO: Implement input/params decoding
let generateDecoderGo = (packageName, schema, dataType) => {
  switch dataType {
  | Params => Some("Code is not available.")
  | Result =>
    let name = dataType->dataTypeToSchemaField
    let template = (structs, functions, results) =>
      j`package $packageName

import "github.com/bandchain/chain/pkg/obi"

type Result struct {
\t$structs
}

func DecodeResult(data []byte) (Result, error) {
\tdecoder := obi.NewObiDecoder(data)

\t$functions

\tif !decoder.Finished() {
\t\treturn Result{}, errors.New("Obi: bytes left when decode result")
\t}

\treturn Result{
\t\t$results
\t}, nil
}`

    let fieldsPair = extractFields(schema, name)->Belt.Option.getExn
    let fields = fieldsPair->Belt.Array.map(parse)->optionsAll->Belt.Option.getExn
    Some(
      template(
        fields->Belt.Array.map(declareGo)->Js.Array.joinWith("\n\t", _),
        fields->Belt.Array.map(assignGo)->Js.Array.joinWith("\n\t", _),
        fields->Belt.Array.map(resultGo)->Js.Array.joinWith("\n\t\t", _),
      ),
    )
  }
}

let encodeStructGo = ({name, varType}) => {
  switch varType {
  | Single(U8) => j`encoder.EncodeU8(result.$name)`
  | Single(U32) => j`encoder.EncodeU32(result.$name)`
  | Single(U64) => j`encoder.EncodeU64(result.$name)`
  | Single(String) => j`encoder.EncodeString(result.$name)`
  | _ => "//TODO: implement later"
  }
}

let generateEncodeGo = (packageName, schema, name) => {
  let template = (structs, functions) =>
    j`package $packageName

import "github.com/bandchain/chain/pkg/obi"

type Result struct {
\t$structs
}

func(result *Result) EncodeResult() []byte {
\tencoder := obi.NewObiEncoder()

\t$functions

\treturn encoder.GetEncodedData()
}`

  let fieldsPair = extractFields(schema, name)->Belt.Option.getExn
  let fields = fieldsPair->Belt.Array.map(parse)->optionsAll->Belt.Option.getExn
  Some(
    template(
      fields->Belt.Array.map(declareGo)->Js.Array.joinWith("\n\t", _),
      fields->Belt.Array.map(encodeStructGo)->Js.Array.joinWith("\n\t", _),
    ),
  )
}
