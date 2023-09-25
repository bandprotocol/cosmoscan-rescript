module Styles = {
  open CssJs

  let a = (theme: Theme.t) =>
    style(. [
      textDecoration(#none),
      color(theme.neutral_900),
      cursor(#pointer),
      hover([color(theme.primary_600)]),
      selector("> i", [transform(rotate(#deg(-45.))), marginLeft(#px(4))]),
    ])
}

@react.component
let make = (~href, ~className="", ~noNewTab=false, ~children, ~showArrow=false) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  switch href {
  | "" => children
  | _ =>
    <a
      href
      className={Css.merge(list{
        Styles.a(theme),
        CssHelper.flexBox(~direction=#row, ~align=#center, ()),
        className,
      })}
      target={noNewTab ? "_self" : "_blank"}
      rel="noopener">
      {<>
        {children}
        {showArrow ? <Icon name="far fa-arrow-right" color=theme.neutral_600 /> : React.null}
      </>}
    </a>
  }
}
