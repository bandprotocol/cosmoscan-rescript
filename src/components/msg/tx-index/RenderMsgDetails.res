module Styles = {
  open CssJs

  let execContainers = (theme: Theme.t) =>
    style(. [padding(#px(20)), backgroundColor(theme.neutral_100), borderRadius(#px(4))])

  let subMsgContainer = (theme: Theme.t) =>
    style(. [
      padding3(~top=#px(20), ~h=#px(20), ~bottom=#zero),
      backgroundColor(theme.neutral_100),
      borderRadius(#px(4)),
      marginBottom(#px(10)),
    ])
}
module Calldata = {
  @react.component
  let make = (~schema, ~calldata) => {
    let failed =
      <Text
        value="Could not decode calldata."
        spacing=Text.Em(0.02)
        nowrap=true
        ellipsis=true
        code=true
        block=true
        size=Text.Body1
      />
    <>
      <div className={Css.merge(list{CssHelper.flexBox(~justify=#flexEnd, ()), CssHelper.mb()})}>
        <CopyButton
          data={calldata->JsBuffer.toHex(~with0x=false)} title="Copy as bytes" width=125
        />
      </div>
      {Obi2.decode(schema, Obi2.Input, calldata)->Belt.Option.mapWithDefault(failed, calldataKVs =>
        <KVTable
          rows={calldataKVs->Belt.Array.map(({fieldName, fieldValue}) => [
            KVTable.Value(fieldName),
            KVTable.Value(fieldValue),
          ])}
        />
      )}
    </>
  }
}

module Packet = {
  @react.component
  let make = (~packet: Msg.Packet.t) => {
    <Text value={packet.data} size=Text.Body1 />
  }
}

type content_inner_t =
  | PlainText(string)
  | Address(Address.t)
  | ValidatorAddress(Address.t)
  | Calldata(string, JsBuffer.t)
  | CoinList(Belt.List.t<Coin.t>)
  | ID(React.element) // TODO: refactor not to receive react.element
  | RawReports(Belt.List.t<Msg.Oracle.RawDataReport.t>)
  | Timestamp(MomentRe.Moment.t)
  | ValidatorLink(Address.t, string, string)
  | Packet(Msg.Packet.t)
  | VoteWeighted(Belt.List.t<Msg.Gov.VoteWeighted.Options.t>)
  | MultiSendInputList(Belt.List.t<Msg.Bank.MultiSend.send_tx_t>)
  | MultiSendOutputList(Belt.List.t<Msg.Bank.MultiSend.send_tx_t>)
  | ExecList(list<Msg.msg_t>)
  | SignalList(Belt.List.t<Feeds.Signal.t>)
  | SignalPriceList(Belt.List.t<Feeds.SignalPrice.t>)
  | None

type content_t = {
  title: string,
  content: content_inner_t,
  order: int,
  heading?: string,
}

let renderValue = v => {
  switch v {
  | Address(address) => <AddressRender position=AddressRender.Subtitle address />
  | ValidatorAddress(address) => {
      let valinfo = SearchBarQuery.getValidatorMoniker(~address, ())

      switch valinfo {
      | Data(val) =>
        switch val {
        | Some({moniker, identity}) =>
          <ValidatorMonikerLink
            validatorAddress={address}
            moniker={moniker}
            identity={identity}
            width={#percent(100.)}
            avatarWidth=20
            size=Text.Body1
          />
        | _ => <AddressRender position=AddressRender.Subtitle address accountType={#validator} />
        }

      | Loading => <LoadingCensorBar width=150 height=15 />
      | _ => React.null
      }
    }

  | PlainText(content) => <Text value={content} size=Text.Body1 breakAll=true />
  | CoinList(amount) => <AmountRender coins={amount} />
  | ID(element) => element
  | Calldata(schema, data) => <Calldata schema calldata=data />
  | RawReports(data) =>
    <KVTable
      headers=["External Id", "Exit Code", "Value"]
      rows={data
      ->Belt.List.sort((a, b) => a.externalDataID - b.externalDataID)
      ->Belt.List.toArray
      ->Belt.Array.map(rawReport => [
        KVTable.Value(rawReport.externalDataID->Belt.Int.toString),
        KVTable.Value(rawReport.exitCode->Belt.Int.toString),
        KVTable.Value(rawReport.data->JsBuffer.toUTF8),
      ])}
    />
  | Timestamp(timestamp) => <Timestamp time={timestamp} size=Text.Body1 />
  | ValidatorLink(address, moniker, identity) =>
    switch (moniker, identity) {
    | ("", "") => <AddressRender position={Subtitle} address accountType={#validator} />
    | (_, _) =>
      <ValidatorMonikerLink
        validatorAddress={address}
        moniker={moniker}
        identity={identity}
        width={#percent(100.)}
        avatarWidth=20
        size=Text.Body1
      />
    }
  | VoteWeighted(options) =>
    <>
      {options
      ->Belt.List.mapWithIndex((index, {weight, option}) => {
        let optionCount = options->Belt.List.toArray->Belt_Array.length
        let mb = index == optionCount ? 0 : 8

        <div
          key={index->Belt.Int.toString ++ weight->Js.Float.toString ++ option}
          className={CssHelper.flexBox(
            ~justify=#flexStart,
            ~align=#center,
            ~direction=#row,
            ~wrap=#wrap,
            (),
          )}>
          <Text size=Text.Body1 value=option />
          <HSpacing size=Spacing.sm />
          <Text size=Text.Body1 value={weight->Js.Float.toString} />
          {index == optionCount - 1 ? React.null : <HSpacing size=Spacing.md />}
        </div>
      })
      ->Belt.List.toArray
      ->React.array}
    </>
  | Packet(packet) => <Packet packet />
  | MultiSendInputList(inputs) =>
    <KVTable
      headers=["Address", "Amount (BAND)"]
      rows={inputs
      ->Belt.List.toArray
      ->Belt.Array.map(input => [
        KVTable.Value(
          // <AddressRender address={input.address} />
          input.address->Address.toBech32,
        ),
        KVTable.Value(
          // <AmountRender coins={input.coins} />
          input.coins
          ->Coin.getBandAmountFromCoins
          ->Belt.Float.toString,
        ),
      ])}
    />
  | MultiSendOutputList(outputs) =>
    <KVTable
      headers=["Address", "Amount (BAND)"]
      rows={outputs
      ->Belt.List.toArray
      ->Belt.Array.map(output => [
        KVTable.Value(
          // <AddressRender address={output.address} />
          output.address->Address.toBech32,
        ),
        KVTable.Value(
          // <AmountRender coins={output.coins} />
          output.coins
          ->Coin.getBandAmountFromCoins
          ->Belt.Float.toString,
        ),
      ])}
    />
  | SignalList(signals) =>
    <KVTable
      headers=["Signal ID", "Power"]
      rows={signals
      ->Belt.List.toArray
      ->Belt.Array.map(signal => [
        KVTable.Value(signal.id),
        KVTable.Value(signal.power->Belt.Float.toString),
      ])}
    />
  | SignalPriceList(prices) =>
    <KVTable
      headers=["Signal", "Price"]
      rows={prices
      ->Belt.List.toArray
      ->Belt.Array.map(price => [
        KVTable.Value(price.signalId),
        KVTable.Value(
          switch // render N/A if no price reported
          price.price {
          | Some(price) => price->Belt.Float.toString
          | None => "N/A"
          },
        ),
      ])}
    />
  // Noted: We support only 1 level of exec (no recursion)
  | ExecList(msgs) => React.null
  | None => React.null
  }
}

module CreateDataSource = {
  let factory = (msg: Msg.Oracle.CreateDataSource.internal_t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {title: "Owner", content: Address(msg.owner), order: 2},
      {title: "Treasury", content: Address(msg.treasury), order: 3},
      {title: "Fee", content: CoinList(msg.fee), order: 4},
    ])

  let success = (msg: Msg.Oracle.CreateDataSource.success_t) =>
    msg->factory([
      {
        title: "ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.DataSource position=TypeID.Subtitle id={msg.id} />
            <HSpacing size=Spacing.sm />
            <Text value={msg.name} size=Text.Body1 />
          </div>,
        ),
        order: 1,
      },
    ])

  let failed = (msg: Msg.Oracle.CreateDataSource.fail_t) =>
    msg->factory([
      {
        title: "Name",
        content: PlainText(msg.name),
        order: 1,
      },
    ])
}

module Request = {
  let factory = (msg: Msg.Oracle.Request.t<'a, 'b, 'c>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Owner",
        content: Address(msg.sender),
        order: 3,
      },
      {
        title: "Fee Limit",
        content: CoinList(msg.feeLimit),
        order: 4,
      },
      {
        title: "Prepare Gas",
        content: PlainText(msg.prepareGas->Belt.Int.toString),
        order: 5,
      },
      {
        title: "Execute Gas",
        content: PlainText(msg.executeGas->Belt.Int.toString),
        order: 6,
      },
      {
        title: "Request Validator Count",
        content: PlainText(msg.askCount->Belt.Int.toString),
        order: 7,
      },
      {
        title: "Sufficient Validator Count",
        content: PlainText(msg.minCount->Belt.Int.toString),
        order: 8,
      },
    ])

  let success = (msg: Msg.Oracle.Request.success_t) =>
    msg->factory([
      {
        title: "Request ID",
        content: ID(<TypeID.Request position=TypeID.Subtitle id={msg.id} />),
        order: 1,
      },
      {
        title: "Oracle Script ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.OracleScript position=TypeID.Subtitle id={msg.oracleScriptID} />
            <HSpacing size=Spacing.sm />
            <Text value={msg.oracleScriptName} size=Text.Body1 />
          </div>,
        ),
        order: 2,
      },
      {
        title: "Calldata",
        content: Calldata(msg.schema, msg.calldata),
        order: 9,
      },
    ])

  let failed = (msg: Msg.Oracle.Request.fail_t) => msg->factory([])
}

module EditDataSource = {
  let factory = (msg: Msg.Oracle.EditDataSource.t) => [
    {
      title: "Name",
      content: ID(
        <div className={CssHelper.flexBox()}>
          <TypeID.DataSource position=TypeID.Subtitle id={msg.id} />
          <HSpacing size=Spacing.sm />
          <Text value={msg.name} size=Text.Body1 />
        </div>,
      ),
      order: 1,
    },
    {
      title: "Owner",
      content: Address(msg.owner),
      order: 2,
    },
    {
      title: "Treasury",
      content: Address(msg.treasury),
      order: 3,
    },
    {
      title: "Fee",
      content: CoinList(msg.fee),
      order: 4,
    },
  ]
}

module CreateOracleScript = {
  let factory = (msg: Msg.Oracle.CreateOracleScript.t<'a>, firsts) =>
    firsts->Belt.Array.concat([{title: "Owner", content: Address(msg.owner), order: 2}])

  let success = (msg: Msg.Oracle.CreateOracleScript.success_t) =>
    msg->factory([
      {
        title: "ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.OracleScript position=TypeID.Subtitle id={msg.id} />
            <HSpacing size=Spacing.sm />
            <Text value={msg.name} size=Text.Body1 />
          </div>,
        ),
        order: 1,
      },
    ])

  let failed = (msg: Msg.Oracle.CreateOracleScript.fail_t) =>
    msg->factory([
      {
        title: "Name",
        content: PlainText(msg.name),
        order: 1,
      },
    ])
}

module EditOracleScript = {
  let factory = (msg: Msg.Oracle.EditOracleScript.t) => [
    {
      title: "Name",
      content: ID(
        <div className={CssHelper.flexBox()}>
          <TypeID.OracleScript position=TypeID.Subtitle id={msg.id} />
          <HSpacing size=Spacing.sm />
          <Text value={msg.name} size=Text.Body1 />
        </div>,
      ),
      order: 1,
    },
    {
      title: "Owner",
      content: Address(msg.owner),
      order: 2,
    },
  ]
}

module Send = {
  let factory = (msg: Msg.Bank.Send.internal_t) => [
    {
      title: "From",
      content: Address(msg.fromAddress),
      order: 1,
    },
    {
      title: "To",
      content: Address(msg.toAddress),
      order: 2,
    },
    {
      title: "Amount",
      content: CoinList(msg.amount),
      order: 5,
    },
  ]
}

module Report = {
  let factory = (msg: Msg.Oracle.Report.t) => [
    {
      title: "Request ID",
      content: ID(<TypeID.Request position=TypeID.Subtitle id={msg.requestID} />),
      order: 1,
    },
    {
      title: "Validator",
      content: ValidatorAddress(msg.validator),
      order: 2,
    },
    {
      title: "Raw Data Report",
      content: RawReports(msg.rawReports),
      order: 5,
    },
  ]
}

module Grant = {
  let factory = (msg: Msg.Authz.Grant.t) => [
    {
      title: "Granter",
      content: Address(msg.granter),
      order: 1,
    },
    {
      title: "Grantee",
      content: Address(msg.grantee),
      order: 2,
    },
    {
      title: "Authorization URL",
      content: PlainText(msg.url->Belt.Option.getWithDefault("-")),
      order: 4,
    },
    {
      title: "Expiration Date",
      content: Timestamp(msg.expiration),
      order: 5,
    },
  ]
}

module Revoke = {
  let factory = (msg: Msg.Authz.Revoke.t) => [
    {
      title: "Granter",
      content: Address(msg.validator),
      order: 1,
    },
    {
      title: "Grantee",
      content: Address(msg.reporter),
      order: 2,
    },
    {
      title: "Message Type URL",
      content: PlainText(msg.msgTypeUrl),
      order: 3,
    },
  ]
}

// TODO: add more details eg. spend_limit, expiration
module GrantAllowance = {
  let factory = (msg: Msg.FeeGrant.GrantAllowance.t) => [
    {
      title: "Granter",
      content: Address(msg.granter),
      order: 1,
    },
    {
      title: "Grantee",
      content: Address(msg.grantee),
      order: 2,
    },
  ]
}

module RevokeAllowance = {
  let factory = (msg: Msg.FeeGrant.RevokeAllowance.t) => [
    {
      title: "Granter",
      content: Address(msg.granter),
      order: 1,
    },
    {
      title: "Grantee",
      content: Address(msg.grantee),
      order: 2,
    },
  ]
}

module CreateValidator = {
  let factory = (msg: Msg.Staking.CreateValidator.t) => [
    {
      title: "Moniker",
      content: ValidatorLink(msg.validatorAddress, msg.moniker, msg.identity),
      order: 1,
    },
    {
      title: "Identity",
      content: PlainText(msg.identity),
      order: 2,
    },
    {
      title: "Commission Rate",
      content: PlainText(
        (msg.commissionRate *. 100.)->Js.Float.toFixedWithPrecision(~digits=4) ++ "%",
      ),
      order: 3,
    },
    {
      title: "Commission Max Rate",
      content: PlainText(
        (msg.commissionMaxRate *. 100.)->Js.Float.toFixedWithPrecision(~digits=4) ++ "%",
      ),
      order: 4,
    },
    {
      title: "Commission Max Change",
      content: PlainText(
        (msg.commissionMaxChange *. 100.)->Js.Float.toFixedWithPrecision(~digits=4) ++ "%",
      ),
      order: 5,
    },
    {
      title: "Delegator Address",
      content: Address(msg.delegatorAddress),
      order: 6,
    },
    {
      title: "Validator Address",
      content: ValidatorAddress(msg.validatorAddress),
      order: 7,
    },
    {
      title: "Min Self Delegation",
      content: CoinList(list{msg.minSelfDelegation}),
      order: 8,
    },
    {
      title: "Self Delegation",
      content: CoinList(list{msg.selfDelegation}),
      order: 9,
    },
    {
      title: "Details",
      content: PlainText(msg.details),
      order: 10,
    },
    {
      title: "Website",
      content: PlainText(msg.website),
      order: 11,
    },
  ]
}

module EditValidator = {
  let factory = (msg: Msg.Staking.EditValidator.t) => [
    {
      title: "Moniker",
      content: PlainText(msg.moniker == Config.doNotModify ? "Unchanged" : msg.moniker),
      order: 1,
    },
    {
      title: "Identity",
      content: PlainText(msg.identity == Config.doNotModify ? "Unchanged" : msg.identity),
      order: 2,
    },
    {
      title: "Commission Rate",
      content: PlainText(
        switch msg.commissionRate {
        | Some(rate) => (rate *. 100.)->Js.Float.toFixedWithPrecision(~digits=4) ++ "%"
        | None => "Unchanged"
        },
      ),
      order: 3,
    },
    {
      title: "Validator Address",
      content: ValidatorAddress(msg.sender),
      order: 4,
    },
    {
      title: "Min Self Delegation",
      content: {
        switch msg.minSelfDelegation {
        | Some(minSelfDelegation') => CoinList(list{minSelfDelegation'})
        | None => PlainText("Unchanged")
        }
      },
      order: 5,
    },
    {
      title: "Details",
      content: PlainText(msg.details == Config.doNotModify ? "Unchanged" : msg.details),
      order: 6,
    },
    {
      title: "Website",
      content: PlainText(msg.website == Config.doNotModify ? "Unchanged" : msg.website),
      order: 7,
    },
  ]
}

module Delegate = {
  let factory = (msg: Msg.Staking.Delegate.t<'a, 'b>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Delegator Address",
        content: Address(msg.delegatorAddress),
        order: 1,
      },
      {
        title: "Amount",
        content: CoinList(list{msg.amount}),
        order: 3,
      },
    ])

  let success = (msg: Msg.Staking.Delegate.success_t) =>
    msg->factory([
      {
        title: "Validator",
        content: ValidatorLink(msg.validatorAddress, msg.moniker, msg.identity),
        order: 2,
      },
    ])

  let failed = (msg: Msg.Staking.Delegate.fail_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 2,
      },
    ])
}

module Undelegate = {
  let factory = (msg: Msg.Staking.Undelegate.t<'a, 'b>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Delegator Address",
        content: Address(msg.delegatorAddress),
        order: 1,
      },
      {
        title: "Amount",
        content: CoinList(list{msg.amount}),
        order: 3,
      },
    ])

  let success = (msg: Msg.Staking.Undelegate.success_t) =>
    msg->factory([
      {
        title: "Validator",
        content: ValidatorLink(msg.validatorAddress, msg.moniker, msg.identity),
        order: 2,
      },
    ])

  let failed = (msg: Msg.Staking.Undelegate.fail_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 2,
      },
    ])
}

