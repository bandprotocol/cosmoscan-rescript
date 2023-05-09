let pythonMatch = str => {
  let reg = %re("/def main\(([^\)]*)\)/ig")
  let args =
    reg
    ->Js.Re.exec_(str)
    ->Belt.Option.mapWithDefault([], Js.Re.captures)
    ->Belt.Array.get(1)
    ->Belt.Option.flatMap(Js.Nullable.toOption)

  args->Belt.Option.map(result =>
    result
    ->Js.String2.split(",")
    ->Belt.Array.map(String.trim)
    ->Belt.Array.keep(s => s->Js.String2.length > 0)
  )
}

let getVariables = str => {
  str
  ->Js.String2.split("\n")
  ->Belt.Array.get(0)
  ->Belt.Option.flatMap(program =>
    switch program {
    | "#!/usr/bin/env python3" => str->pythonMatch
    | _ => None
    }
  )
}

let parseExecutableScript = (buff: JsBuffer.t) => {
  buff->JsBuffer.toUTF8->getVariables
}
