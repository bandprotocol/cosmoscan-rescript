let end = (~text, ~limit, ()) => {
  Js.String2.length(text) > limit ? Js.String2.slice(~from=0, ~to_=limit, text) ++ "..." : text
}

let center = (~text, ~limit=6, ()) => {
  let startHash = text->Js.String.slice(~from=0, ~to_=limit)

  let endHash =
    text->Js.String.slice(~from=text->Js.String2.length - limit, ~to_=text->Js.String2.length)

  startHash ++ "..." ++ endHash
}
