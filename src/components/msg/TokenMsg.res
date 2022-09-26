module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module SendMsg = {
  @react.component
  let make = (~toAddress, ~amount) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AmountRender coins=amount />
      <Text value={j` to `} size=Text.Md nowrap=true block=true />
      <AddressRender address=toAddress />
    </div>
}

module ReceiveMsg = {
  @react.component
  let make = (~fromAddress, ~amount) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AmountRender coins=amount />
      <Text value={j` from `} size=Text.Md nowrap=true block=true />
      <AddressRender address=fromAddress />
    </div>
}

module MultisendMsg = {
  @react.component
  let make = (~inputs, ~outputs) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <Text value={inputs->Belt.List.length->Belt.Int.toString} weight=Text.Semibold />
      <Text value="Inputs" />
      <Text value={j` to `} size=Text.Md nowrap=true block=true />
      <Text value={outputs->Belt.List.length->Belt.Int.toString} weight=Text.Semibold />
      <Text value="Outputs" />
    </div>
}

module DelegateMsg = {
  @react.component
  let make = (~amount) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AmountRender coins=list{amount} />
    </div>
}

module UndelegateMsg = {
  @react.component
  let make = (~amount) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AmountRender coins=list{amount} />
    </div>
}

module RedelegateMsg = {
  @react.component
  let make = (~amount) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AmountRender coins=list{amount} />
    </div>
}

module WithdrawRewardMsg = {
  @react.component
  let make = (~amount) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AmountRender coins=amount />
    </div>
}

module WithdrawCommissionMsg = {
  @react.component
  let make = (~amount) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <AmountRender coins=amount />
    </div>
}
