@react.component
let make = () => {
  let currentRoute = RescriptReactRouter.useUrl() |> Route.fromUrl

  <div>
    {switch currentRoute {
    | HomePage => "home" |> React.string
    | DataSourcePage => "data source home" |> React.string
    | DataSourceDetailsPage(dataSourceID, hashtag) => {
        Js.log(hashtag)
        `data source index ${dataSourceID |> string_of_int} ` |> React.string
      }

    | OracleScriptPage => "oracle script home" |> React.string
    | OracleScriptDetailsPage(oracleScriptID, hashtag) => {
        Js.log(hashtag)
        `oracle script index ${oracleScriptID |> string_of_int} ` |> React.string
      }

    | TxHomePage => "tx home" |> React.string
    | _ => "not found" |> React.string
    }}
  </div>
}
