module Styles = {
  open CssJs

  let tableGrid = (~templateColumns, ~cGap, ()) =>
    style(. [
      width(#percent(100.)),
      display(#grid),
      alignItems(#center),
      gridTemplateColumns(templateColumns),
      columnGap(#em(cGap)),
    ])
}

@react.component
let make = (~children, ~templateColumns, ~cGap=1.) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div className={Styles.tableGrid(~templateColumns, ~cGap, ())}> children </div>
}