module Redelegate = {
  let factory = (msg: Msg.Staking.Redelegate.t<'a, 'b, 'c, 'd>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Delegator Address",
        content: Address(msg.delegatorAddress),
        order: 1,
      },
      {
        title: "Amount",
        content: CoinList(list{msg.amount}),
        order: 4,
      },
    ])

  let success = (msg: Msg.Staking.Redelegate.success_t) =>
    msg->factory([
      {
        title: "Source Validator Address",
        content: ValidatorLink(msg.validatorSourceAddress, msg.monikerSource, msg.identitySource),
        order: 2,
      },
      {
        title: "Destination Validator Address",
        content: ValidatorLink(
          msg.validatorDestinationAddress,
          msg.monikerDestination,
          msg.identityDestination,
        ),
        order: 3,
      },
    ])

  let failed = (msg: Msg.Staking.Redelegate.fail_t) =>
    msg->factory([
      {
        title: "Source Validator",
        content: ValidatorAddress(msg.validatorSourceAddress),
        order: 2,
      },
      {
        title: "Destination Validator",
        content: ValidatorAddress(msg.validatorDestinationAddress),
        order: 3,
      },
    ])
}

module SetWithdrawAddress = {
  let factory = (msg: Msg.Distribution.SetWithdrawAddress.t) => {
    [
      {
        title: "Delegator Address",
        content: Address(msg.delegatorAddress),
        order: 1,
      },
      {
        title: "Withdraw Address",
        content: Address(msg.withdrawAddress),
        order: 2,
      },
    ]
  }
}

