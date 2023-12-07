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
      gridColumnGap(#px(4)),
    ])
}

@react.component
let make = (~title, ~direction, ~toggle, ~value, ~sortedBy, ~justify=Left, ~tooltipItem=?) => {
  let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

  let selected = sortedBy === value

  let color = selected ? theme.neutral_900 : theme.neutral_600

  <div className={Styles.sortableTHead(~justify, ())} onClick={_ => toggle(direction, value)}>
    <Text block=true value=title weight=Text.Semibold color />
    {switch tooltipItem {
    | Some(tooltipMsg) =>
      <CTooltip tooltipPlacementSm=CTooltip.BottomLeft tooltipText=tooltipMsg>
        <Icon name="fal fa-info-circle" size=16 />
      </CTooltip>
    | None => React.null
    }}
    {if !selected {
      <Icon name="fas fa-sort" color />
    } else if direction == Sort.ASC {
      <Icon name="fad fa-sort-down" color />
    } else {
      <Icon name="fad fa-sort-up" color />
    }}
  </div>
}
