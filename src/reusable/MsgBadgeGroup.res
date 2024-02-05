@react.component
let make = (~messages: list<Msg.result_t>) => {
  let theme = List.nth(messages, 0).decoded->Msg.getBadge
  let length = List.length(messages)

  <div className={CssHelper.flexBox(~direction=#row, ())}>
    <MsgBadge name=theme.name />
    {length > 1
      ? <Text
          value={"+" ++ (length - 1)->Belt.Int.toString} size=Text.Body2 transform=Text.Uppercase
        />
      : React.null}
  </div>
}
