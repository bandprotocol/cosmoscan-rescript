module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module CreateDataSourceMsg = {
  @react.component
  let make = (~id, ~name) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      {id->Belt.Option.mapWithDefault(React.null, i => {
        <React.Fragment>
          <TypeID.DataSource id=i />
          <Text value=name nowrap=true block=true ellipsis=true />
        </React.Fragment>
      })}
    </div>
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
  @react.component
  let make = (~id, ~name) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <TypeID.OracleScript id />
      <Text value=name nowrap=true block=true ellipsis=true />
    </div>
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
  @react.component
  let make = (~id, ~oracleScriptID, ~oracleScriptName) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~wrap=#nowrap, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      <React.Fragment>
        {id->Belt.Option.mapWithDefault(React.null, i => <TypeID.Request id=i />)}
        <Text value={j` to `} size=Text.Body2 nowrap=true block=true />
        <TypeID.OracleScript id=oracleScriptID />
        {oracleScriptName->Belt.Option.mapWithDefault(React.null, name =>
          <Text value=name nowrap=true block=true ellipsis=true />
        )}
      </React.Fragment>
    </div>
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
