@obj external makeProps: (~src: Js.Json.t, ~theme: string, ~style: Js.t<'a>, unit) => _ = "";

@module("react-json-view")
external make:
  React.component<{
    .
    "src": Js.Json.t,
    "theme": string,
    "style": Js.t<'a>,
  }> =
  "default"
