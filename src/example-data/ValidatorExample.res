type raw_reports = {
  hash: string,
  timestamp: string,
  request_id: int,
}

type raw_blocks = {
  hash: string,
  height: int,
  timestamp: string,
  txn: int,
}

type raw_delegations = {
  adddress: string,
  shares: string,
}

type imported = {
  validators: array<Validator.raw_t>,
  reporters: array<string>,
  reports: raw_reports,
  blocks: raw_blocks,
}

// import from validators.json
@module external importedJSON: imported = "./validators.json"

// this is Example of used of validators
let validators =
  importedJSON.validators->Belt.Array.mapWithIndex((idx, each) =>
    Validator.toExternal(each, idx + 1)
  )

Js.log(importedJSON)