module WithdrawReward = {
  let factory = (msg: Msg.Distribution.WithdrawReward.t<'a, 'b, 'c>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Delegator Address",
        content: Address(msg.delegatorAddress),
        order: 1,
      },
    ])

  let success = (msg: Msg.Distribution.WithdrawReward.success_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorLink(msg.validatorAddress, msg.moniker, msg.identity),
        order: 2,
      },
      {
        title: "Amount",
        content: CoinList(msg.amount),
        order: 3,
      },
    ])

  let failed = (msg: Msg.Distribution.WithdrawReward.fail_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 2,
      },
    ])
}

module WithdrawCommission = {
  let factory = (msg: Msg.Distribution.WithdrawCommission.t<'a, 'b, 'c>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 1,
      },
    ])

  let success = (msg: Msg.Distribution.WithdrawCommission.success_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorLink(msg.validatorAddress, msg.moniker, msg.identity),
        order: 2,
      },
      {
        title: "Amount",
        content: CoinList(msg.amount),
        order: 3,
      },
    ])

  let failed = (msg: Msg.Distribution.WithdrawCommission.fail_t) => msg->factory([])
}

module Unjail = {
  let factory = (msg: Msg.Slashing.Unjail.t) => {
    [
      {
        title: "Validator",
        content: ValidatorAddress(msg.address),
        order: 1,
      },
    ]
  }
}

