type imported = {
  validators: array<Validator.raw_t>,
  reporters: array<string>,
}

// import from validators.json
@module external importedJSON: imported = "./validators.json"

let validators =
  importedJSON.validators->Belt.Array.mapWithIndex((idx, each) =>
    Validator.toExternal(each, idx + 1)
  )

Belt.Array.forEach(validators, x => Js.log(x.rank))
