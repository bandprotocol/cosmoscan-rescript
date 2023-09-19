// import from validators.json
@module external rawValidators: array<Validator.raw_t> = "./validators.json"

let validators =
  rawValidators->Belt.Array.mapWithIndex((idx, each) => Validator.toExternal(each, idx + 1))

Belt.Array.forEach(validators, x => Js.log(x.rank))
