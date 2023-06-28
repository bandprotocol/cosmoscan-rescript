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
    margin2(~v=zero, ~h=#px(16)),
    selector("> * + *", [marginLeft(#px(20))]),
  ])

  let inputPage = (theme: Theme.t) =>
    style(. [
      width(#px(80)),
      height(#px(32)),
      padding(#px(5)),
      borderRadius(#px(4)),
      fontSize(#px(14)),
      fontWeight(#light),
      border(#px(1), #solid, theme.neutral_200),
      backgroundColor(theme.neutral_200),
      outlineStyle(#none),
      color(theme.neutral_900),
      fontFamilies([#custom("Montserrat"), #custom("sans-serif")]),
      textAlign(#center),
      marginLeft(#px(16)),
      selector(":focus", [border(#px(1), #solid, theme.primary_600)]),
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
        ? <Icon name="far fa-angle-left" color=theme.neutral_900 size=18 />
        : <Icon name="far fa-angle-right" color=theme.neutral_900 size=18 />}
    </div>
  }
}

@react.component
let make = (
  ~currentPage,
  ~pageCount,
  ~onPageChange: int => unit,
  ~onChangeCurrentPage: int => unit,
) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let (inputPage, setInputPage) = React.useState(_ => "1")

  if pageCount >= 1 {
    <div className=Styles.container>
      <div className=Styles.innerContainer>
        <ClickableSymbol
          isPrevious=true
          active={currentPage != 1}
          onClick={_ => {
            onPageChange(currentPage < 1 ? 1 : currentPage - 1)
            setInputPage(_ => (currentPage - 1)->Format.iPretty)
          }}
        />
        <input
          className={Styles.inputPage(theme)}
          type_="number"
          defaultValue={currentPage->Belt.Int.toString}
          onChange={event => {
            let newVal = ReactEvent.Form.target(event)["value"]
            setInputPage(_ => newVal)
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
      </div>
    </div>
  } else {
    React.null
  }
}
