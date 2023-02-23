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

// module CreateDataSourceMsg = {
//   // @react.component
//   let factory = (~msg: Msg.CreateDataSource.t<'a>, ~renderID) =>
//     <div
//       className={CssJs.merge(. [
//         CssHelper.flexBox(~wrap=#nowrap, ()),
//         CssHelper.overflowHidden,
//         Styles.msgContainer,
//       ])}>
//       {renderID}
//       <Text value=msg.name nowrap=true block=true ellipsis=true />
//     </div>

//   module ID = {
//     @react.component
//     let make = (~id) => <TypeID.DataSource id />
//   }

//   @react.component
//   let make = (~msg) => factory(~msg, <ID id=msg.id />)
// }

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