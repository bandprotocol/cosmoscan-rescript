module Styles = {
  open CssJs

  let iconWrapper =  (theme: Theme.t) =>
  style(. [
    backgroundColor(theme.primary_600),
    width(#px(24)),
    height(#px(24)),
    borderRadius(#percent(50.)),
    position(#relative),
    selector(
      "> i",
      [
        position(#absolute),
        left(#percent(50.)),
        top(#percent(50.)),
        transform(translate(#percent(-50.), #percent(-50.))),
      ],
    ),
  ])
}

@react.component
let make = (~category: MsgDecoder.msg_cat_t) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div className=Styles.iconWrapper(theme)>
    {switch category {
    | TokenMsg => <Icon name="far fa-wallet" color=theme.white size=14 />
    | ValidatorMsg => <Icon name="fas fa-user" color=theme.white size=14 />
    | ProposalMsg => <Icon name="fal fa-file" color=theme.white size=14 />
    | DataMsg => <Icon name="fal fa-globe" color=theme.white size=14 />
    | IBCClientMsg
    | IBCConnectionMsg
    | IBCChannelMsg
    | IBCPacketMsg
    | IBCTransferMsg =>
      <img src=Images.ibcIcon alt="IBC Icon" />
    | _ => <Icon name="fal fa-question" color=theme.white size=14 />
    }}
  </div>
}