module SubmitProposal = {
  let factory = (msg: Msg.Gov.SubmitProposal.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {title: "Proposer", content: Address(msg.proposer), order: 1},
      {
        title: "Title",
        content: PlainText(msg.title->Belt.Option.getWithDefault("")),
        order: 3,
      },
      {
        title: "Deposit Amount",
        content: CoinList(msg.initialDeposit),
        order: 4,
      },
    ])

  let success = (msg: Msg.Gov.SubmitProposal.success_t) =>
    msg->factory([
      {
        title: "Proposal ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.Proposal position=TypeID.Subtitle id={msg.proposalID} />
          </div>,
        ),
        order: 2,
      },
    ])

  let failed = (msg: Msg.Gov.SubmitProposal.fail_t) => msg->factory([])
}

module Deposit = {
  let factory = (msg: Msg.Gov.Deposit.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Depositor",
        content: Address(msg.depositor),
        order: 1,
      },
      {
        title: "Amount",
        content: CoinList(msg.amount),
        order: 4,
      },
    ])

  let success = (msg: Msg.Gov.Deposit.success_t) =>
    msg->factory([
      {
        title: "Title",
        content: PlainText(msg.title),
        order: 2,
      },
    ])

  let failed = (msg: Msg.Gov.Deposit.fail_t) =>
    msg->factory([
      {
        title: "Proposal ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.Proposal position=TypeID.Subtitle id={msg.proposalID} />
          </div>,
        ),
        order: 2,
      },
    ])
}

