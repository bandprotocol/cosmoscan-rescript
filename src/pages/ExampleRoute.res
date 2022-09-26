@react.component
let make = () => {
  let currentRoute = RescriptReactRouter.useUrl()->Route.fromUrl

  <div>
    {switch currentRoute {
    | HomePage => "home"->React.string
    | DataSourcePage => "data source home"->React.string
    | DataSourceDetailsPage(id, _) => `data source index ${id->Belt.Int.toString}`->React.string

    | OracleScriptPage => "oracle script home"->React.string
    | OracleScriptDetailsPage(id, _) => `oracle script index ${id->Belt.Int.toString}`->React.string

    | TxHomePage => "tx home"->React.string
    | _ => "not found"->React.string
    }}
  </div>
}
