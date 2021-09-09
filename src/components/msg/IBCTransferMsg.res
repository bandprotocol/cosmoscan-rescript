module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module Transfer = {
  @react.component
  let make = (~toAddress, ~amount, ~denom) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <Text value={amount |> Format.fPretty(~digits=4)} code=true nowrap=true block=true />
      <Text value=denom nowrap=true block=true />
      <Text value=j` to ` nowrap=true block=true />
      <Text value=toAddress nowrap=true block=true code=true />
    </div>
}
