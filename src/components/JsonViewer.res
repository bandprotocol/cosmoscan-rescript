@react.component
let make = (~src) => {
  // TODO: complete it after implementing the ThemeContext
  //   let ({ThemeContext.isDarkMode: isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isDarkMode = false
  let style = {
    "height": "300px",
    "overflow": "auto",
    "padding": "24px",
    "border": isDarkMode ? "0px" : "1px solid #eaeaea",
  }

  <ReactJsonViewer src theme={isDarkMode ? "codeschool" : "bright:inverted"} style />
}
