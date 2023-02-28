module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module CreateValidator = {
  @react.component
  let make = (~moniker) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <Text value=moniker size=Text.Body2 nowrap=true block=true />
    </div>
}

module EditValidator = {
  @react.component
  let make = (~moniker) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <Text value=moniker size=Text.Body2 nowrap=true block=true />
    </div>
}

module AddReporter = {
  @react.component
  let make = (~reporter) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AddressRender address=reporter />
    </div>
}

module RemoveReporter = {
  @react.component
  let make = (~reporter) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AddressRender address=reporter />
    </div>
}

module SetWithdrawAddress = {
  @react.component
  let make = (~withdrawAddress) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <Text value={j` to `} size=Text.Body2 nowrap=true block=true />
      <AddressRender address=withdrawAddress />
    </div>
}

module Grant = {
  @react.component
  let make = (~reporter) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AddressRender address=reporter />
    </div>
}

module Revoke = {
  @react.component
  let make = (~reporter) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AddressRender address=reporter />
    </div>
}
