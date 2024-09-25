let context = React.createContext(("noShow", _ => (), "", _ => ()))

module Provider = {
  @react.component
  let make = (~children) => {
    let (accountBoxState, setAccountBoxState) = React.useState(_ => "noShow")
    let (accountError, setAccountError) = React.useState(_ => "")
    React.createElement(
      React.Context.provider(context),
      {value: (accountBoxState, setAccountBoxState, accountError, setAccountError), children},
    )
  }
}
