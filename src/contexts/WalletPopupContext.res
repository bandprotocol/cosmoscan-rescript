let context = React.createContext(("noShow", _ => ()))

module Provider = {
  @react.component
  let make = (~children) => {
    let (accountBoxState, setAccountBoxState) = React.useState(_ => "noShow")
    React.createElement(
      React.Context.provider(context),
      {value: (accountBoxState, setAccountBoxState), children},
    )
  }
}
