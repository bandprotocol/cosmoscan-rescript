@react.component
let make = (~address, ~hashtag: Route.validator_tab_t) => {
  Js.log2(address, hashtag)
  <Text value="Validator Index" size=Text.Lg />
}
