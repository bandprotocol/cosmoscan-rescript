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
      {Obi.decode(schema, "input", calldata)->Belt.Option.mapWithDefault(failed, calldataKVs =>
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
  | VoteWeighted(Belt.List.t<Msg.Gov.VoteWeighted.Options.t>)
  | MultiSendInputList(Belt.List.t<Msg.Bank.MultiSend.send_tx_t>)
  | MultiSendOutputList(Belt.List.t<Msg.Bank.MultiSend.send_tx_t>)

type content_t = {
  title: string,
  content: content_inner_t,
  order: int,
}

let renderValue = v => {
  switch v {
  | Address(address) => <AddressRender position=AddressRender.Subtitle address />
  | ValidatorAddress(address) =>
    <AddressRender position=AddressRender.Subtitle address accountType={#validator} />
  | PlainText(content) => <Text value={content} size=Text.Body1 />
  | CoinList(amount) => <AmountRender coins={amount} />
  | ID(element) => element
  | Calldata(schema, data) => <Calldata schema calldata=data />
  | RawReports(data) =>
    <KVTable
      headers=["External Id", "Exit Code", "Value"]
      rows={data
      ->Belt.List.toArray
      ->Belt.Array.map(rawReport => [
        KVTable.Value(rawReport.externalDataID->string_of_int),
        KVTable.Value(rawReport.exitCode->string_of_int),
        KVTable.Value(rawReport.data->JsBuffer.toUTF8),
      ])}
    />
  | Timestamp(timestamp) => <Timestamp time={timestamp} size=Text.Body1 />
  | ValidatorLink(address, moniker, identity) =>
    <ValidatorMonikerLink
      validatorAddress={address}
      moniker={moniker}
      identity={identity}
      width={#percent(100.)}
      avatarWidth=20
      size=Text.Body1
    />
  | VoteWeighted(options) =>
    <>
      {options
      ->Belt.List.mapWithIndex((index, {weight, option}) => {
        let optionCount = options->Belt.List.toArray->Belt_Array.length
        let mb = index == optionCount ? 0 : 8

        <div
          key={index->string_of_int ++ weight->Js.Float.toString ++ option}
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
  }
}

module CreateDataSource = {
  let factory = (msg: Msg.Oracle.CreateDataSource.t<'a>, firsts) =>
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
      title: "Reporter",
      content: Address(msg.reporter),
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
      content: PlainText(msg.url),
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

// module RevokeAllowance = {
//   let factory = (msg: Msg.RevokeAllowance.t) => [
//     {
//       title: "Granter",
//       content: Address(msg.granter),
//       order: 1,
//     },
//     {
//       title: "Grantee",
//       content: Address(msg.grantee),
//       order: 2,
//     },
//   ]
// }

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
        content: PlainText(msg.title),
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
  | Msg.MultiSendMsg(data) => MultiSend.factory(data)

  | Msg.UnknownMsg => []
  }
}

@react.component
let make = (~contents: array<content_t>) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  {
    contents
    ->Belt.SortArray.stableSortBy((a, b) => a.order - b.order)
    ->Belt.Array.mapWithIndex((i, content) => {
      <Row key={i->Belt.Int.toString} marginBottom=0 marginBottomSm=24>
        <Col col=Col.Three mb=16 mbSm=8>
          <Heading
            value={content.title}
            size=Heading.H4
            weight=Heading.Regular
            marginBottom=8
            color=theme.neutral_600
          />
        </Col>
        <Col col=Col.Nine mb=16 mbSm=8 key={i->Belt.Int.toString}>
          {renderValue(content.content)}
        </Col>
      </Row>
    })
    ->React.array
  }
}
