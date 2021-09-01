module Styles = {
  open CssJs

  let avatar = width_ => style(. [width(px(width_)), borderRadius(#percent(50.))])
  let avatarSm = width_ => style(. [Media.mobile([width(px(width_))])])
}

let decodeThem = json =>
  json |> JsonUtils.Decode.at(list{"pictures", "primary", "url"}, JsonUtils.Decode.string)

let decode = json =>
  json |> JsonUtils.Decode.field("them", JsonUtils.Decode.array(decodeThem)) |> Belt.Array.get(_, 0)

module Placeholder = {
  @react.component
  let make = (~moniker, ~width, ~widthSm) =>
    <img
      src={`https://ui-avatars.com/api/?rounded=true&size=128&name=${moniker}&color=230F81&background=C2B6F7`}
      className={CssJs.merge(. [Styles.avatar(width), Styles.avatarSm(widthSm)])}
    />
}

module Keybase = {
  @react.component
  let make = (~identity, ~moniker, ~width, ~widthSm) => {
    let resOpt = AxiosHooks.use(
      `https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=${identity}&fields=pictures`,
    )
    switch resOpt {
    | Some(res) =>
      switch res |> decode {
      | Some(url) =>
        Some(
          <img
            src=url className={CssJs.merge(. [Styles.avatar(width), Styles.avatarSm(widthSm)])}
          />,
        )
      | None =>
        // Log for debug
        Js.Console.log3("none", identity, res)
        Some(<Placeholder moniker width widthSm />)
      | exception err =>
        // Log for debug
        Js.Console.log3(identity, res, err)
        Some(<Placeholder moniker width widthSm />)
      }
    | None => None
    }->Belt.Option.getWithDefault(<LoadingCensorBar width height={width - 4} radius=100 />)
  }
}

@react.component
let make = (~moniker, ~identity, ~width=25, ~widthSm=width) =>
  React.useMemo1(
    () =>
      identity != ""
        ? <Keybase identity moniker width widthSm />
        : <Placeholder moniker width widthSm />,
    [identity],
  )