module Vote = {
  let factory = (msg: Msg.Gov.Vote.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Voter",
        content: Address(msg.voterAddress),
        order: 1,
      },
      {
        title: "Proposal ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.Proposal position=TypeID.Subtitle id={msg.proposalID} />
          </div>,
        ),
        order: 2,
      },
      {
        title: "Option",
        content: PlainText(msg.option),
        order: 4,
      },
    ])

  let success = (msg: Msg.Gov.Vote.success_t) =>
    msg->factory([
      {
        title: "Title",
        content: PlainText(msg.title),
        order: 3,
      },
    ])

  let failed = (msg: Msg.Gov.Vote.fail_t) => msg->factory([])
}

module VoteWeighted = {
  let factory = (msg: Msg.Gov.VoteWeighted.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Voter",
        content: Address(msg.voterAddress),
        order: 1,
      },
      {
        title: "Proposal ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.Proposal position=TypeID.Subtitle id={msg.proposalID} />
          </div>,
        ),
        order: 2,
      },
      {
        title: "Option/Weight",
        content: VoteWeighted(msg.options),
        order: 4,
      },
    ])

  let success = (msg: Msg.Gov.VoteWeighted.success_t) =>
    msg->factory([
      {
        title: "Title",
        content: PlainText(msg.title),
        order: 3,
      },
    ])

  let failed = (msg: Msg.Gov.VoteWeighted.fail_t) => msg->factory([])
}

module MultiSend = {
  let factory = (msg: Msg.Bank.MultiSend.t) => [
    {
      title: "From",
      content: MultiSendInputList(msg.inputs),
      order: 1,
    },
    {
      title: "To",
      content: MultiSendOutputList(msg.outputs),
      order: 2,
    },
  ]
}

module RecvPacket = {
  let factory = (msg: Msg.Channel.RecvPacket.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 2,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 3,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 4,
      },
      {
        heading: "Packet",
        title: "",
        content: PlainText(""),
        order: 5,
      },
      {
        title: "Source Port",
        content: PlainText(msg.packet.sourcePort),
        order: 6,
      },
      {
        title: "Destination Port",
        content: PlainText(msg.packet.destinationPort),
        order: 7,
      },
      {
        title: "Source Channel",
        content: PlainText(msg.packet.sourceChannel),
        order: 8,
      },
      {
        title: "Destination Channel",
        content: PlainText(msg.packet.destinationChannel),
        order: 9,
      },
      {
        title: "Data",
        content: PlainText(msg.packet.data),
        order: 10,
      },
      {
        title: "Timeout Timestamp",
        content: Timestamp(msg.packet.timeoutTimestamp),
        order: 11,
      },
    ])

  let success = (msg: Msg.Channel.RecvPacket.success_t) =>
    msg->factory(
      switch msg.packetData {
      | Some(packetData) =>
        switch packetData.packetDetail {
        | OracleRequestPacket(details) => [
            {
              heading: "Packet Data",
              title: "",
              content: PlainText(""),
              order: 12,
            },
            {
              title: "Request ID",
              content: ID(<TypeID.Request position=TypeID.Subtitle id=details.requestID />),
              order: 13,
            },
            {
              title: "Oracle Script",
              content: ID(
                <TypeID.OracleScript position=TypeID.Subtitle id=details.oracleScriptID />,
              ),
              order: 14,
            },
            {
              title: "Prepare Gas",
              content: PlainText(details.prepareGas->Belt.Int.toString),
              order: 15,
            },
            {
              title: "Execute Gas",
              content: PlainText(details.executeGas->Belt.Int.toString),
              order: 16,
            },
            {
              title: "Calldata",
              content: Calldata(details.schema, details.calldata),
              order: 17,
            },
            {
              title: "Request Validator Count",
              content: PlainText(details.askCount->Belt.Int.toString),
              order: 18,
            },
            {
              title: "Sufficient Validator Count",
              content: PlainText(details.minCount->Belt.Int.toString),
              order: 19,
            },
          ]
        | FungibleTokenPacket(details) => [
            {
              heading: "Packet Data",
              title: "",
              content: PlainText(""),
              order: 12,
            },
            {
              title: "Sender",
              content: PlainText(details.sender),
              order: 13,
            },
            {
              title: "Receiver",
              content: PlainText(details.receiver),
              order: 14,
            },
            {
              title: "Amount",
              content: PlainText(details.amount->Belt.Int.toString ++ " " ++ details.denom),
              order: 15,
            },
          ]
        | Unknown => []
        }
      | None => []
      },
    )

  let failed = (msg: Msg.Channel.RecvPacket.fail_t) => msg->factory([])
}

module AcknowledgePacket = {
  let factory = (msg: Msg.Channel.AcknowledgePacket.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 2,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 3,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 4,
      },
      {
        heading: "Packet",
        title: "",
        content: PlainText(""),
        order: 5,
      },
      {
        title: "Source Port",
        content: PlainText(msg.packet.sourcePort),
        order: 6,
      },
      {
        title: "Destination Port",
        content: PlainText(msg.packet.destinationPort),
        order: 7,
      },
      {
        title: "Source Channel",
        content: PlainText(msg.packet.sourceChannel),
        order: 8,
      },
      {
        title: "Destination Channel",
        content: PlainText(msg.packet.destinationChannel),
        order: 9,
      },
      {
        title: "Data",
        content: PlainText(msg.packet.data),
        order: 10,
      },
      {
        title: "Timeout Timestamp",
        content: Timestamp(msg.packet.timeoutTimestamp),
        order: 11,
      },
    ]
  }
}

module Timeout = {
  let factory = (msg: Msg.Channel.Timeout.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 2,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 3,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 4,
      },
      {
        heading: "Packet",
        title: "",
        content: PlainText(""),
        order: 5,
      },
      {
        title: "Source Port",
        content: PlainText(msg.packet.sourcePort),
        order: 6,
      },
      {
        title: "Destination Port",
        content: PlainText(msg.packet.destinationPort),
        order: 7,
      },
      {
        title: "Source Channel",
        content: PlainText(msg.packet.sourceChannel),
        order: 8,
      },
      {
        title: "Destination Channel",
        content: PlainText(msg.packet.destinationChannel),
        order: 9,
      },
      {
        title: "Data",
        content: PlainText(msg.packet.data),
        order: 10,
      },
      {
        title: "Timeout Timestamp",
        content: Timestamp(msg.packet.timeoutTimestamp),
        order: 11,
      },
    ]
  }
}

