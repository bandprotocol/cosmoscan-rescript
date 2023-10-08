type align_t =
  | Left
  | Center
  | Right

let toJustifyString = align =>
  switch align {
  | Left => #flexStart
  | Center => #center
  | Right => #flexEnd
  }

module Styles = {
  open CssJs

  let sortableTHead = (~justify, ()) =>
    style(. [
      display(#flex),
      flexDirection(#row),
      alignItems(#center),
      cursor(#pointer),
      justifyContent(justify->toJustifyString),
    ])
}

@react.component
let make = (
  ~title,
  ~direction,
  ~toggle,
  ~value,
  ~sortedBy,
  ~justify=Left,
  ~tooltipItem=?,
  ~tooltipPlacement=Text.AlignBottomStart,
) => {
  let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

  let selected = sortedBy === value

  let color = selected ? theme.neutral_900 : theme.neutral_600

  <div className={Styles.sortableTHead(~justify, ())} onClick={_ => toggle(direction, value)}>
    <Text
      block=true
      value=title
      weight=Text.Semibold
      tooltipItem={tooltipItem->Belt.Option.mapWithDefault(React.null, React.string)}
      tooltipPlacement
      color
    />
    <HSpacing size=Spacing.xs />
    {if !selected {
      <Icon name="fas fa-sort" color />
    } else if direction == Sort.ASC {
      <Icon name="fas fa-caret-down" color />
    } else {
      <Icon name="fas fa-caret-up" color />
    }}
  </div>
}
