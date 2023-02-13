module Styles = {
  open CssJs

  let paperStyle = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.white : theme.white),
      borderRadius(#px(10)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      padding(#px(16)),
      border(#px(1), #solid, isDarkMode ? hex("F3F4F6") : hex("F3F4F6")), // TODO: will change to theme color
      //   border(#px(1), #solid, isDarkMode ? theme.secondaryBg : theme.textSecondary),
      //   padding2(~v=#px(8), ~h=#px(10)),
      //   minWidth(#px(153)),
      //   justifyContent(#spaceBetween),
      //   alignItems(#center),
      //   position(#relative),
      //   cursor(#pointer),
      //   zIndex(5),
      //   Media.mobile([padding2(~v=#px(5), ~h=#px(10))]),
      //   Media.smallMobile([minWidth(#px(90))]),
    ])
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <div className={Styles.paperStyle(theme, isDarkMode)}>
    <Text value={"Hello"} />
  </div>
}
