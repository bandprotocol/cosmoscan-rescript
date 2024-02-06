module Styles = {
  open CssJs

  let emptyContainer = style(. [
    justifyContent(#center),
    alignItems(#center),
    rowGap(#px(8)),
    flexDirection(#column),
    width(#percent(100.)),
    Media.mobile([minHeight(#px(200))]),
  ])

  let height = he => style(. [height(he)])
  let display = dp => style(. [display(dp ? #flex : #none)])
  let backgroundColor = bc => style(. [backgroundColor(bc)])
  let boxShadow = style(. [
    boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.08)))),
  ])
  let borderTop = (theme: Theme.t) => style(. [borderTop(#px(1), #solid, theme.neutral_200)])
}

@react.component
let make = (
  ~height=#px(300),
  ~display=true,
  ~backgroundColor=?,
  ~boxShadow=false,
  ~borderTop=false,
  ~children,
) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <div
    className={CssJs.merge(. [
      Styles.emptyContainer,
      Styles.height(height),
      Styles.display(display),
      Styles.backgroundColor(
        backgroundColor->Belt.Option.getWithDefault(
          isDarkMode ? theme.neutral_100 : theme.neutral_000,
        ),
      ),
      boxShadow ? Styles.boxShadow : "",
      borderTop ? Styles.borderTop(theme) : "",
    ])}>
    children
  </div>
}
