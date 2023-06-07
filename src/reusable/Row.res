type direction_t =
  | Stretch
  | Start
  | Center
  | Between
  | End

module Styles = {
  open CssJs

  let justify = x =>
    switch x {
    | Start => style(. [justifyContent(#flexStart)])
    | Center => style(. [justifyContent(#center)])
    | Between => style(. [justifyContent(#spaceBetween)])
    | End => style(. [justifyContent(#flexEnd)])
    | _ => style(. [justifyContent(#flexStart)])
    }

  let alignItems = x =>
    switch x {
    | Stretch => style(. [alignItems(#stretch)])
    | Start => style(. [alignItems(#flexStart)])
    | Center => style(. [alignItems(#center)])
    | End => style(. [alignItems(#flexEnd)])
    | _ => style(. [alignItems(#stretch)])
    }

  let wrap = style(. [flexWrap(#wrap)])

  let minHeight = mh => style(. [minHeight(mh)])
  let rowBase = style(. [display(#flex), margin2(~v=#zero, ~h=#px(-12))])
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
}

@react.component
let make = (
  ~justify=Start,
  ~alignItems=Stretch,
  ~minHeight=#auto,
  ~wrap=true,
  ~style="",
  ~children,
  ~marginBottom=0,
  ~marginBottomSm=?,
  ~marginTop=0,
  ~marginTopSm=?,
) =>
  <div
    className={CssJs.merge(. [
      Styles.rowBase,
      Styles.justify(justify),
      Styles.minHeight(minHeight),
      Styles.alignItems(alignItems),
      Styles.mt(~mt=marginTop, ~mtSm=marginTopSm, ()),
      Styles.mb(~mb=marginBottom, ~mbSm=marginBottomSm, ()),
      wrap ? Styles.wrap : "",
      style,
    ])}>
    children
  </div>
