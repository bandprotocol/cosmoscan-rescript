module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module CreateDataSourceMsg = {
  module Outer = {
    @react.component
    let make = (~msg: Msg.CreateDataSource.t<'a>, ~children) =>
      <div
        className={CssJs.merge(. [
          CssHelper.flexBox(~wrap=#nowrap, ()),
          CssHelper.overflowHidden,
          Styles.msgContainer,
        ])}>
        children
        <Text value={msg.name} nowrap=true block=true ellipsis=true />
      </div>
  }
  module Success = {
    @react.component
    let make = (~msg) =>
      <Outer msg>
        <TypeID.DataSource id=msg.id />
      </Outer>
  }

  module Failure = {
    @react.component
    let make = (~msg) =>
      <Outer msg>
        <div />
      </Outer>
  }
}

module EditDataSourceMsg = {
  @react.component
  let make = (~id, ~name) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <TypeID.DataSource id />
      {name == Config.doNotModify
        ? React.null
        : <Text value=name nowrap=true block=true ellipsis=true />}
    </div>
}

module CreateOracleScriptMsg = {
  module Outer = {
    @react.component
    let make = (~msg: Msg.CreateOracleScript.t<'a>, ~children) =>
      <div
        className={CssJs.merge(. [
          CssHelper.flexBox(~wrap=#nowrap, ()),
          CssHelper.overflowHidden,
          Styles.msgContainer,
        ])}>
        children
        <Text value={msg.name} nowrap=true block=true ellipsis=true />
      </div>
  }
  module Success = {
    @react.component
    let make = (~msg) =>
      <Outer msg>
        <TypeID.OracleScript id=msg.id />
      </Outer>
  }

  module Failure = {
    @react.component
    let make = (~msg) =>
      <Outer msg>
        <div />
      </Outer>
  }
}

module EditOracleScriptMsg = {
  @react.component
  let make = (~id, ~name) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <TypeID.OracleScript id />
      {name == Config.doNotModify
        ? React.null
        : <Text value=name nowrap=true block=true ellipsis=true />}
    </div>
}

module RequestMsg = {
  module Outer = {
    @react.component
    let make = (~msg: Msg.Request.t<'a, 'b, 'c>, ~children) =>
      <div
        className={CssJs.merge(. [
          CssHelper.flexBox(~wrap=#nowrap, ()),
          CssHelper.overflowHidden,
          Styles.msgContainer,
        ])}>
        children
      </div>
  }
  module Success = {
    @react.component
    let make = (~msg) =>
      <Outer msg>
        <TypeID.Request id={msg.id} />
        <Text value={j` to `} size=Text.Body2 nowrap=true block=true />
        <TypeID.OracleScript id=msg.oracleScriptID />
        <Text value={msg.oracleScriptName} nowrap=true block=true ellipsis=true />
      </Outer>
  }

  module Failure = {
    @react.component
    let make = (~msg) =>
      <Outer msg>
        <div />
      </Outer>
  }
}

module ReportMsg = {
  @react.component
  let make = (~requestID) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <TypeID.Request id=requestID />
    </div>
}
