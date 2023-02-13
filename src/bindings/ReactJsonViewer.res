@react.component @module("react-json-view")
external make: (~src: Js.Json.t, ~theme: string, ~style: Js.t<'a>) => React.element = "default"
