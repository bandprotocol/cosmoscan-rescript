type chip_variant_t =
  | Success
  | Warning
  | Danger
  | Default

module Styles = {
  open CssJs
  let chipStyles = (~bgColor: chip_variant_t, theme: Theme.t) =>
    style(. [
      backgroundColor({
        switch bgColor {
        | Success => theme.success_600
        | Warning => theme.warning_600
        | Danger => theme.error_600
        | Default => theme.neutral_500
        }
      }),
      borderRadius(#px(50)),
      padding2(~v=#px(2), ~h=#px(8)),
      whiteSpace(#pre),
      display(#inlineFlex),
      selector("> p", [color(bgColor == Warning ? theme.neutral_900 : theme.neutral_000)]),
    ])
}

@react.component
let make = (~value, ~color=Default) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{
      CssHelper.flexBox(~wrap=#nowrap, ~justify=#center, ()),
      Styles.chipStyles(~bgColor=color, theme),
    })}>
    <Text
      value
      size=Caption
      color={theme.neutral_900}
      transform=Text.Uppercase
      align=Text.Center
      weight={Semibold}
    />
  </div>
}