module CreateClient = {
  let factory = (msg: Msg.Client.Create.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
    ]
  }
}

module Client = {
  let factory = (msg: Msg.Client.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Client ID",
        content: PlainText(msg.clientID),
        order: 2,
      },
    ]
  }
}

module ConnectionOpenInit = {
  let factory = (msg: Msg.Connection.ConnectionOpenInit.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Client ID",
        content: PlainText(msg.clientID),
        order: 2,
      },
      {
        title: "Delay Period",
        content: PlainText(msg.delayPeriod->Belt.Int.toString ++ "ns"),
        order: 3,
      },
      {
        heading: "Counterparty",
        title: "",
        content: PlainText(""),
        order: 4,
      },
      {
        title: "Client ID",
        content: PlainText(msg.counterparty.clientID),
        order: 5,
      },
    ]
  }
}

module ConnectionOpenTry = {
  let factory = (msg: Msg.Connection.ConnectionOpenTry.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Client ID",
        content: PlainText(msg.clientID),
        order: 2,
      },
      {
        title: "Delay Period",
        content: PlainText(msg.delayPeriod->Belt.Int.toString ++ "ns"),
        order: 3,
      },
      {
        title: "Previous Connection ID",
        content: PlainText(msg.previousConnectionID),
        order: 4,
      },
      {
        heading: "Counterparty",
        title: "",
        content: PlainText(""),
        order: 5,
      },
      {
        title: "Client ID",
        content: PlainText(msg.counterparty.clientID),
        order: 6,
      },
      {
        title: "Connection ID",
        content: PlainText(msg.counterparty.connectionID),
        order: 7,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 8,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 9,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 10,
      },
      {
        heading: "Consensus Height",
        title: "",
        content: PlainText(""),
        order: 11,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.consensusHeight.revisionHeight->Belt.Int.toString),
        order: 12,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.consensusHeight.revisionNumber->Belt.Int.toString),
        order: 13,
      },
    ]
  }
}

module ConnectionOpenAck = {
  let factory = (msg: Msg.Connection.ConnectionOpenAck.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Connection ID",
        content: PlainText(msg.connectionID),
        order: 2,
      },
      {
        heading: "Counterparty",
        title: "",
        content: PlainText(""),
        order: 3,
      },
      {
        title: "Connection ID",
        content: PlainText(msg.counterpartyConnectionID),
        order: 4,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 5,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 6,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 7,
      },
      {
        heading: "Consensus Height",
        title: "",
        content: PlainText(""),
        order: 8,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.consensusHeight.revisionHeight->Belt.Int.toString),
        order: 9,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.consensusHeight.revisionNumber->Belt.Int.toString),
        order: 10,
      },
    ]
  }
}

module ConnectionOpenConfirm = {
  let factory = (msg: Msg.Connection.ConnectionOpenConfirm.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Connection ID",
        content: PlainText(msg.connectionID),
        order: 2,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 3,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 4,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 5,
      },
    ]
  }
}

module ChannelOpenInit = {
  let factory = (msg: Msg.Channel.ChannelOpenInit.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Port ID",
        content: PlainText(msg.portID),
        order: 2,
      },
      {
        title: "State",
        content: PlainText(msg.channel.state),
        order: 3,
      },
      {
        title: "Order",
        content: PlainText(msg.channel.ordering),
        order: 4,
      },
      {
        heading: "Counterparty",
        title: "",
        content: PlainText(""),
        order: 5,
      },
      {
        title: "Port ID",
        content: PlainText(msg.channel.counterparty.portID),
        order: 6,
      },
    ]
  }
}

module ChannelOpenTry = {
  let factory = (msg: Msg.Channel.ChannelOpenTry.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Port ID",
        content: PlainText(msg.portID),
        order: 2,
      },
      {
        title: "State",
        content: PlainText(msg.channel.state),
        order: 3,
      },
      {
        title: "Order",
        content: PlainText(msg.channel.ordering),
        order: 4,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 5,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 6,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 7,
      },
      {
        heading: "Counterparty",
        title: "",
        content: PlainText(""),
        order: 8,
      },
      {
        title: "Port ID",
        content: PlainText(msg.channel.counterparty.portID),
        order: 9,
      },
      {
        title: "Channel ID",
        content: PlainText(msg.channel.counterparty.channelID),
        order: 9,
      },
    ]
  }
}

module ChannelOpenAck = {
  let factory = (msg: Msg.Channel.ChannelOpenAck.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Port ID",
        content: PlainText(msg.portID),
        order: 2,
      },
      {
        title: "Channel ID",
        content: PlainText(msg.channelID),
        order: 3,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 4,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 5,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 6,
      },
      {
        heading: "Counterparty",
        title: "",
        content: PlainText(""),
        order: 7,
      },
      {
        title: "Channel ID",
        content: PlainText(msg.counterpartyChannelID),
        order: 8,
      },
    ]
  }
}

module ChannelOpenConfirm = {
  let factory = (msg: Msg.Channel.ChannelOpenConfirm.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Port ID",
        content: PlainText(msg.portID),
        order: 2,
      },
      {
        title: "Channel ID",
        content: PlainText(msg.channelID),
        order: 3,
      },
      {
        heading: "Proof Height",
        title: "",
        content: PlainText(""),
        order: 4,
      },
      {
        title: "Revision Height",
        content: PlainText(msg.proofHeight.revisionHeight->Belt.Int.toString),
        order: 5,
      },
      {
        title: "Revision Number",
        content: PlainText(msg.proofHeight.revisionNumber->Belt.Int.toString),
        order: 6,
      },
    ]
  }
}

