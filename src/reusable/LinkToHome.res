module Styles = {
  open CssJs

  let link = style(. [cursor(#pointer)])
}

@react.component
let make = (~children) => <Link className=Styles.link route=Route.HomePage> children </Link>
