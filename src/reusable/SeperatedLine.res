module Styles = {
  open CssJs

  let container = (theme: Theme.t, isDarkMode, mt, mb, mtSm, mbSm, color) =>
    style(. [
      width(#percent(100.)),
      marginTop(#px(mt)),
      marginBottom(#px(mb)),
      height(#px(1)),
      backgroundColor(color->Belt.Option.getWithDefault(theme.neutral_300)),
      Media.mobile([marginTop(#px(mtSm)), marginBottom(#px(mbSm))]),
    ])
}

// TODO: I add mtSm, mbSm propoties to this component. recheck marginTop for every existence of it
@react.component
let make = (~mt=15, ~mb=15, ~mtSm=15, ~mbSm=15, ~style="", ~color=?) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{Styles.container(theme, isDarkMode, mt, mb, mtSm, mbSm, color)})}
  />
}
