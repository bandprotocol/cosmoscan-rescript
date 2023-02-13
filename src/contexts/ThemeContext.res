type t = {
  isDarkMode: bool,
  theme: Theme.t,
}

let keyword = "theme"

let getThemeMode = () => {
  LocalStorage.getItem(keyword)
  ->Belt.Option.flatMap(local => {
    local == "dark" ? Some(Theme.Dark) : Some(Day)
  })
  ->Belt.Option.getWithDefault(Day)
}

let setThemeMode = x =>
  switch x {
  | Theme.Day => LocalStorage.setItem(keyword, "day")
  | Dark => LocalStorage.setItem(keyword, "dark")
  }

type props = {value: (t, unit => unit), children: React.element}
let context = React.createContext(({isDarkMode: false, theme: Theme.get(Day)}, () => ()))

module Provider = {
  @react.component
  let make = (~children) => {
    let (mode, setMode) = React.useState(getThemeMode)
    let theme = React.useMemo1(() => Theme.get(mode), [mode])
    let toggle = () =>
      setMode(prevMode =>
        switch prevMode {
        | Day =>
          setThemeMode(Dark)
          Dark
        | Dark =>
          setThemeMode(Day)
          Day
        }
      )
    let data = {isDarkMode: mode == Dark, theme}
    React.createElement(React.Context.provider(context), {value: (data, toggle), children})
  }
}
