module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module BadgeWrapper = {
  @react.component
  let make = (~children) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~align=#center, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      {children}
    </div>
}

module SendMsg = {
  @react.component
  let make = (~toAddress, ~amount) =>
    <BadgeWrapper>
      <AmountRender coins=amount size={Body2} />
      <Text value="to" size=Text.Body2 nowrap=true block=true marginLeft=4 marginRight=4 />
      <AddressRender address=toAddress />
    </BadgeWrapper>
}

module ReceiveMsg = {
  @react.component
  let make = (~fromAddress, ~amount) =>
    <BadgeWrapper>
      <AmountRender coins=amount size={Body2} />
      <Text value={j` from `} size=Text.Body2 nowrap=true block=true />
      <AddressRender address=fromAddress />
    </BadgeWrapper>
}

module MultisendMsg = {
  @react.component
  let make = (~inputs, ~outputs) =>
    <BadgeWrapper>
      <Text value={inputs->Belt.List.length->Belt.Int.toString} weight=Text.Semibold />
      <Text value="Inputs" />
      <Text value={j` to `} size=Text.Body2 nowrap=true block=true />
      <Text value={outputs->Belt.List.length->Belt.Int.toString} weight=Text.Semibold />
      <Text value="Outputs" />
    </BadgeWrapper>
}

module DelegateMsg = {
  @react.component
  let make = (~coin) =>
    <BadgeWrapper>
      <AmountRender coins=list{coin} size={Body2} />
    </BadgeWrapper>
}

module RedelegateMsg = {
  @react.component
  let make = (~amount) =>
    <BadgeWrapper>
      <AmountRender coins=list{amount} size={Body2} />
    </BadgeWrapper>
}

module WithdrawRewardMsg = {
  @react.component
  let make = (~amount) =>
    <BadgeWrapper>
      <AmountRender coins={amount} size={Body2} />
    </BadgeWrapper>
}

module WithdrawCommissionMsg = {
  @react.component
  let make = (~amount) =>
    <BadgeWrapper>
      <AmountRender coins=amount size={Body2} />
    </BadgeWrapper>
}
