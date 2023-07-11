type size =
  | H1
  | H2
  | H3
  | H4
  | H5

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
  let lineHeight = style(. [lineHeight(#em(1.41))])
  let fontSize = x =>
    switch x {
    | H1 => style(. [fontSize(#px(24)), Media.mobile([fontSize(#px(20))])])
    | H2 => style(. [fontSize(#px(20)), Media.mobile([fontSize(#px(18))])])
    | H3 => style(. [fontSize(#px(18)), Media.mobile([fontSize(#px(16))])])
    | H4 => style(. [fontSize(#px(14)), Media.mobile([fontSize(#px(12))])])
    | H5 => style(. [fontSize(#px(12)), Media.mobile([fontSize(#px(11))])])
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
    style(. [
      marginBottom(#px(mb)),
      Media.mobile([marginBottom(#px(mbSm->Belt.Option.getWithDefault(mb)))]),
    ])
  let mt = (~mt, ~mtSm, ()) =>
    style(. [
      marginTop(#px(mt)),
      Media.mobile([marginTop(#px(mtSm->Belt.Option.getWithDefault(mt)))]),
    ])
  let mono = style(. [fontFamilies([#custom("Roboto Mono"), #monospace])])
}

@react.component
let make = (
  ~value="",
  ~align=Left,
  ~weight=Semibold,
  ~size=H1,
  ~marginTop=0,
  ~marginTopSm=?,
  ~marginBottom=0,
  ~marginBottomSm=?,
  ~style="",
  ~color=?,
  ~mono=false,
  ~children=?,
) => {
  let children_ = switch children {
  | Some(child) => child
  | None => React.string(value)
  }

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let style_ = size =>
    CssJs.merge(. [
      Styles.fontSize(size),
      Styles.fontWeight(weight),
      Styles.textColor(color->Belt.Option.getWithDefault(theme.neutral_900)),
      Styles.textAlign(align),
      Styles.lineHeight,
      Styles.mt(~mt=marginTop, ~mtSm=marginTopSm, ()),
      Styles.mb(~mb=marginBottom, ~mbSm=marginBottomSm, ()),
      mono ? Styles.mono : "",
      style,
    ])

  switch size {
  | H1 => <h1 className={style_(size)}> children_ </h1>
  | H2 => <h2 className={style_(size)}> children_ </h2>
  | H3 => <h3 className={style_(size)}> children_ </h3>
  | H4 => <h4 className={style_(size)}> children_ </h4>
  | H5 => <h5 className={style_(size)}> children_ </h5>
  }
}
