@react.component
  let make = (~txHash, ~messages) => {
    let theme = List.nth(messages, 0) -> MsgDecoder.getBadgeTheme;
    let length = List.length(messages);

    <div className={CssHelper.flexBox(~direction=#row, ())}>
      <MsgBadge name=theme.name />
      {
        length > 1 ? <Text 
        value={"+" ++ ((length - 1) -> Belt.Int.toString)}
        size=Text.Body2
        transform=Text.Uppercase /> : React.null
      }
    </div>;
    
  }
