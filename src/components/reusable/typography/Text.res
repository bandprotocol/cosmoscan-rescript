type size =
  | Xs
  | Caption
  | Body2
  | Body1
  | Xl
  | Xxl
  | Xxxl
  | Xxxxl

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

type spacing =
  | Unset
  | Em(float)

type lineHeight =
  | Px(int)
  | PxFloat(float)

type transform =
  | Uppercase
  | Capitalize
  | Lowercase
  | Normal

type placement =
  | AlignBottomEnd
  | AlignBottomStart
  | AlignBottom
  | AlignLeftEnd
  | AlignLeftStart
  | AlignLeft
  | AlignRightEnd
  | AlignRightStart
  | AlignRight
  | AlignTopEnd
  | AlignTopStart
  | AlignTop

let toPlacementString = x =>
  switch x {
  | AlignBottomEnd => "bottom-end"
  | AlignBottomStart => "bottom-start"
  | AlignBottom => "bottom"
  | AlignLeftEnd => "left-end"
  | AlignLeftStart => "left-start"
  | AlignLeft => "left"
  | AlignRightEnd => "right-end"
  | AlignRightStart => "right-start"
  | AlignRight => "right"
  | AlignTopEnd => "top-end"
  | AlignTopStart => "top-start"
  | AlignTop => "top"
  }

module Styles = {
  open CssJs
  open Belt.Option

  let fontSize = mapWithDefault(
    _,
    style(. [fontSize(#px(12)), lineHeight(#px(16)), Media.mobile([fontSize(#px(10))])]),
    x =>
      switch x {
      | Xs => style(. [fontSize(#px(8)), lineHeight(#em(1.41)), Media.mobile([fontSize(#px(7))])])
      | Caption =>
        style(. [fontSize(#px(10)), lineHeight(#px(16)), Media.mobile([fontSize(#px(8))])])
      | Body2 =>
        style(. [fontSize(#px(12)), lineHeight(#px(20)), Media.mobile([fontSize(#px(10))])])
      | Body1 =>
        style(. [fontSize(#px(14)), lineHeight(#px(22)), Media.mobile([fontSize(#px(12))])])
      | Xl => style(. [fontSize(#px(16)), lineHeight(#em(1.41)), Media.mobile([fontSize(#px(14))])])
      | Xxl => style(. [fontSize(#px(18)), Media.mobile([fontSize(#px(16))])])
      | Xxxl => style(. [fontSize(#px(20)), Media.mobile([fontSize(#px(18))])])
      | Xxxxl => style(. [fontSize(#px(24)), Media.mobile([fontSize(#px(20))])])
      },
  )

  let fontWeight = mapWithDefault(_, style(. []), x =>
    switch x {
    | Thin => style(. [fontWeight(#num(300))])
    | Regular => style(. [fontWeight(#num(400))])
    | Medium => style(. [fontWeight(#num(500))])
    | Semibold => style(. [fontWeight(#num(600))])
    | Bold => style(. [fontWeight(#num(700))])
    }
  )

  let lineHeight = mapWithDefault(_, style(. []), x =>
    switch x {
    | Px(height) => style(. [lineHeight(#px(height))])
    | PxFloat(height) => style(. [lineHeight(#pxFloat(height))])
    }
  )

  let letterSpacing = mapWithDefault(_, style(. [letterSpacing(#unset)]), x =>
    switch x {
    | Unset => style(. [letterSpacing(#unset)])
    | Em(spacing) => style(. [letterSpacing(#em(spacing))])
    }
  )

  let noWrap = style(. [whiteSpace(#nowrap)])
  let block = style(. [display(#block)])
  let ellipsis = style(. [
    overflow(#hidden),
    textOverflow(#ellipsis),
    whiteSpace(#nowrap),
    width(#auto),
  ])
  let underline = style(. [textDecoration(#underline)])
  let textAlign = mapWithDefault(_, style(. [textAlign(#left)]), x =>
    switch x {
    | Center => style(. [textAlign(#center)])
    | Right => style(. [textAlign(#right)])
    | Left => style(. [textAlign(#left)])
    }
  )

  let code = style(. [fontFamilies([#custom("Roboto Mono"), #monospace])])

  let special = style(. [fontFamilies([#custom("Lexend Exa"), #monospace])])

  let textTransform = x =>
    switch x {
    | Uppercase => style(. [textTransform(#uppercase)])
    | Lowercase => style(. [textTransform(#lowercase)])
    | Capitalize => style(. [textTransform(#capitalize)])
    | Normal => style(. [textTransform(#unset)])
    }

  let breakAll = style(. [wordBreak(#breakAll)])

  let textColor = color_ => style(. [color(color_)])
}

@react.component
let make = (
  ~size=?,
  ~weight=?,
  ~align=?,
  ~spacing=?,
  ~height=?,
  ~nowrap=false,
  ~color=?,
  ~block=false,
  ~code=false,
  ~ellipsis=false,
  ~underline=false,
  ~breakAll=false,
  ~transform=Normal,
  ~value,
  ~tooltipItem=React.null,
  ~tooltipPlacement=AlignBottom,
  ~tooltipLeaveDelay=100,
  ~special=false,
) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  tooltipItem == React.null
    ? <p
        className={Css.merge(list{
          Styles.fontSize(size),
          Styles.fontWeight(weight),
          Styles.textAlign(align),
          Styles.letterSpacing(spacing),
          Styles.lineHeight(height),
          Styles.textTransform(transform),
          Styles.textColor(color->Belt.Option.getWithDefault(theme.neutral_600)),
          nowrap ? Styles.noWrap : "",
          block ? Styles.block : "inline-block",
          code ? Styles.code : "",
          special ? Styles.special : "",
          ellipsis ? Styles.ellipsis : "",
          underline ? Styles.underline : "",
          breakAll ? Styles.breakAll : "",
        })}>
        {React.string(value)}
      </p>
    : <Tooltip
        title=tooltipItem
        placement={tooltipPlacement->toPlacementString}
        arrow=true
        leaveDelay=tooltipLeaveDelay
        enterTouchDelay=0
        leaveTouchDelay=3000>
        <span
          className={CssJs.merge(. [
            Styles.fontSize(size),
            Styles.fontWeight(weight),
            Styles.textAlign(align),
            Styles.letterSpacing(spacing),
            Styles.lineHeight(height),
            Styles.textTransform(transform),
            Styles.textColor(color->Belt.Option.getWithDefault(theme.neutral_600)),
            nowrap ? Styles.noWrap : "",
            block ? Styles.block : "inline-block",
            code ? Styles.code : "",
            ellipsis ? Styles.ellipsis : "",
            underline ? Styles.underline : "",
            breakAll ? Styles.breakAll : "",
          ])}>
          {React.string(value)}
        </span>
      </Tooltip>
}
