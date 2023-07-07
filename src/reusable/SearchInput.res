module Styles = {
  open CssJs

  let searchbarWrapper = (theme: Theme.t) =>
    style(. [width(#percent(100.)), boxSizing(#borderBox), zIndex(1), position(#relative)])

  let searchContainer = (theme: Theme.t) =>
    style(. [
      display(#flex),
      alignItems(#center),
      position(#relative),
      padding(#px(16)),
      border(#px(1), #solid, theme.neutral_300),
      borderRadius(#px(8)),
      boxShadow(
        Shadow.box(
          ~x=#px(0),
          ~y=#px(2),
          ~blur=#px(4),
          ~spread=#px(1),
          ~inset=false,
          rgba(16, 18, 20, #num(0.15)),
        ),
      ),
    ])
  let iconContainer = style(. [
    position(#absolute),
    right(#px(16)),
    top(#percent(50.)),
    transform(#translateY(#percent(-50.))),
  ])

  let searchbarInput = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      height(#px(40)),
      border(#px(1), #solid, theme.neutral_200),
      borderRadius(#px(8)),
      padding2(~v=#px(8), ~h=#px(10)),
      boxSizing(#borderBox),
      fontSize(#px(14)),
      color(theme.neutral_900),
      transition("all", ~duration=200, ~timingFunction=#easeInOut, ~delay=0),
      hover([border(#px(1), #solid, theme.neutral_500)]),
      focus([border(#px(1), #solid, theme.primary_600)]),
      outlineStyle(#none),
      background(theme.neutral_000),
      paddingRight(#px(40)),
      fontWeight(#num(300)),
      boxShadows([Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(16, 18, 20, #num(0.15)))]),
    ])
}

@react.component
let make = (~placeholder, ~onChange, ~debounce=500, ~maxWidth=240) => {
  let (changeValue, setChangeValue) = React.useState(_ => "")
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let (isSearching, setIsSearching) = React.useState(_ => false)
  let clickOutside = ClickOutside.useClickOutside(_ => setIsSearching(_ => false))

  React.useEffect1(() => {
    let timeoutId = Js.Global.setTimeout(() => onChange(_ => changeValue), debounce)
    Some(() => Js.Global.clearTimeout(timeoutId))
  }, [changeValue])

  <div className={Styles.searchbarWrapper(theme)} ref={ReactDOM.Ref.domRef(clickOutside)}>
    <div className=Styles.iconContainer>
      <Icon name="far fa-search" color=theme.neutral_900 size=14 />
    </div>
    <input
      type_="text"
      className={Styles.searchbarInput(theme)}
      placeholder
      onChange={event => {
        let newVal = ReactEvent.Form.target(event)["value"]->String.lowercase_ascii->String.trim
        setChangeValue(_ => newVal)
      }}
    />
  </div>
}