module ChannelCloseInit = {
  let factory = (msg: Msg.Channel.ChannelCloseInit.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Port ID",
        content: PlainText(msg.portID),
        order: 2,
      },
      {
        title: "Channel ID",
        content: PlainText(msg.channelID),
        order: 3,
      },
    ]
  }
}

module ChannelCloseConfirm = {
  let factory = (msg: Msg.Channel.ChannelCloseConfirm.t) => {
    [
      {
        title: "Signer",
        content: Address(msg.signer),
        order: 1,
      },
      {
        title: "Port ID",
        content: PlainText(msg.portID),
        order: 2,
      },
      {
        title: "Channel ID",
        content: PlainText(msg.channelID),
        order: 3,
      },
    ]
  }
}

module Activate = {
  let factory = (msg: Msg.Activate.t) => {
    [
      {
        title: "Validator",
        content: Address(msg.validatorAddress),
        order: 1,
      },
    ]
  }
}

module Transfer = {
  let factory = (msg: Msg.Application.Transfer.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Sender",
        content: Address(msg.sender),
        order: 1,
      },
      {
        title: "Receiver",
        content: PlainText(msg.receiver),
        order: 2,
      },
      {
        title: "Source Port",
        content: PlainText(msg.sourcePort),
        order: 3,
      },
      {
        title: "Source Channel",
        content: PlainText(msg.sourceChannel),
        order: 4,
      },
      {
        title: "Timeout Timestamp",
        content: Timestamp(msg.timeoutTimestamp),
        order: 6,
      },
    ])

  let success = (msg: Msg.Application.Transfer.success_t) =>
    msg->factory([
      {
        title: "Token",
        content: CoinList(list{msg.token}),
        order: 5,
      },
    ])

  let failed = (msg: Msg.Application.Transfer.fail_t) => msg->factory([])
}

module SubmitSignals = {
  let factory = (msg: Msg.Feed.SubmitSignals.t) => {
    [
      {
        title: "Validator",
        content: Address(msg.delegator),
        order: 1,
      },
      {
        title: "Signals",
        content: SignalList(msg.signals),
        order: 2,
      },
    ]
  }
}

module SubmitSignalPrices = {
  let factory = (msg: Msg.Feed.SubmitSignalPrices.t) => {
    [
      {
        title: "Validator",
        content: Address(msg.validator),
        order: 1,
      },
      {
        title: "Prices",
        content: SignalPriceList(msg.prices),
        order: 2,
      },
    ]
  }
}

