module Styles = {
  open CssJs

  let errorContainer = (theme: Theme.t) =>
    style(. [
      padding(#px(10)),
      color(theme.failColor),
      backgroundColor(theme.mainBg),
      border(#px(1), #solid, theme.failColor),
      borderRadius(#px(4)),
      marginBottom(#px(24)),
      selector("> i", [marginRight(#px(8))]),
    ])
}

type log_t = {message: string}

type err_t = {log: option<string>}

let decodeLog = json => {
  open JsonUtils.Decode
  {message: json |> field("message", string)}
}

let decode = json => {
  open JsonUtils.Decode
  {log: json |> optional(field("log", string))}
}

let parseErr = msg => {
  let err =
    msg
    |> Json.parse
    |> Belt_Option.flatMap(_, json =>
      json
      |> Js.Json.decodeArray
      |> Belt_Option.flatMap(_, x =>
        x->Belt.Array.get(0)
          |> Belt_Option.flatMap(_, y =>
            (y |> decode).log |> Belt_Option.flatMap(_, logStr => {
              logStr
              |> Json.parse
              |> Belt_Option.flatMap(_, logJson => {
                let log = logJson |> decodeLog
                Some(log.message)
              })
            })
          )
      )
    )
    |> Belt.Option.getWithDefault(_, msg)

  "Error: " ++ err
}

module Full = {
  @react.component
  let make = (~msg) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div
      className={Css.merge(list{
        Styles.errorContainer(theme),
        CssHelper.flexBox(~wrap=#nowrap, ()),
      })}>
      <Icon name="fal fa-exclamation-circle" size=14 color=theme.failColor />
      <Text
        value={msg |> parseErr}
        size=Text.Lg
        spacing=Text.Em(0.02)
        breakAll=true
        color=theme.textPrimary
      />
    </div>
  }
}

module Mini = {
  @react.component
  let make = (~msg) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <Text value={msg |> parseErr} code=true size=Text.Sm breakAll=true color=theme.failColor />
  }
}
