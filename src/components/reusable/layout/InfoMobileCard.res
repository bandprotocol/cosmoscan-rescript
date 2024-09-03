type coin_amount_t = {
  value: list<Coin.t>,
  hasDenom: bool,
}

type request_count_t = {
  reportedValidators: int,
  minimumValidators: int,
  requestValidators: int,
}

type request_response_t = {
  requestCount: int,
  responseTime: option<float>,
}

type t =
  | Address(Address.t, int, [#account | #validator])
  | Height(ID.Block.t)
  | Coin(coin_amount_t)
  | Count(int)
  | DataSource(ID.DataSource.t, string)
  | OracleScript(ID.OracleScript.t, string)
  | RequestID(ID.Request.t)
  | RequestResponse(request_response_t)
  | RequestStatus(RequestSub.resolve_status_t, string)
  | ProgressBar(request_count_t)
  | Float(float, option<int>)
  | KVTableReport(array<string>, array<MsgDecoder.RawDataReport.t>)
  | KVTableRequest(option<array<Obi2.field_key_value_t>>)
  | CopyButton(JsBuffer.t)
  | Percentage(float, option<int>)
  | Timestamp(MomentRe.Moment.t)
  | TxHash(Hash.t, int)
  | BlockHash(Hash.t)
  | Validator({address: Address.t, moniker: string, identity: string, isActive?: bool})
  | Messages(Hash.t, list<Msg.result_t>, bool, string)
  | MsgBadgeGroup(Hash.t, list<Msg.result_t>)
  | PubKey(PubKey.t)
  | Badge(Msg.badge_theme_t)
  | VotingPower(Coin.t, float)
  | Uptime(option<float>)
  | Loading(int)
  | Text(string)
  | Status({status: bool, withText?: bool})
  | Nothing

module Styles = {
  open CssJs
  let vFlex = style(. [display(#flex), alignItems(#center)])
  let addressContainer = w => {
    style(. [width(px(w))])
  }
  let badge = color =>
    style(. [
      display(inlineFlex),
      padding2(~v=px(5), ~h=px(10)),
      backgroundColor(color),
      borderRadius(px(15)),
    ])
  let logo = style(. [width(px(20))])

  let uptimeContainer = style(. [width(#percent(70.))])
}

@react.component
let make = (~info) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

  switch info {
  | Address(address, width, accountType) =>
    <div className={Styles.addressContainer(width)}>
      <AddressRender address position=AddressRender.Text clickable=true accountType />
    </div>
  | Height(height) =>
    <div className=Styles.vFlex>
      <TypeID.Block id=height size=Text.Xl position=TypeID.MobileCard />
    </div>
  | Coin({value, hasDenom}) =>
    <AmountRender coins=value pos={hasDenom ? AmountRender.TxIndex : Fee} />
  | Count(value) => <Text value={value->Format.iPretty} size=Xl />
  | DataSource(id, name) =>
    <div className=Styles.vFlex>
      <TypeID.DataSource id position=TypeID.MobileCard />
      <HSpacing size=Spacing.sm />
      <Text value=name ellipsis=true />
    </div>
  | OracleScript(id, name) =>
    <TypeID.OracleScript id size=Text.Xl position=TypeID.MobileCard details=name />
  | RequestID(id) => <TypeID.Request id size=Text.Xl position=TypeID.MobileCard />
  | RequestResponse({requestCount, responseTime: responseTimeOpt}) =>
    <div className={CssHelper.flexBox()}>
      <Text value={requestCount->Format.iPretty} block=true ellipsis=true />
      <HSpacing size=Spacing.sm />
      <Text
        value={switch responseTimeOpt {
        | Some(responseTime') => "(" ++ responseTime'->Format.fPretty(~digits=2) ++ "s)"
        | None => "(TBD)"
        }}
        block=true
      />
    </div>
  | RequestStatus(resolveStatus, text) => <RequestStatus resolveStatus text size=Text.Xl />
  | ProgressBar({reportedValidators, minimumValidators, requestValidators}) =>
    <ProgressBar reportedValidators minimumValidators requestValidators />
  | Float(value, digits) => <Text value={value->Format.fPretty(~digits?)} code=true size=Xl />
  | KVTableReport(heading, rawReports) =>
    <KVTable
      headers=heading
      rows={rawReports->Belt.Array.map(rawReport => [
        KVTable.Value(rawReport.externalDataID->Belt.Int.toString),
        KVTable.Value(rawReport.exitCode->Belt.Int.toString),
        KVTable.Value(rawReport.data->JsBuffer.toUTF8),
      ])}
    />
  | KVTableRequest(calldataKVsOpt) =>
    switch calldataKVsOpt {
    | Some(calldataKVs) =>
      <KVTable
        rows={calldataKVs->Belt.Array.map(({fieldName, fieldValue}) => [
          KVTable.Value(fieldName),
          KVTable.Value(fieldValue),
        ])}
      />
    | None =>
      <Text
        value="Could not decode calldata."
        spacing={Text.Em(0.02)}
        nowrap=true
        ellipsis=true
        block=true
      />
    }
  | CopyButton(calldata) =>
    <CopyButton data={calldata->JsBuffer.toHex(~with0x=false)} title="Copy as bytes" width=125 />
  | Percentage(value, digits) => <Text value={value->Format.fPercent(~digits?)} code=true size=Xl />
  | Text(text) => <Text value=text spacing={Text.Em(0.02)} nowrap=true ellipsis=true block=true />
  | Timestamp(time) => <Timestamp time size=Text.Body2 weight=Text.Regular />
  | Validator({address, moniker, identity, ?isActive}) =>
    <ValidatorMonikerLink
      validatorAddress=address moniker size=Text.Xl identity width={#px(230)} ?isActive
    />
  | PubKey(publicKey) => <PubKeyRender alignLeft=true pubKey=publicKey display=#block />
  | TxHash(txHash, width) => <TxLink txHash width size=Text.Xl />
  | BlockHash(hash) =>
    <Text
      value={hash->Hash.toHex(~upper=true)}
      weight=Text.Medium
      block=true
      code=true
      ellipsis=true
      color={theme.neutral_900}
    />
  | Messages(txHash, messages, success, errMsg) => <TxMessages txHash messages success errMsg />
  | MsgBadgeGroup(txHash, messages) => <MsgBadgeGroup txHash messages />
  | Badge(_) => React.null
  | VotingPower(tokens, votingPercent) =>
    <div className=Styles.vFlex>
      <Text
        value={votingPercent->Format.fPercent(~digits=2)}
        block=true
        size=Xl
        weight=Bold
        color=theme.neutral_900
        code=true
      />
      <HSpacing size=Spacing.sm />
      <Text
        value={"(" ++ tokens->Coin.getBandAmountFromCoin->Format.fPretty(~digits=0) ++ ")"}
        weight=Text.Thin
        block=true
        size=Xl
        code=true
      />
    </div>
  | Status({status, ?withText}) => <StatusIcon status ?withText />
  // Special case for uptime to have loading state inside.
  | Uptime(uptimeOpt) =>
    switch uptimeOpt {
    | Some(uptime) =>
      <div className={Css.merge(list{Styles.vFlex, Styles.uptimeContainer})}>
        <Text
          value={uptime->Format.fPercent(~digits=uptime == 100. ? 0 : 2)}
          spacing={Text.Em(0.02)}
          nowrap=true
          code=true
          size=Xl
        />
        <HSpacing size=Spacing.lg />
        <ProgressBar.Uptime percent=uptime />
      </div>
    | None => <Text value="N/A" nowrap=true />
    }
  | Loading(width) => <LoadingCensorBar width height=21 />
  | Nothing => React.null
  }
}
