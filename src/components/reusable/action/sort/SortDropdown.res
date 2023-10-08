module Styles = {
  open CssJs
  let dropdownContainer = style(. [
    position(#relative),
    display(#flex),
    alignItems(#center),
    justifyContent(#center),
    cursor(#pointer),
  ])

  let dropdownSelected = style(. [
    display(#flex),
    alignItems(#center),
    padding2(~v=#px(8), ~h=#zero),
  ])

  let dropdownMenu = (theme: Theme.t, isDarkMode, isShow) =>
    style(. [
      position(#absolute),
      top(#px(40)),
      left(#px(0)),
      width(#px(270)),
      backgroundColor(theme.neutral_000),
      borderRadius(#px(8)),
      padding2(~v=#px(8), ~h=#px(0)),
      zIndex(1),
      boxShadow(
        Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), ~spread=#px(1), rgba(16, 18, 20, #num(0.15))),
      ),
      selector(" > ul + ul", [borderTop(#px(1), #solid, theme.neutral_300)]),
      display(isShow ? #block : #none),
    ])

  let menuItem = (theme: Theme.t, isDarkMode) =>
    style(. [
      position(#relative),
      display(#flex),
      alignItems(#center),
      justifyContent(#flexStart),
      padding4(~top=#px(10), ~right=#px(16), ~bottom=#px(10), ~left=#px(38)),
      cursor(#pointer),
      marginTop(#zero),
      selector("&:hover", [backgroundColor(isDarkMode ? theme.neutral_200 : theme.neutral_100)]),
      selector(
        "i",
        [
          position(#absolute),
          left(#px(18)),
          top(#percent(50.)),
          transform(#translateY(#percent(-50.))),
        ],
      ),
    ])
}

@react.component
let make = (~sortedBy, ~setSortedBy, ~direction, ~setDirection, ~options, ~optionToString) => {
  let (show, setShow) = React.useState(_ => false)
  let ({ThemeContext.theme: theme, isDarkMode}, _) = ThemeContext.use()

  <div className=Styles.dropdownContainer>
    <div
      className={Styles.dropdownSelected}
      onClick={event => {
        setShow(oldVal => !oldVal)
        ReactEvent.Mouse.stopPropagation(event)
      }}>
      <Text
        value={sortedBy->optionToString ++ "( " ++ direction->Sort.toString ++ " )"}
        size={Body1}
        color=theme.neutral_900
        weight={Semibold}
      />
      <HSpacing size=Spacing.sm />
      {show
        ? <Icon name="far fa-angle-up" color={theme.neutral_900} />
        : <Icon name="far fa-angle-down" color={theme.neutral_900} />}
    </div>
    <div className={Styles.dropdownMenu(theme, isDarkMode, show)}>
      <ul>
        {options
        ->Belt.Array.mapWithIndex((i, each) => {
          <li
            key={i->Belt.Int.toString}
            className={Styles.menuItem(theme, isDarkMode)}
            onClick={_ => {
              setSortedBy(_ => each)
              setShow(_ => false)
            }}>
            {sortedBy == each
              ? <Icon name="fal fa-check" size=12 color=theme.neutral_900 />
              : React.null}
            <Text
              value={each->optionToString} size={Body1} weight={Semibold} color={theme.neutral_900}
            />
          </li>
        })
        ->React.array}
      </ul>
      <ul>
        {[Sort.ASC, DESC]
        ->Belt.Array.mapWithIndex((i, each) => {
          <li
            className={Styles.menuItem(theme, isDarkMode)}
            key={i->Belt.Int.toString}
            onClick={_ => {
              setDirection(_ => each)
              setShow(_ => false)
            }}>
            {direction == each
              ? <Icon name="fal fa-check" size=12 color=theme.neutral_900 />
              : React.null}
            <Text
              value={switch each {
              | ASC => "Ascending (smallest value first)"
              | DESC => "Descending (largest value first)"
              }}
              size={Body1}
              weight={Semibold}
              color={theme.neutral_900}
            />
          </li>
        })
        ->React.array}
      </ul>
    </div>
  </div>
}
