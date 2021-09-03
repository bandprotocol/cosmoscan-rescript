let pythonMatch = str => {
  let reg = "def main\(\s*([^)]+?)\s*\)" |> Js.Re.fromString
  let rawResult = reg |> Js.Re.exec_(_, str) |> Belt_Option.mapWithDefault(_, [], Js.Re.captures)

  switch rawResult->Belt.Array.get(1) {
  | Some(resultNullable) =>
    switch resultNullable->Js.Nullable.toOption {
    | Some(result) => Some(result |> String.split_on_char(',') |> Belt.List.map(_, String.trim))
    | None => None
    }
  | None => None
  }
}

let getVariables = str => {
  let splitedStr = String.split_on_char('\n', str)
  switch splitedStr->Belt.List.get(0) {
  | Some(program) =>
    switch program {
    | "#!/usr/bin/env python3" => str |> pythonMatch
    | _ => None
    }
  | None => None
  }
}

let parseExecutableScript = (buff: JsBuffer.t) => {
  buff |> JsBuffer.toUTF8 |> getVariables
}
