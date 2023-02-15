type size =
  | H1
  | H2
  | H3
  | H4
  | H5
  | H6

type weight =
  | Thin
  | Regular
  | Medium
  | Semibold
  | Bold

type align =
  | Center
  | Right
  | Left

module Styles = {
  open CssJs

  let fontSize = x =>
    switch x {
    | H1 => style(. [
      fontSize(#px(40)),
      lineHeight(#px(56)),
      Media.mobile([fontSize(#px(32)), lineHeight(#px(44))])
    ])
    | H2 => style(. [
      fontSize(#px(32)),
      lineHeight(#px(44)),
      Media.mobile([fontSize(#px(28)), lineHeight(#px(40))])
    ])
    | H3 => style(. [
      fontSize(#px(24)),
      lineHeight(#px(40)),
      Media.mobile([fontSize(#px(22)), lineHeight(#px(32))])
    ])
    | H4 => style(. [
      fontSize(#px(20)),
      lineHeight(#px(32)),
      Media.mobile([fontSize(#px(20)), lineHeight(#px(32))])
    ])
    | H5 => style(. [
      fontSize(#px(18)),
      lineHeight(#px(28)),
      Media.mobile([fontSize(#px(18)), lineHeight(#px(28))])
    ])
    | H6 => style(. [
      fontSize(#px(16)),
      lineHeight(#px(26)),
      Media.mobile([fontSize(#px(16)), lineHeight(#px(26))])
    ])
    }

  let fontWeight = x =>
    switch x {
    | Thin => style(. [fontWeight(#num(300))])
    | Regular => style(. [fontWeight(#num(400))])
    | Medium => style(. [fontWeight(#num(500))])
    | Semibold => style(. [fontWeight(#num(600))])
    | Bold => style(. [fontWeight(#num(700))])
    }

  let textAlign = x =>
    switch x {
    | Center => style(. [textAlign(#center)])
    | Right => style(. [textAlign(#right)])
    | Left => style(. [textAlign(#left)])
    }
  let textColor = color_ => style(. [color(color_)])
  let mb = (~mb, ~mbSm, ()) =>
    style(. [marginBottom(#px(mb)), Media.mobile([marginBottom(#px(mbSm))])])
  let mt = (~mt, ~mtSm, ()) => style(. [marginTop(#px(mt)), Media.mobile([marginTop(#px(mtSm))])])
  let mono = style(. [fontFamilies([#custom("Roboto Mono"), #monospace])])
}

@react.component
let make = (
  ~value,
  ~align=Left,
  ~weight=Semibold,
  ~size=H1,
  ~marginTop=0,
  ~marginTopSm=marginTop,
  ~marginBottom=0,
  ~marginBottomSm=marginBottom,
  ~style="",
  ~color=?,
  ~mono=false,
) => {
  let children_ = React.string(value)

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let style_ = size =>
    CssJs.merge(. [
      Styles.fontSize(size),
      Styles.fontWeight(weight),
      Styles.textColor(color->Belt.Option.getWithDefault(theme.neutral_900)),
      Styles.textAlign(align),
      Styles.mb(~mb=marginBottom, ~mbSm=marginBottomSm, ()),
      Styles.mt(~mt=marginTop, ~mtSm=marginTopSm, ()),
      mono ? Styles.mono : "",
      style,
    ])

  switch size {
  | H1 => <h1 className={style_(size)}> children_ </h1>
  | H2 => <h2 className={style_(size)}> children_ </h2>
  | H3 => <h3 className={style_(size)}> children_ </h3>
  | H4 => <h4 className={style_(size)}> children_ </h4>
  | H5 => <h5 className={style_(size)}> children_ </h5>
  | H6 => <h6 className={style_(size)}> children_ </h6>
  }
}
