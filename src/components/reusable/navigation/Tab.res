module Styles = {
  open CssJs

  let container = style(. [Media.mobile([margin2(~h=px(-12), ~v=zero)])])
  let header = (theme: Theme.t, isDarkMode) =>
    style(. [
      borderBottom(px(1), solid, isDarkMode ? theme.neutral_300 : theme.neutral_100),
      selector("> * + *", [marginLeft(px(32))]),
      Media.mobile([
        overflow(auto),
        padding2(~v=#px(1), ~h=#px(15)),
        selector("&::-webkit-scrollbar", [display(none)]),
      ]),
    ])

  let buttonContainer = (theme: Theme.t, active) =>
    style(. [
      display(inlineFlex),
      justifyContent(center),
      alignItems(center),
      cursor(pointer),
      padding4(~top=#zero, ~right=#zero, ~bottom=#px(16), ~left=#zero),
      borderBottom(#px(4), solid, active ? theme.primary_600 : transparent),
      Media.mobile([whiteSpace(nowrap), padding2(~v=#px(24), ~h=zero)]),
    ])

  let childrenContainer = style(. [Media.mobile([padding2(~h=px(16), ~v=zero)])])
}

module Route = {
  type t = {
    name: string,
    route: Route.t,
  }

  let button = (~name, ~route, ~active) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <Link key=name isTab=true className={Styles.buttonContainer(theme, active)} route>
      <Text
        value=name
        weight={active ? Text.Semibold : Text.Regular}
        size=Text.Body1
        color={active ? theme.neutral_900 : theme.neutral_600}
      />
    </Link>
  }

  @react.component
  let make = (~tabs: array<t>, ~currentRoute, ~children) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className=Styles.container>
      <div
        className={CssJs.merge(. [
          Styles.header(theme, isDarkMode),
          CssHelper.flexBox(~wrap=#nowrap, ()),
        ])}>
        {tabs
        ->Belt.Array.map(({name, route}) => button(~name, ~route, ~active=route == currentRoute))
        ->React.array}
      </div>
      <div className=Styles.childrenContainer> children </div>
    </div>
  }
}

module State = {
  let button = (~name, ~active, ~setTab) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div key=name className={Styles.buttonContainer(theme, active)} onClick={_ => setTab()}>
      <Text value=name weight={active ? Text.Semibold : Text.Regular} size=Text.Body1 />
    </div>
  }

  @react.component
  let make = (~tabs: array<string>, ~tabIndex, ~setTab, ~children) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className=Styles.container>
      <div
        className={CssJs.merge(. [
          Styles.header(theme, isDarkMode),
          CssHelper.flexBox(~wrap=#nowrap, ()),
        ])}>
        {tabs
        ->Belt.Array.mapWithIndex((index, name) =>
          button(~name, ~active=index == tabIndex, ~setTab=() => setTab(index))
        )
        ->React.array}
      </div>
      <div className=Styles.childrenContainer> children </div>
    </div>
  }
}