let getContent = msg => {
  switch msg {
  | Msg.CreateDataSourceMsg(m) =>
    switch m {
    | Msg.Oracle.CreateDataSource.Success(data) => CreateDataSource.success(data)
    | Msg.Oracle.CreateDataSource.Failure(data) => CreateDataSource.failed(data)
    }
  | Msg.EditDataSourceMsg(data) => EditDataSource.factory(data)

  | Msg.CreateOracleScriptMsg(m) =>
    switch m {
    | Msg.Oracle.CreateOracleScript.Success(data) => CreateOracleScript.success(data)
    | Msg.Oracle.CreateOracleScript.Failure(data) => CreateOracleScript.failed(data)
    }
  | Msg.EditOracleScriptMsg(data) => EditOracleScript.factory(data)
  | Msg.RequestMsg(m) =>
    switch m {
    | Msg.Oracle.Request.Success(data) => Request.success(data)
    | Msg.Oracle.Request.Failure(data) => Request.failed(data)
    }
  | Msg.SendMsg(data) => Send.factory(data)
  | Msg.ReceiveMsg(data) => Send.factory(data)
  | Msg.ReportMsg(data) => Report.factory(data)
  | Msg.GrantMsg(data) => Grant.factory(data)
  | Msg.RevokeMsg(data) => Revoke.factory(data)
  | Msg.RevokeAllowanceMsg(data) => RevokeAllowance.factory(data)
  | Msg.GrantAllowanceMsg(data) => GrantAllowance.factory(data)
  | Msg.CreateValidatorMsg(data) => CreateValidator.factory(data)
  | Msg.EditValidatorMsg(data) => EditValidator.factory(data)
  | Msg.DelegateMsg(m) =>
    switch m {
    | Msg.Staking.Delegate.Success(data) => Delegate.success(data)
    | Msg.Staking.Delegate.Failure(data) => Delegate.failed(data)
    }
  | Msg.UndelegateMsg(m) =>
    switch m {
    | Msg.Staking.Undelegate.Success(data) => Undelegate.success(data)
    | Msg.Staking.Undelegate.Failure(data) => Undelegate.failed(data)
    }
  | Msg.RedelegateMsg(m) =>
    switch m {
    | Msg.Staking.Redelegate.Success(data) => Redelegate.success(data)
    | Msg.Staking.Redelegate.Failure(data) => Redelegate.failed(data)
    }
  | Msg.WithdrawRewardMsg(m) =>
    switch m {
    | Msg.Distribution.WithdrawReward.Success(data) => WithdrawReward.success(data)
    | Msg.Distribution.WithdrawReward.Failure(data) => WithdrawReward.failed(data)
    }
  | Msg.WithdrawCommissionMsg(m) =>
    switch m {
    | Msg.Distribution.WithdrawCommission.Success(data) => WithdrawCommission.success(data)
    | Msg.Distribution.WithdrawCommission.Failure(data) => WithdrawCommission.failed(data)
    }
  | Msg.UnjailMsg(data) => Unjail.factory(data)
  | Msg.SetWithdrawAddressMsg(data) => SetWithdrawAddress.factory(data)
  | Msg.SubmitSignals(data) => SubmitSignals.factory(data)
  | Msg.SubmitSignalPrices(data) => SubmitSignalPrices.factory(data)
  | Msg.SubmitProposalMsg(m) =>
    switch m {
    | Msg.Gov.SubmitProposal.Success(data) => SubmitProposal.success(data)
    | Msg.Gov.SubmitProposal.Failure(data) => SubmitProposal.failed(data)
    }
  | Msg.DepositMsg(m) =>
    switch m {
    | Msg.Gov.Deposit.Success(data) => Deposit.success(data)
    | Msg.Gov.Deposit.Failure(data) => Deposit.failed(data)
    }
  | Msg.VoteMsg(m) =>
    switch m {
    | Msg.Gov.Vote.Success(data) => Vote.success(data)
    | Msg.Gov.Vote.Failure(data) => Vote.failed(data)
    }
  | Msg.VoteWeightedMsg(m) =>
    switch m {
    | Msg.Gov.VoteWeighted.Success(data) => VoteWeighted.success(data)
    | Msg.Gov.VoteWeighted.Failure(data) => VoteWeighted.failed(data)
    }
  | Msg.CreateClientMsg(data) => CreateClient.factory(data)
  | Msg.UpdateClientMsg(data)
  | Msg.UpgradeClientMsg(data)
  | Msg.SubmitClientMisbehaviourMsg(data) =>
    Client.factory(data)
  | Msg.RecvPacketMsg(m) =>
    switch m {
    | Msg.Channel.RecvPacket.Success(data) => RecvPacket.success(data)
    | Msg.Channel.RecvPacket.Failure(data) => RecvPacket.failed(data)
    }
  | Msg.AcknowledgePacketMsg(data) => AcknowledgePacket.factory(data)
  | Msg.TimeoutMsg(data) => Timeout.factory(data)
  | Msg.TimeoutOnCloseMsg(data) => Timeout.factory(data)
  | Msg.ConnectionOpenInitMsg(data) => ConnectionOpenInit.factory(data)
  | Msg.ConnectionOpenTryMsg(data) => ConnectionOpenTry.factory(data)
  | Msg.ConnectionOpenAckMsg(data) => ConnectionOpenAck.factory(data)
  | Msg.ConnectionOpenConfirmMsg(data) => ConnectionOpenConfirm.factory(data)
  | Msg.ChannelOpenInitMsg(data) => ChannelOpenInit.factory(data)
  | Msg.ChannelOpenTryMsg(data) => ChannelOpenTry.factory(data)
  | Msg.ChannelOpenAckMsg(data) => ChannelOpenAck.factory(data)
  | Msg.ChannelOpenConfirmMsg(data) => ChannelOpenConfirm.factory(data)
  | Msg.ChannelCloseInitMsg(data) => ChannelCloseInit.factory(data)
  | Msg.ChannelCloseConfirmMsg(data) => ChannelCloseConfirm.factory(data)
  | Msg.ActivateMsg(data) => Activate.factory(data)
  | Msg.TransferMsg(m) =>
    switch m {
    | Msg.Application.Transfer.Success(data) => Transfer.success(data)
    | Msg.Application.Transfer.Failure(data) => Transfer.failed(data)
    }
  | Msg.MultiSendMsg(data) => MultiSend.factory(data)
  | Msg.ExecMsg(msg) => [
      {
        title: "Grantee",
        content: Address(msg.grantee),
        order: 1,
      },
      {
        title: "Messages ( " ++ msg.msgs->Belt.List.length->Belt.Int.toString ++ " )",
        content: None,
        order: 2,
      },
      {
        title: "Executed Messages",
        content: ExecList(msg.msgs),
        order: 2,
      },
    ]
  | Msg.UnknownMsg => []
  }
}

module MessageItem = {
  @react.component
  let make = (~title, ~content: content_inner_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <Row marginBottom=0 marginBottomSm=24>
      {switch content {
      | ExecList(msgs) =>
        <Col col=Col.Twelve>
          <div>
            {msgs
            ->Belt.List.toArray
            ->Belt.Array.mapWithIndex((i, msg) => {
              let contents = getContent(msg)
              <div className={Styles.subMsgContainer(theme)} key={i->Belt.Int.toString}>
                <Row marginBottom=0 marginBottomSm=24>
                  <Col col=Col.Three mb=16 mbSm=8>
                    <Heading
                      value="Executed Message"
                      size=Heading.H4
                      weight=Heading.Regular
                      marginBottom=8
                      color=theme.neutral_600
                    />
                  </Col>
                  <Col col=Col.Nine mb=16 mbSm=8>
                    <Text
                      value={
                        let badge = msg->Msg.getBadge
                        badge.name
                      }
                      size=Text.Body1
                      breakAll=true
                    />
                  </Col>
                </Row>
                {contents
                ->Belt.Array.map(c => {
                  <Row marginBottom=0 marginBottomSm=24 key={c.title}>
                    <Col col=Col.Three mb=16 mbSm=8>
                      <Heading
                        value={c.title}
                        size=Heading.H4
                        weight=Heading.Regular
                        marginBottom=8
                        color=theme.neutral_600
                      />
                    </Col>
                    <Col col=Col.Nine mb=16 mbSm=8> {renderValue(c.content)} </Col>
                  </Row>
                })
                ->React.array}
              </div>
            })
            ->React.array}
          </div>
        </Col>

      | _ =>
        <>
          <Col col=Col.Three mb=16 mbSm=8>
            <Heading
              value={title}
              size=Heading.H4
              weight=Heading.Regular
              marginBottom=8
              color=theme.neutral_600
            />
          </Col>
          <Col col=Col.Nine mb=16 mbSm=8> {renderValue(content)} </Col>
        </>
      }}
    </Row>
  }
}

@react.component
let make = (~contents: array<content_t>) => {
  contents
  ->Belt.SortArray.stableSortBy((a, b) => a.order - b.order)
  ->Belt.Array.mapWithIndex((i, {content, title}) => {
    <MessageItem key={i->Belt.Int.toString} title={title} content={content} />
  })
  ->React.array
}
