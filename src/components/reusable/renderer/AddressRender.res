type position =
  | Title
  | Subtitle
  | Text

module Styles = {
  open CssJs

  let container = style(. [display(#flex), cursor(#pointer), overflow(#hidden)])

  let clickable = (isActive, theme: Theme.t) =>
    isActive
      ? style(. [
          pointerEvents(#auto),
          transition(~duration=200, "all"),
          color(theme.primary_600),
          hover([color(theme.primary_800)]),
          active([color(theme.primary_800)]),
        ])
      : style(. [
          pointerEvents(#none),
          color(theme.neutral_600),
          hover([color(theme.neutral_600)]),
          active([color(theme.neutral_600)]),
        ])

  let prefix = style(. [fontWeight(#num(600))])

  let font = x =>
    switch x {
    | Title => style(. [fontSize(#px(18)), lineHeight(#em(1.41)), Media.mobile([fontSize(px(14))])])
    | Subtitle =>
      style(. [fontSize(#px(14)), lineHeight(#em(1.41)), Media.mobile([fontSize(#px(12))])])
    | Text => style(. [fontSize(#px(12)), lineHeight(#em(1.41))])
    }

  let base = style(. [
    overflow(#hidden),
    textOverflow(#ellipsis),
    whiteSpace(#nowrap),
    display(#block),
  ])

  let wordBreak = style(. [
    Media.mobile([textOverflow(#unset), whiteSpace(#unset), wordBreak(#breakAll)]),
  ])

  let copy = style(. [width(#px(15)), marginLeft(#px(10)), cursor(#pointer)])

  let setWidth = x =>
    switch x {
    | Title => style(. [Media.mobile([width(#percent(90.))])])
    | _ => ""
    }
}

@react.component
let make = (
  ~address,
  ~position=Text,
  ~accountType=#account,
  ~copy=false,
  ~clickable=true,
  ~wordBreak=false,
  ~ellipsis=false,
) => {
  let isValidator = accountType == #validator
  let prefix = isValidator ? "bandvaloper" : "band"

  let noPrefixAddress = isValidator
    ? address->Address.toOperatorBech32->Js.String2.sliceToEnd(~from=11)
    : address->Address.toBech32->Js.String2.sliceToEnd(~from=4)

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className={Styles.container}>
    <Link
      className={CssJs.merge(. [
        Styles.container,
        Styles.clickable(clickable, theme),
        Text.Styles.code,
        Styles.setWidth(position),
      ])}
      route={isValidator
        ? Route.ValidatorDetailsPage(address, Route.Reports)
        : Route.AccountIndexPage(address, Route.AccountPortfolio)}>
      <span
        className={CssJs.merge(. [
          Styles.base,
          Styles.font(position),
          wordBreak ? Styles.wordBreak : "",
        ])}>
        <span className=Styles.prefix> {prefix->React.string} </span>
        {(
          ellipsis ? Ellipsis.center(~text=noPrefixAddress, ~limit=8, ()) : noPrefixAddress
        )->React.string}
      </span>
    </Link>
    {copy
      ? <>
          {switch position {
          | Title => <HSpacing size=Spacing.md />
          | _ => <HSpacing size=Spacing.xs />
          }}
          <CopyRender
            width={switch position {
            | Title => 15
            | _ => 12
            }}
            message={isValidator ? address->Address.toOperatorBech32 : address->Address.toBech32}
          />
        </>
      : React.null}
  </div>
}
