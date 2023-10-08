open CssJs

let flexBox = (
  ~align=#center,
  ~justify=#flexStart,
  ~wrap=#wrap,
  ~direction=#row,
  ~cGap=#zero,
  ~rGap=#zero,
  (),
) =>
  style(. [
    display(#flex),
    alignItems(align),
    justifyContent(justify),
    flexDirection(direction),
    flexWrap(wrap),
    columnGap(cGap),
    rowGap(rGap),
  ])
let flexBoxSm = (
  ~align=#center,
  ~justify=#flexStart,
  ~wrap=#wrap,
  ~direction=#row,
  ~cGap=#zero,
  ~rGap=#zero,
  (),
) =>
  style(. [
    Media.mobile([
      display(#flex),
      alignItems(align),
      justifyContent(justify),
      flexDirection(direction),
      flexWrap(wrap),
      columnGap(cGap),
      rowGap(rGap),
    ]),
  ])

let mobileSpacing = style(. [Media.mobile([paddingBottom(#px(20))])])

let clickable = style(. [cursor(#pointer)])

let container = "container"

let mb = (~size=8, ()) => style(. [marginBottom(#px(size))])
let mbSm = (~size=8, ()) => style(. [Media.mobile([marginBottom(#px(size))])])

let mt = (~size=8, ()) => style(. [marginTop(#px(size))])
let mtSm = (~size=8, ()) => style(. [Media.mobile([marginTop(#px(size))])])

let ml = (~size=8, ()) => style(. [marginLeft(#px(size))])
let mlSm = (~size=8, ()) => style(. [Media.mobile([marginLeft(#px(size))])])

let mr = (~size=8, ()) => style(. [marginRight(#px(size))])
let mrSm = (~size=8, ()) => style(. [Media.mobile([marginRight(#px(size))])])

let px = (~size=0, ()) => style(. [paddingLeft(#px(size)), paddingRight(#px(size))])

let pxSm = (~size=0, ()) =>
  style(. [Media.mobile([paddingLeft(#px(size)), paddingRight(#px(size))])])

// Angle Icon on select input

let selectWrapper = (~size=14, ~pRight=16, ~pRightSm=pRight, ~mW=500, ~fontColor=Theme.black, ()) =>
  style(. [
    position(#relative),
    width(#percent(100.)),
    maxWidth(#px(mW)),
    after([
      contentRule(#text("\f107")),
      fontFamily(#custom("'Font Awesome 5 Pro'")),
      fontSize(#px(size)),
      lineHeight(#px(1)),
      display(#block),
      position(#absolute),
      pointerEvents(#none),
      top(#percent(50.)),
      right(#px(pRight)),
      color(fontColor),
      transform(#translateY(#percent(-50.))),
      Media.mobile([right(#px(pRightSm))]),
    ]),
  ])

// Helper

let overflowHidden = style(. [overflow(#hidden)])

let infoContainer = style(. [
  backgroundColor(Theme.white),
  boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.08)))),
  padding(#px(24)),
  Media.mobile([padding(#px(16))]),
])

let fullWidth = style(. [width(#percent(100.))])
