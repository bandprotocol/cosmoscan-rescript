type alignment =
  | Start
  | Center
  | End
type column =
  | One
  | Two
  | Three
  | Four
  | Five
  | Six
  | Seven
  | Eight
  | Nine
  | Ten
  | Eleven
  | Twelve
module Styles = {
  open CssJs
  let colGridBase = style(. [
    flexGrow(0.),
    flexShrink(0.),
    flexBasis(#auto),
    padding2(~v=#zero, ~h=#px(12)),
    width(#percent(100.)),
  ])
  let colGrid = x =>
    switch x {
    | One => style(. [maxWidth(#percent(8.333333)), flexBasis(#percent(8.333333))])
    | Two => style(. [maxWidth(#percent(16.666667)), flexBasis(#percent(16.666667))])
    | Three => style(. [maxWidth(#percent(25.)), flexBasis(#percent(25.))])
    | Four => style(. [maxWidth(#percent(33.333333)), flexBasis(#percent(33.333333))])
    | Five => style(. [maxWidth(#percent(41.666667)), flexBasis(#percent(41.666667))])
    | Six => style(. [maxWidth(#percent(50.)), flexBasis(#percent(50.))])
    | Seven => style(. [maxWidth(#percent(58.333333)), flexBasis(#percent(58.333333))])
    | Eight => style(. [maxWidth(#percent(66.666667)), flexBasis(#percent(66.666667))])
    | Nine => style(. [maxWidth(#percent(75.)), flexBasis(#percent(75.))])
    | Ten => style(. [maxWidth(#percent(83.333333)), flexBasis(#percent(83.333333))])
    | Eleven => style(. [maxWidth(#percent(91.666667)), flexBasis(#percent(91.666667))])
    | Twelve => style(. [maxWidth(#percent(100.)), flexBasis(#percent(100.))])
    }
  let colSmGrid = x =>
    switch x {
    | One => style(. [Media.mobile([maxWidth(#percent(8.333333)), flexBasis(#percent(8.333333))])])
    | Two =>
      style(. [Media.mobile([maxWidth(#percent(16.666667)), flexBasis(#percent(16.666667))])])
    | Three => style(. [Media.mobile([maxWidth(#percent(25.)), flexBasis(#percent(25.))])])
    | Four =>
      style(. [Media.mobile([maxWidth(#percent(33.333333)), flexBasis(#percent(33.333333))])])
    | Five =>
      style(. [Media.mobile([maxWidth(#percent(41.666667)), flexBasis(#percent(41.666667))])])
    | Six => style(. [Media.mobile([maxWidth(#percent(50.)), flexBasis(#percent(50.))])])
    | Seven =>
      style(. [Media.mobile([maxWidth(#percent(58.333333)), flexBasis(#percent(58.333333))])])
    | Eight =>
      style(. [Media.mobile([maxWidth(#percent(66.666667)), flexBasis(#percent(66.666667))])])
    | Nine => style(. [Media.mobile([maxWidth(#percent(75.)), flexBasis(#percent(75.))])])
    | Ten =>
      style(. [Media.mobile([maxWidth(#percent(83.333333)), flexBasis(#percent(83.333333))])])
    | Eleven =>
      style(. [Media.mobile([maxWidth(#percent(91.666667)), flexBasis(#percent(91.666667))])])
    | Twelve => style(. [Media.mobile([maxWidth(#percent(100.)), flexBasis(#percent(100.))])])
    }
  let colOffset = x =>
    switch x {
    | One => style(. [marginLeft(#percent(8.333333))])
    | Two => style(. [marginLeft(#percent(16.666667))])
    | Three => style(. [marginLeft(#percent(25.))])
    | Four => style(. [marginLeft(#percent(33.333333))])
    | Five => style(. [marginLeft(#percent(41.666667))])
    | Six => style(. [marginLeft(#percent(50.))])
    | Seven => style(. [marginLeft(#percent(58.333333))])
    | Eight => style(. [marginLeft(#percent(66.666667))])
    | Nine => style(. [marginLeft(#percent(75.))])
    | Ten => style(. [marginLeft(#percent(83.333333))])
    | Eleven => style(. [marginLeft(#percent(91.666667))])
    | Twelve => style(. [])
    }

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
  let ml = (~ml, ~mlSm, ()) =>
    style(. [
      marginLeft(#px(ml)),
      Media.mobile([marginLeft(#px(mlSm->Belt.Option.getWithDefault(ml)))]),
    ])
  let mr = (~mr, ~mrSm, ()) =>
    style(. [
      marginRight(#px(mr)),
      Media.mobile([marginRight(#px(mrSm->Belt.Option.getWithDefault(mr)))]),
    ])
}
@react.component
let make = (
  ~col=Twelve,
  ~colSm=Twelve,
  ~offset=Twelve,
  ~mb=0,
  ~mbSm=?,
  ~mt=0,
  ~mtSm=?,
  ~ml=0,
  ~mlSm=?,
  ~mr=0,
  ~mrSm=?,
  ~style="",
  ~children,
) =>
  <div
    className={CssJs.merge(. [
      Styles.colGridBase,
      Styles.colGrid(col),
      Styles.colOffset(offset),
      Styles.colSmGrid(colSm),
      Styles.mt(~mt, ~mtSm, ()),
      Styles.mb(~mb, ~mbSm, ()),
      Styles.ml(~ml, ~mlSm, ()),
      Styles.mr(~mr, ~mrSm, ()),
      style,
    ])}>
    children
  </div>
