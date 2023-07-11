module Styles = {
  open CssJs

  let badge = color =>
    style(. [backgroundColor(color), padding2(~v=#px(2), ~h=#px(8)), borderRadius(#px(10))])
}

@react.component
let make = (~value, ~color) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div className={Css.merge(list{Styles.badge(color), CssHelper.flexBox(~justify=#center, ())})}>
    <Text value size=Text.Caption transform=Text.Uppercase weight=Text.Semibold color=theme.white />
  </div>
}
