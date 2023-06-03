module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module BadgeWrapper = {
  @react.component
  let make = (~children) =>
    <div
      className={CssJs.merge(. [CssHelper.flexBox(~align=#center, ()), CssHelper.overflowHidden])}>
      {children}
    </div>
}

module Validator = {
  @react.component
  let make = (~moniker) =>
    <BadgeWrapper>
      <Text value=moniker size=Text.Body2 nowrap=true block=true />
    </BadgeWrapper>
}

module AddReporter = {
  @react.component
  let make = (~reporter) =>
    <BadgeWrapper>
      <AddressRender address=reporter />
    </BadgeWrapper>
}

module RemoveReporter = {
  @react.component
  let make = (~reporter) =>
    <BadgeWrapper>
      <AddressRender address=reporter />
    </BadgeWrapper>
}
module Grant = {
  @react.component
  let make = (~reporter) =>
    <BadgeWrapper>
      <AddressRender address=reporter />
    </BadgeWrapper>
}

module Revoke = {
  @react.component
  let make = (~reporter) =>
    <BadgeWrapper>
      <AddressRender address=reporter />
    </BadgeWrapper>
}

module RevokeAllowance = {
  @react.component
  let make = (~granter) =>
    <BadgeWrapper>
      <AddressRender address=granter />
    </BadgeWrapper>
}

module SetWithdrawAddress = {
  @react.component
  let make = (~withdrawAddress) => {
    <BadgeWrapper>
      <Text value={j` to `} size=Text.Body1 nowrap=true block=true />
      <AddressRender address=withdrawAddress />
    </BadgeWrapper>
  }
}

module Exec = {
  @react.component
  let make = (~messages) => {
    <BadgeWrapper>
      {messages
      ->Belt.List.mapWithIndex((index, msg) => {
        <Text key={index->Belt.Int.toString} value={Msg.getBadge(msg).name} />
      })
      ->Belt.List.toArray
      ->React.array}
    </BadgeWrapper>
  }
}
