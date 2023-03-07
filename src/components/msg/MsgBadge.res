module Styles = {
  open CssJs
  let msgBadge = (theme: Theme.t) =>
    style(. [
      minWidth(#px(80)),
      backgroundColor(theme.neutral_700),
      border(#px(1), #solid, theme.neutral_600),
      borderRadius(#px(50)),
      marginRight(#px(8)),
      padding2(~v=#zero, ~h=#px(12)),
      whiteSpace(#pre),
      display(#inlineFlex),
      Media.mobile([maxWidth(#px(200))]),
    ])
}

@react.component
let make = (~name) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{
      CssHelper.flexBox(~wrap=#nowrap, ~justify=#center, ()),
      Styles.msgBadge(theme),
    })}>
    <Text
      value=name
      size=Text.Body2
      weight=Text.Semibold
      color=theme.neutral_000
      align=Text.Center
      ellipsis=true
    />
  </div>
}
