module Styles = {
  open CssJs

  let container = style(. [
    selector("a", [wordBreak(#breakAll), textDecoration(#none), transition(~duration=200, "all")]),
    selector("p + p", [marginTop(#em(1.))]),
  ])
}

@react.component
let make = (~value) => {
  // TODO: Add theme context later
  <div className=Styles.container> {value->MarkedJS.marked->MarkedJS.parse} </div>
}
