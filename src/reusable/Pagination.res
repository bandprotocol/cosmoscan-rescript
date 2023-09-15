module Styles = {
  open CssJs

  let container = style(. [
    display(#flex),
    flexDirection(#row),
    width(#percent(100.)),
    justifyContent(#center),
    minHeight(#px(30)),
    borderRadius(#px(8)),
    padding2(~v=#px(24), ~h=#zero),
    Media.mobile([padding2(~v=#px(12), ~h=#zero)]),
  ])

  let innerContainer = style(. [
    display(#flex),
    alignItems(#center),
    Media.mobile([
      width(#percent(100.)),
      justifyContent(#spaceBetween),
      padding2(~v=#zero, ~h=#px(5)),
    ]),
  ])

  let clickable = (active, theme: Theme.t, isDarkMode) =>
    style(. [
      cursor(#pointer),
      width(#px(32)),
      height(#px(32)),
      borderRadius(#px(8)),
      // border(#px(1), #solid, active ? theme.neutral_900 : theme.neutral_600),
      pointerEvents(active ? #auto : #none),
      opacity(active ? 1. : 0.5),
      hover([
        backgroundColor(theme.clickableHover),
        selector("> i", [color(isDarkMode ? theme.white : theme.black)]),
      ]),
    ])

  let paginationBox = style(. [
    minWidth(#px(80)),
    margin2(~v=zero, ~h=#px(16)),
    selector("> * + *", [marginLeft(#px(20))]),
    fontFamilies([#custom("Roboto Mono"), #monospace]),
  ])

  let inputPage = (theme: Theme.t) =>
    style(. [
      width(#px(80)),
      height(#px(32)),
      padding(#px(5)),
      borderRadius(#px(4)),
      fontSize(#px(14)),
      fontWeight(#light),
      border(#px(1), #solid, theme.neutral_400),
      outlineStyle(#none),
      color(theme.neutral_900),
      fontFamilies([#custom("Roboto Mono"), #monospace]),
      textAlign(#center),
      marginLeft(#px(16)),
      selector(":focus", [border(#px(1), #solid, theme.primary_600)]),
    ])

  let currentPageRange = style(. [
    fontFamilies([#custom("Roboto Mono"), #monospace]),
    marginLeft(#px(40)),
  ])
}
module ClickableSymbol = {
  @react.component
  let make = (~isPrevious, ~active, ~onClick) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div
      className={CssJs.merge(. [
        Styles.clickable(active, theme, isDarkMode),
        CssHelper.flexBox(~justify=#center, ()),
      ])}
      onClick>
      {isPrevious
        ? <Icon
            name="far fa-angle-left" color={active ? theme.neutral_600 : theme.neutral_300} size=18
          />
        : <Icon
            name="far fa-angle-right" color={active ? theme.neutral_600 : theme.neutral_300} size=18
          />}
    </div>
  }
}

@react.component
let make = (
  ~currentPage,
  ~totalElement,
  ~pageSize,
  ~onPageChange: int => unit,
  ~onChangeCurrentPage: int => unit,
) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let (inputPage, setInputPage) = React.useState(_ => "1")
  let pageCount = Page.getPageCount(totalElement, pageSize)
  let currentPageString = Page.getCurrentPageRange(currentPage, pageSize, totalElement)

  if pageCount >= 1 {
    <div className=Styles.container>
      <div className=Styles.innerContainer>
        <ClickableSymbol
          isPrevious=true
          active={currentPage > 1}
          onClick={_ => {
            onPageChange(currentPage < 1 ? 1 : currentPage - 1)
            setInputPage(_ => (currentPage - 1)->Format.iPretty)
          }}
        />
        <input
          className={Styles.inputPage(theme)}
          type_="number"
          value={inputPage}
          min="1"
          max={pageCount->Belt.Int.toString}
          onChange={event => {
            let newVal = ReactEvent.Form.target(event)["value"]
            setInputPage(_ => {
              if newVal->Belt.Int.fromString->Belt.Option.getWithDefault(0) > pageCount {
                pageCount->Belt.Int.toString
              } else if newVal->Belt.Int.fromString->Belt.Option.getWithDefault(0) < 1 {
                "1"
              } else {
                newVal
              }
            })
          }}
          onKeyDown={event => {
            let nextIndexCount = 0
            switch ReactEvent.Keyboard.key(event) {
            | "Enter" => onChangeCurrentPage(inputPage->Belt.Int.fromString->Belt.Option.getExn)
            | _ => ()
            }
          }}
        />
        <div
          className={Css.merge(list{
            CssHelper.flexBox(~justify=#center, ()),
            Styles.paginationBox,
          })}>
          <Text value="of" size=Text.Body1 />
          <Text
            value={pageCount->Format.iPretty}
            weight=Text.Semibold
            size=Text.Body1
            color=theme.neutral_900
          />
        </div>
        <ClickableSymbol
          isPrevious=false
          active={currentPage != pageCount}
          onClick={_ => {
            onPageChange(currentPage > pageCount ? pageCount : currentPage + 1)
            setInputPage(_ => (currentPage + 1)->Format.iPretty)
          }}
        />
        <div className={CssHelper.ml(~size=40, ())}>
          <Text value=currentPageString code=true size=Text.Body1 />
        </div>
      </div>
    </div>
  } else {
    React.null
  }
}
