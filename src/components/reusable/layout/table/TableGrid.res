module Styles = {
  open CssJs

  let tableGrid = (~templateColumns, ()) =>
    style(. [
      width(#percent(100.)),
      display(#grid),
      alignItems(#center),
      gridTemplateColumns(templateColumns),
    ])
}

@react.component
let make = (~children, ~templateColumns) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div className={Styles.tableGrid(~templateColumns, ())}> children </div>
}
