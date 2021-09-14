module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module Packet = {
  @react.component
  let make = (~packetType) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <Text value=packetType nowrap=true block=true />
    </div>
}
