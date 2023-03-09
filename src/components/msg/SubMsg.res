module Styles = {
  open CssJs
  let rowWithWidth = (w: int) =>
    style(. [
      width(#px(w)),
      display(#flex),
      flexDirection(#row),
      alignItems(#center),
      Media.mobile([
        width(#auto),
        flexWrap(#wrap),
        selector("> div:nth-child(1)", [width(#px(90)), marginBottom(#px(10))]),
        selector(
          "> .labelContainer",
          [display(#flex), flexBasis(#calc(#sub, #percent(100.), #px(100))), marginBottom(#px(10))],
        ),
      ]),
      Media.smallMobile([selector("> div:nth-child(1)", [width(#px(68)), marginBottom(#px(10))])]),
    ])
  let withWidth = (w: int) => style(. [width(#px(w))])
  let withBg = (color: Types.Color.t, mw: int) =>
    style(. [
      minWidth(#px(mw)),
      height(#px(16)),
      backgroundColor(color),
      borderRadius(#px(100)),
      margin2(~v=#zero, ~h=#px(5)),
      display(#flex),
      justifyContent(#center),
      alignItems(#center),
    ])

  let addressWrapper = style(. [width(#px(120))])

  let msgContainer = style(. [
    Media.mobile([
      selector("> div", [width(#percent(100.))]),
      selector("> div + div", [marginTop(#px(8))]),
    ]),
  ])
}

let makeBadge = (name, length, color1, color2) =>
  <div className="labelContainer">
    <div className={Styles.withBg(color1, length)}>
      <Text value=name size=Text.Xs spacing=Text.Em(0.07) weight=Text.Medium color=color2 />
    </div>
  </div>

@react.component
let make = (~msg: Msg.t) => {
  let badge = msg.decoded->Msg.getBadge
  <div
    className={CssJs.merge(. [
      CssHelper.flexBox(~wrap=#nowrap, ()),
      CssHelper.flexBoxSm(~wrap=#wrap, ()),
      CssHelper.overflowHidden,
      Styles.msgContainer,
    ])}>
    <MsgFront name=badge.name fromAddress={msg.sender} />
    {switch msg.decoded {
    | SendMsg({toAddress, amount}) => <TokenMsg.SendMsg toAddress amount />
    | CreateDataSourceMsg(msg) =>
      switch msg {
      | Msg.Oracle.CreateDataSource.Success(m) => <OracleMsg.CreateDataSourceMsg.Success msg=m />
      | Msg.Oracle.CreateDataSource.Failure(f) => <OracleMsg.CreateDataSourceMsg.Failure msg=f />
      }
    | EditDataSourceMsg(msg) => <OracleMsg.EditDataSourceMsg id=msg.id name=msg.name />
    | CreateOracleScriptMsg(msg) =>
      switch msg {
      | Msg.Oracle.CreateOracleScript.Success(m) =>
        <OracleMsg.CreateOracleScriptMsg.Success msg=m />
      | Msg.Oracle.CreateOracleScript.Failure(f) =>
        <OracleMsg.CreateOracleScriptMsg.Failure msg=f />
      }
    | EditOracleScriptMsg(msg) => <OracleMsg.EditOracleScriptMsg id=msg.id name=msg.name />

    | RequestMsg(msg) =>
      switch msg {
      | Msg.Oracle.Request.Success(m) => <OracleMsg.RequestMsg.Success msg=m />
      | Msg.Oracle.Request.Failure(f) => <OracleMsg.RequestMsg.Failure msg=f />
      }
    | ReportMsg(msg) => <OracleMsg.ReportMsg requestID=msg.requestID />
    | GrantMsg(msg) => <ValidatorMsg.Grant reporter=msg.granter />
    | RevokeMsg(msg) => <ValidatorMsg.Revoke reporter=msg.validator />
    | RevokeAllowanceMsg(msg) => <ValidatorMsg.Grant reporter=msg.granter />
    | GrantAllowanceMsg(msg) => <ValidatorMsg.Grant reporter=msg.granter />
    | CreateValidatorMsg({moniker})
    | EditValidatorMsg({moniker}) =>
      <ValidatorMsg.Validator moniker />
    | DelegateMsg(msg) =>
      switch msg {
      | Msg.Staking.Delegate.Success(m) => <TokenMsg.DelegateMsg coin={m.amount} />
      | Msg.Staking.Delegate.Failure(f) => <TokenMsg.DelegateMsg coin={f.amount} />
      }
    | UndelegateMsg(msg) =>
      switch msg {
      | Msg.Staking.Undelegate.Success(m) => <TokenMsg.DelegateMsg coin={m.amount} />
      | Msg.Staking.Undelegate.Failure(f) => <TokenMsg.DelegateMsg coin={f.amount} />
      }
    | RedelegateMsg(msg) =>
      switch msg {
      | Msg.Staking.Redelegate.Success(m) => <TokenMsg.RedelegateMsg amount={m.amount} />
      | Msg.Staking.Redelegate.Failure(f) => <TokenMsg.RedelegateMsg amount={f.amount} />
      }
    | WithdrawRewardMsg(msg) =>
      switch msg {
      | Msg.Distribution.WithdrawReward.Success(m) =>
        <TokenMsg.WithdrawRewardMsg amount={m.amount} />
      | Msg.Distribution.WithdrawReward.Failure(f) => React.null
      }
    | WithdrawCommissionMsg(msg) =>
      switch msg {
      | Msg.Distribution.WithdrawCommission.Success(m) =>
        <TokenMsg.WithdrawCommissionMsg amount={m.amount} />
      | Msg.Distribution.WithdrawCommission.Failure(f) => React.null
      }
    | UnjailMsg(_) => React.null
    | SetWithdrawAddressMsg(m) =>
      <ValidatorMsg.SetWithdrawAddress withdrawAddress={m.withdrawAddress} />
    | SubmitProposalMsg(msg) =>
      switch msg {
      | Msg.Gov.SubmitProposal.Success(m) =>
        <ProposalMsg.SubmitProposal.Success proposalID=m.proposalID title=m.title />
      | Msg.Gov.SubmitProposal.Failure(f) => <ProposalMsg.SubmitProposal.Fail title=f.title />
      }
    | DepositMsg(msg) =>
      switch msg {
      | Msg.Gov.Deposit.Success(m) =>
        <ProposalMsg.Deposit.Success amount={m.amount} proposalID={m.proposalID} title={m.title} />
      | Msg.Gov.Deposit.Failure(f) => <ProposalMsg.Deposit.Fail proposalID={f.proposalID} />
      }
    | VoteMsg(msg) =>
      switch msg {
      | Msg.Gov.Vote.Success(m) =>
        <ProposalMsg.Vote.Success proposalID={m.proposalID} title={m.title} />
      | Msg.Gov.Vote.Failure(f) => <ProposalMsg.Vote.Fail proposalID={f.proposalID} />
      }
    | VoteWeightedMsg(msg) =>
      switch msg {
      | Msg.Gov.VoteWeighted.Success(m) =>
        <ProposalMsg.Vote.Success proposalID={m.proposalID} title={m.title} />
      | Msg.Gov.VoteWeighted.Failure(f) => <ProposalMsg.Vote.Fail proposalID={f.proposalID} />
      }
    | MultiSendMsg(msg) => <TokenMsg.MultisendMsg inputs={msg.inputs} outputs={msg.outputs} />
    | ExecMsg(msg) => <ValidatorMsg.Exec messages={msg.msgs} />

    // <OracleMsg.RequestMsg id oracleScriptID oracleScriptName />
    // | ReceiveMsg({fromAddress, amount}) => <TokenMsg.ReceiveMsg fromAddress amount />
    // | MultiSendMsgSuccess({inputs, outputs}) => <TokenMsg.MultisendMsg inputs outputs />
    // | DelegateMsgSuccess({amount}) => <TokenMsg.DelegateMsg amount />
    // | UndelegateMsgSuccess({amount}) => <TokenMsg.UndelegateMsg amount />
    // | RedelegateMsgSuccess({amount}) => <TokenMsg.RedelegateMsg amount />
    // | WithdrawRewardMsgSuccess({amount}) => <TokenMsg.Distribution.WithdrawReward.Msg amount />
    // | WithdrawCommissionMsgSuccess({amount}) => <TokenMsg.WithdrawCommissionMsg amount />
    // | CreateDataSourceMsgSuccess({id, name}) => <DataMsg.Oracle.CreateDataSourceMsg id name />
    // | EditDataSourceMsgSuccess({id, name}) => <DataMsg.EditDataSourceMsg id name />
    // | CreateOracleScriptMsgSuccess({id, name}) => <DataMsg.CreateOracleScriptMsg id name />
    // | EditOracleScriptMsgSuccess({id, name}) => <DataMsg.EditOracleScriptMsg id name />
    // | RequestMsgSuccess({id, oracleScriptID, oracleScriptName}) =>
    //   <DataMsg.RequestMsg id oracleScriptID oracleScriptName />
    // | ReportMsgSuccess({requestID}) => <DataMsg.ReportMsg requestID />
    // | AddReporterMsgSuccess({reporter}) => <ValidatorMsg.AddReporter reporter />
    // | RemoveReporterMsgSuccess({reporter}) => <ValidatorMsg.RemoveReporter reporter />
    // | CreateValidatorMsgSuccess({moniker}) => <ValidatorMsg.CreateValidator moniker />
    // | EditValidatorMsgSuccess({moniker}) => <ValidatorMsg.EditValidator moniker />
    // | UnjailMsgSuccess(_) => React.null
    // | SetWithdrawAddressMsgSuccess({withdrawAddress}) =>
    //   <ValidatorMsg.SetWithdrawAddress withdrawAddress />
    // | SubmitProposalMsgSuccess({proposalID, title}) =>
    //   <ProposalMsg.SubmitProposal proposalID title />
    // | DepositMsgSuccess({amount, proposalID, title}) =>
    //   <ProposalMsg.Deposit amount proposalID title />
    // | VoteMsgSuccess({proposalID, title}) => <ProposalMsg.Vote proposalID title />
    // | ActivateMsgSuccess(_) => React.null
    // | CreateClientMsg(_) => React.null
    // | UpdateClientMsg({clientID})
    // | UpgradeClientMsg({clientID})
    // | SubmitClientMisbehaviourMsg({clientID}) =>
    //   <IBCClientMsg.Client clientID />
    // | ConnectionOpenTryMsg({clientID, counterparty})
    // | ConnectionOpenInitMsg({clientID, counterparty}) =>
    //   <IBCConnectionMsg.ConnectionCommon clientID counterpartyClientID=counterparty.clientID />
    // | ConnectionOpenAckMsg({connectionID, counterpartyConnectionID}) =>
    //   <IBCConnectionMsg.ConnectionOpenAck connectionID counterpartyConnectionID />
    // | ConnectionOpenConfirmMsg({connectionID}) =>
    //   <IBCConnectionMsg.ConnectionOpenConfirm connectionID />
    // | ChannelOpenInitMsg({portID, channel})
    // | ChannelOpenTryMsg({portID, channel}) =>
    //   <IBCChannelMsg.ChannelOpenCommon portID counterpartyPortID=channel.counterparty.portID />
    // | ChannelOpenAckMsg({channelID, counterpartyChannelID}) =>
    //   <IBCChannelMsg.ChannelOpenAck channelID counterpartyChannelID />
    // | ChannelOpenConfirmMsg({channelID}) => <IBCChannelMsg.ChannelCloseCommon channelID />
    // | ChannelCloseInitMsg({channelID})
    // | ChannelCloseConfirmMsg({channelID}) =>
    //   <IBCChannelMsg.ChannelCloseCommon channelID />
    // | TransferMsg({token, receiver}) =>
    //   <IBCTransferMsg.Transfer toAddress=receiver amount=token.amount denom=token.denom />
    // | RecvPacketMsgSuccess({packetData}) => <IBCPacketMsg.Packet packetType=packetData.packetType />
    // | RecvPacketMsgFail(_)
    // | AcknowledgePacketMsg(_)
    // | TimeoutMsg(_)
    // | TimeoutOnCloseMsg(_)
    | UnknownMsg => React.null
    }}
  </div>
}
