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
let make = (~msg: Msg.result_t) => {
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
    | MultiSendMsg(msg) => <TokenMsg.MultisendMsg inputs={msg.inputs} outputs={msg.outputs} />
    | ReceiveMsg({fromAddress, amount}) => <TokenMsg.ReceiveMsg fromAddress amount />
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
        <ProposalMsg.SubmitProposal.Success
          proposalID=m.proposalID title={m.title->Belt.Option.getWithDefault("")}
        />
      | Msg.Gov.SubmitProposal.Failure(f) =>
        <ProposalMsg.SubmitProposal.Fail title={f.title->Belt.Option.getWithDefault("")} />
      }
    | DepositMsg(msg) =>
      switch msg {
      | Msg.Gov.Deposit.Success(m) =>
        <ProposalMsg.Deposit.Success amount={m.amount} proposalID={m.proposalID} title={m.title} />
      | Msg.Gov.Deposit.Failure(f) => <ProposalMsg.Deposit.Fail proposalID={f.proposalID} />
      }
    | LegacyVoteMsg(msg) =>
      switch msg {
      | Msg.Gov.Vote.Success(m) =>
        <ProposalMsg.Vote.Success proposalID={m.proposalID} title={m.title} />
      | Msg.Gov.Vote.Failure(f) => <ProposalMsg.Vote.Fail proposalID={f.proposalID} />
      }
    | LegacyVoteWeightedMsg(msg) =>
      switch msg {
      | Msg.Gov.VoteWeighted.Success(m) =>
        <ProposalMsg.Vote.Success proposalID={m.proposalID} title={m.title} />
      | Msg.Gov.VoteWeighted.Failure(f) => <ProposalMsg.Vote.Fail proposalID={f.proposalID} />
      }
    | VoteMsg(msg) => <ProposalMsg.Vote.Fail proposalID={msg.proposalID} />
    | SubmitCouncilProposalMsg(msg) =>
      switch msg {
      | Msg.Council.SubmitProposal.Success({proposalID, council}) =>
        <ProposalMsg.SubmitCouncilProposal.Success proposalID council />
      | Msg.Council.SubmitProposal.Failure({council}) =>
        <ProposalMsg.SubmitCouncilProposal.Fail council />
      }
    | CreateClientMsg(_) => React.null
    | UpgradeClientMsg({clientID})
    | UpdateClientMsg({clientID})
    | SubmitClientMisbehaviourMsg({clientID}) =>
      <IBCClientMsg.Client clientID />
    | ConnectionOpenTryMsg({clientID, counterparty})
    | ConnectionOpenInitMsg({clientID, counterparty}) =>
      <IBCConnectionMsg.ConnectionCommon clientID counterpartyClientID={counterparty.clientID} />
    | ConnectionOpenAckMsg({connectionID, counterpartyConnectionID}) =>
      <IBCConnectionMsg.ConnectionOpenAck connectionID counterpartyConnectionID />
    | ConnectionOpenConfirmMsg({connectionID}) =>
      <IBCConnectionMsg.ConnectionOpenConfirm connectionID />
    | ChannelOpenInitMsg({portID, channel})
    | ChannelOpenTryMsg({portID, channel}) =>
      <IBCChannelMsg.ChannelOpenCommon portID counterpartyPortID={channel.counterparty.portID} />
    | ChannelOpenAckMsg({channelID, counterpartyChannelID}) =>
      <IBCChannelMsg.ChannelOpenAck channelID counterpartyChannelID />
    | ChannelOpenConfirmMsg({channelID})
    | ChannelCloseInitMsg({channelID})
    | ChannelCloseConfirmMsg({channelID}) =>
      <IBCChannelMsg.ChannelCloseCommon channelID />
    | RecvPacketMsg(msg) =>
      switch msg {
      | Msg.Channel.RecvPacket.Success({packetData}) =>
        switch packetData {
        | Some({packetType}) => <IBCPacketMsg.Packet packetType />
        | None => React.null
        }
      | Msg.Channel.RecvPacket.Failure(f) => React.null
      }
    | AcknowledgePacketMsg(_)
    | TimeoutMsg(_)
    | TimeoutOnCloseMsg(_)
    | ActivateMsg(_) => React.null
    | TransferMsg(msg) =>
      switch msg {
      | Msg.Application.Transfer.Success({receiver, token}) =>
        <IBCTransferMsg.Transfer toAddress=receiver amount={token.amount} denom={token.denom} />
      | Msg.Application.Transfer.Failure(f) => React.null
      }
    | ExecMsg(msg) => <ValidatorMsg.Exec messages={msg.msgs} />
    // | ExecMsg(msg) => React.null
    | UnknownMsg => React.null
    }}
  </div>
}
