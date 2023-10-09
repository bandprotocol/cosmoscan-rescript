module Styles = {
  open CssJs

  let containerBase = style(. [overflow(#hidden), Media.mobile([padding2(~v=#zero, ~h=#px(15))])])
}

@react.component
let make = (~children) => {
  <div className={Css.merge(list{Styles.containerBase})}> children </div>
}
