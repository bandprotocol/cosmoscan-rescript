module Styles = {
  open CssJs
  let addressWrapper = style(. [width(#px(120)), Media.smallMobile([width(#px(80))])])
}

@react.component
let make = (~name, ~fromAddress) =>
  <div className={Css.merge(list{CssHelper.flexBox(~wrap=#nowrap, ())})}>
    <div className=Styles.addressWrapper>
      <AddressRender address=fromAddress />
    </div>
    <MsgBadge name />
  </div>
