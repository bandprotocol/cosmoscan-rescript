module Styles = {
  open CssJs

  let fontSize = size => style(. [fontSize(#px(size))])
  let fontColor = color_ => style(. [color(color_)])
  let margin = (mr, ml, mt, mb) =>
    style(. [marginRight(#px(mr)), marginLeft(#px(ml)), marginTop(#px(mt)), marginBottom(#px(mb))])
}

@react.component
let make = (~name, ~color=?, ~size=12, ~mr=0, ~ml=0, ~mt=0, ~mb=0) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <i
    className={CssJs.merge(. [
      name,
      Styles.fontColor(color->Belt.Option.getWithDefault(theme.neutral_600)),
      Styles.fontSize(size),
      Styles.margin(mr, ml, mt, mb),
    ])}
  />
}
