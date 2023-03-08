module Styles = {
  open CssJs

  let topicContainer = style(. [
    display(#flex),
    justifyContent(#spaceBetween),
    width(#percent(100.)),
    lineHeight(#px(16)),
    alignItems(#center),
  ])

  let failIcon = style(. [width(#px(16)), height(#px(16))])
  let msgContainer = style(. [selector("> div + div", [marginTop(#px(24))])])
  let jsonMode = style(. [display(#flex), alignItems(#center), cursor(#pointer), height(#px(30))])
}

let renderUnknownMessage = () =>
  <Col col=Col.Six>
    <div className=Styles.topicContainer>
      <Text value="Unknown Message" size=Text.Caption transform=Text.Uppercase />
      <img src=Images.fail className=Styles.failIcon />
    </div>
  </Col>

let renderBody = (msg: Msg.t) =>
  // switch msg.decoded {
  // | SendMsg(send) => <IndexTokenMsg.SendMsg send />
  // | RequestMsg(request) => <IndexOracleMsg.RequestMsg request />
  // | CreateDataSourceMsg(dataSource) => <RenderMsgDetails.CreateDataSourceMsg msg={dataSource} />

  // | DelegateMsgSuccess(delegation) => <IndexTokenMsg.DelegateMsg delegation />
  // | DelegateMsgFail(delegation) => <IndexTokenMsg.DelegateFailMsg delegation />
  // | UndelegateMsgSuccess(undelegation) => <IndexTokenMsg.UndelegateMsg undelegation />
  // | UndelegateMsgFail(undelegation) => <IndexTokenMsg.UndelegateFailMsg undelegation />
  // | RedelegateMsgSuccess(redelegation) => <IndexTokenMsg.RedelegateMsg redelegation />
  // | RedelegateMsgFail(redelegation) => <IndexTokenMsg.RedelegateFailMsg redelegation />
  // | WithdrawRewardMsgSuccess(withdrawal) => <IndexTokenMsg.Distribution.WithdrawReward.Msg withdrawal />
  // | WithdrawRewardMsgFail(withdrawal) => <IndexTokenMsg.Distribution.WithdrawReward.FailMsg withdrawal />
  // | WithdrawCommissionMsgSuccess(withdrawal) => <IndexTokenMsg.WithdrawComissionMsg withdrawal />
  // | WithdrawCommissionMsgFail(withdrawal) => <IndexTokenMsg.WithdrawComissionFailMsg withdrawal />
  // | MultiSendMsgSuccess(tx)
  // | MultiSendMsgFail(tx) =>
  //   <IndexTokenMsg.MultisendMsg tx />
  // | CreateDataSourceMsgSuccess(dataSource) => <IndexDataMsg.Oracle.CreateDataSourceMsg dataSource />
  // | CreateDataSourceMsgFail(dataSource) => <IndexDataMsg.Oracle.CreateDataSourceFailMsg dataSource />
  // | EditDataSourceMsgSuccess(dataSource)
  // | EditDataSourceMsgFail(dataSource) =>
  //   <IndexDataMsg.EditDataSourceMsg dataSource />
  // | CreateOracleScriptMsgSuccess(oracleScript) =>
  //   <IndexDataMsg.CreateOracleScriptMsg oracleScript />
  // | CreateOracleScriptMsgFail(oracleScript) =>
  //   <IndexDataMsg.CreateOracleScriptFailMsg oracleScript />
  // | EditOracleScriptMsgSuccess(oracleScript)
  // | EditOracleScriptMsgFail(oracleScript) =>
  //   <IndexDataMsg.EditOracleScriptMsg oracleScript />
  // | RequestMsgSuccess(request) => <IndexDataMsg.RequestMsg request />
  // | RequestMsgFail(request) => <IndexDataMsg.RequestFailMsg request />
  // | ReportMsgSuccess(report)
  // | ReportMsgFail(report) =>
  //   <IndexDataMsg.ReportMsg report />
  // | AddReporterMsgSuccess(address) => <IndexValidatorMsg.AddReporterMsg address />
  // | AddReporterMsgFail(address) => <IndexValidatorMsg.AddReporterFailMsg address />
  // | RemoveReporterMsgSuccess(address) => <IndexValidatorMsg.RemoveReporterMsg address />
  // | RemoveReporterMsgFail(address) => <IndexValidatorMsg.RemoveReporterFailMsg address />
  // | CreateValidatorMsgSuccess(validator)
  // | CreateValidatorMsgFail(validator) =>
  //   <IndexValidatorMsg.CreateValidatorMsg validator />
  // | EditValidatorMsgSuccess(validator)
  // | EditValidatorMsgFail(validator) =>
  //   <IndexValidatorMsg.EditValidatorMsg validator />
  // | UnjailMsgSuccess(unjail)
  // | UnjailMsgFail(unjail) =>
  //   <IndexValidatorMsg.UnjailMsg unjail />
  // | SetWithdrawAddressMsgSuccess(set)
  // | SetWithdrawAddressMsgFail(set) =>
  //   <IndexValidatorMsg.SetWithdrawAddressMsg set />
  // | SubmitProposalMsgSuccess(proposal) => <IndexProposalMsg.SubmitProposalMsg proposal />
  // | SubmitProposalMsgFail(proposal) => <IndexProposalMsg.SubmitProposalFailMsg proposal />
  // | DepositMsgSuccess(deposit) => <IndexProposalMsg.DepositMsg deposit />
  // | DepositMsgFail(deposit) => <IndexProposalMsg.DepositFailMsg deposit />
  // | VoteMsgSuccess(vote) => <IndexProposalMsg.VoteMsg vote />
  // | VoteMsgFail(vote) => <IndexProposalMsg.VoteFailMsg vote />
  // | ActivateMsgSuccess(activate)
  // | ActivateMsgFail(activate) =>
  //   <IndexValidatorMsg.ActivateMsg activate />
  // | UnknownMsg => renderUnknownMessage()
  // // IBC Msg
  // | CreateClientMsg(client) => <IndexIBCClientMsg.CreateClient client />
  // | UpdateClientMsg(client) => <IndexIBCClientMsg.UpdateClient client />
  // | UpgradeClientMsg(client) => <IndexIBCClientMsg.UpgradeClient client />
  // | SubmitClientMisbehaviourMsg(client) => <IndexIBCClientMsg.SubmitClientMisbehaviour client />
  // | ConnectionOpenInitMsg(connection) => <IndexIBCConnectionMsg.ConnectionOpenInit connection />
  // | ConnectionOpenTryMsg(connection) => <IndexIBCConnectionMsg.ConnectionOpenTry connection />
  // | ConnectionOpenAckMsg(connection) => <IndexIBCConnectionMsg.ConnectionOpenAck connection />
  // | ConnectionOpenConfirmMsg(connection) =>
  //   <IndexIBCConnectionMsg.ConnectionOpenConfirm connection />
  // | ChannelOpenInitMsg(channel) => <IndexIBCChannelMsg.ChannelOpenInit channel />
  // | ChannelOpenTryMsg(channel) => <IndexIBCChannelMsg.ChannelOpenTry channel />
  // | ChannelOpenAckMsg(channel) => <IndexIBCChannelMsg.ChannelOpenAck channel />
  // | ChannelOpenConfirmMsg(channel) => <IndexIBCChannelMsg.ChannelOpenConfirm channel />
  // | ChannelCloseInitMsg(channel) => <IndexIBCChannelMsg.ChannelCloseInit channel />
  // | ChannelCloseConfirmMsg(channel) => <IndexIBCChannelMsg.ChannelCloseConfirm channel />
  // | AcknowledgePacketMsg(packet) => <IndexIBCPacketMsg.AcknowledgePacket packet />
  // | RecvPacketMsgSuccess(packet) => <IndexIBCPacketMsg.RecvPacketSuccess packet />
  // | RecvPacketMsgFail(packet) => <IndexIBCPacketMsg.RecvPacketFail packet />
  // | TimeoutMsg(packet) => <IndexIBCPacketMsg.Timeout packet />
  // | TimeoutOnCloseMsg(packet) => <IndexIBCPacketMsg.TimeoutOnClose packet />
  // | TransferMsg(msg) => <IndexIBCTransferMsg.Transfer msg />
  // | UnknownMsg => React.null
  // }
  <RenderMsgDetails contents={msg.decoded->RenderMsgDetails.getContent} />

module MsgDetailCard = {
  @react.component
  let make = (~msg: Msg.t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let badge = msg.decoded->Msg.getBadge
    let (showJson, setShowJson) = React.useState(_ => false)
    let toggle = () => setShowJson(prev => !prev)

    <InfoContainer>
      <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
        <div className={CssHelper.flexBox()}>
          <IndexMsgIcon category=badge.category />
          <HSpacing size=Spacing.sm />
          <Heading value=badge.name size=Heading.H4 />
        </div>
        <div className=Styles.jsonMode onClick={_ => toggle()}>
          <Text value="JSON Mode" weight=Text.Semibold color=theme.neutral_900 />
          <Switch checked=showJson />
        </div>
      </div>
      {showJson
        ? <div className={CssHelper.mt(~size=32, ())}>
            <JsonViewer src=msg.raw />
          </div>
        : <>
            <SeperatedLine mt=32 mb=24 />
            {renderBody(msg)}
          </>}
    </InfoContainer>
  }
}

@react.component
let make = (~messages: list<Msg.t>) =>
  <div className=Styles.msgContainer>
    {messages
    ->Belt.List.mapWithIndex((index, msg) => {
      let badge = msg.decoded->Msg.getBadge
      <MsgDetailCard key={index->Belt.Int.toString ++ badge.name} msg />
    })
    ->Array.of_list
    ->React.array}
  </div>

module Loading = {
  @react.component
  let make = () =>
    <InfoContainer>
      <div className={CssHelper.flexBox()}>
        <LoadingCensorBar width=24 height=24 radius=24 />
        <HSpacing size=Spacing.sm />
        <LoadingCensorBar width=75 height=15 />
        <SeperatedLine mt=32 mb=24 />
      </div>
      <Row>
        <Col col=Col.Six mb=24>
          <LoadingCensorBar width=75 height=15 mb=8 />
          <LoadingCensorBar width=150 height=15 />
        </Col>
        <Col col=Col.Six mb=24>
          <LoadingCensorBar width=75 height=15 mb=8 />
          <LoadingCensorBar width=150 height=15 />
        </Col>
        <Col col=Col.Six>
          <LoadingCensorBar width=75 height=15 mb=8 />
          <LoadingCensorBar width=150 height=15 />
        </Col>
      </Row>
    </InfoContainer>
}
