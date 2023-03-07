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
  | RawReports(Belt.List.t<Msg.RawDataReport.t>)
  | Timestamp(MomentRe.Moment.t)
  | ValidatorLink(Address.t, string, string)
  | VoteWeighted(Belt.List.t<Msg.VoteWeighted.option_t>)

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
  }
}

module CreateDataSource = {
  let factory = (msg: Msg.CreateDataSource.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {title: "Owner", content: Address(msg.owner), order: 2},
      {title: "Treasury", content: Address(msg.treasury), order: 3},
      {title: "Fee", content: CoinList(msg.fee), order: 4},
    ])

  let success = (msg: Msg.CreateDataSource.success_t) =>
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

  let failed = (msg: Msg.CreateDataSource.fail_t) =>
    msg->factory([
      {
        title: "Name",
        content: PlainText(msg.name),
        order: 1,
      },
    ])
}

module Request = {
  let factory = (msg: Msg.Request.t<'a, 'b, 'c>, firsts) =>
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

  let success = (msg: Msg.Request.success_t) =>
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

  let failed = (msg: Msg.Request.fail_t) => msg->factory([])
}

module EditDataSource = {
  let factory = (msg: Msg.EditDataSource.t) => [
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
  let factory = (msg: Msg.CreateOracleScript.t<'a>, firsts) =>
    firsts->Belt.Array.concat([{title: "Owner", content: Address(msg.owner), order: 2}])

  let success = (msg: Msg.CreateOracleScript.success_t) =>
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

  let failed = (msg: Msg.CreateOracleScript.fail_t) =>
    msg->factory([
      {
        title: "Name",
        content: PlainText(msg.name),
        order: 1,
      },
    ])
}

module EditOracleScript = {
  let factory = (msg: Msg.EditOracleScript.t) => [
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
  let factory = (msg: Msg.Send.t) => [
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
  let factory = (msg: Msg.Report.t) => [
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
  let factory = (msg: Msg.Grant.t) => [
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
      title: "Authorization URL",
      content: PlainText({
        switch msg.url {
        | Some(url) => url
        | None => "-"
        }
      }),
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
  let factory = (msg: Msg.Revoke.t) => [
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

module RevokeAllowance = {
  let factory = (msg: Msg.RevokeAllowance.t) => [
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
  let factory = (msg: Msg.CreateValidator.t) => [
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
  let factory = (msg: Msg.EditValidator.t) => [
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
  let factory = (msg: Msg.Delegate.t<'a, 'b>, firsts) =>
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

  let success = (msg: Msg.Delegate.success_t) =>
    msg->factory([
      {
        title: "Validator",
        content: ValidatorLink(msg.validatorAddress, msg.moniker, msg.identity),
        order: 2,
      },
    ])

  let failed = (msg: Msg.Delegate.fail_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 2,
      },
    ])
}

module Undelegate = {
  let factory = (msg: Msg.Undelegate.t<'a, 'b>, firsts) =>
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

  let success = (msg: Msg.Undelegate.success_t) =>
    msg->factory([
      {
        title: "Validator",
        content: ValidatorLink(msg.validatorAddress, msg.moniker, msg.identity),
        order: 2,
      },
    ])

  let failed = (msg: Msg.Undelegate.fail_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 2,
      },
    ])
}

module Redelegate = {
  let factory = (msg: Msg.Redelegate.t<'a, 'b, 'c, 'd>, firsts) =>
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

  let success = (msg: Msg.Redelegate.success_t) =>
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

  let failed = (msg: Msg.Redelegate.fail_t) =>
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

module WithdrawReward = {
  let factory = (msg: Msg.WithdrawReward.t<'a, 'b, 'c>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Delegator Address",
        content: Address(msg.delegatorAddress),
        order: 1,
      },
    ])

  let success = (msg: Msg.WithdrawReward.success_t) =>
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

  let failed = (msg: Msg.WithdrawReward.fail_t) =>
    msg->factory([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 2,
      },
    ])
}

module WithdrawCommission = {
  let factory = (msg: Msg.WithdrawCommission.t<'a, 'b, 'c>, firsts) =>
    firsts->Belt.Array.concat([
      {
        title: "Validator Address",
        content: ValidatorAddress(msg.validatorAddress),
        order: 1,
      },
    ])

  let success = (msg: Msg.WithdrawCommission.success_t) =>
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

  let failed = (msg: Msg.WithdrawCommission.fail_t) => msg->factory([])
}

module Unjail = {
  let factory = (msg: Msg.Unjail.t) => {
    [
      {
        title: "Validator",
        content: ValidatorAddress(msg.address),
        order: 1,
      },
    ]
  }
}

module SetWithdrawAddress = {
  let factory = (msg: Msg.SetWithdrawAddress.t) => {
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

module SubmitProposal = {
  let factory = (msg: Msg.SubmitProposal.t<'a>, firsts) =>
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

  let success = (msg: Msg.SubmitProposal.success_t) =>
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

  let failed = (msg: Msg.SubmitProposal.fail_t) => msg->factory([])
}

module Deposit = {
  let factory = (msg: Msg.Deposit.t<'a>, firsts) =>
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

  let success = (msg: Msg.Deposit.success_t) =>
    msg->factory([
      {
        title: "Title",
        content: PlainText(msg.title),
        order: 2,
      },
    ])

  let failed = (msg: Msg.Deposit.fail_t) =>
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
  let factory = (msg: Msg.Vote.t<'a>, firsts) =>
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

  let success = (msg: Msg.Vote.success_t) =>
    msg->factory([
      {
        title: "Title",
        content: PlainText(msg.title),
        order: 3,
      },
    ])

  let failed = (msg: Msg.Vote.fail_t) => msg->factory([])
}

module VoteWeighted = {
  let factory = (msg: Msg.VoteWeighted.t<'a>, firsts) =>
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

  let success = (msg: Msg.VoteWeighted.success_t) =>
    msg->factory([
      {
        title: "Title",
        content: PlainText(msg.title),
        order: 3,
      },
    ])

  let failed = (msg: Msg.VoteWeighted.fail_t) => msg->factory([])
}

module UpdateClient = {
  let factory = (msg: Msg.UpdateClient.t) => {
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

let getContent = msg => {
  switch msg {
  | Msg.CreateDataSourceMsg(m) =>
    switch m {
    | Msg.CreateDataSource.Success(data) => CreateDataSource.success(data)
    | Msg.CreateDataSource.Failure(data) => CreateDataSource.failed(data)
    }
  | Msg.EditDataSourceMsg(data) => EditDataSource.factory(data)

  | Msg.CreateOracleScriptMsg(m) =>
    switch m {
    | Msg.CreateOracleScript.Success(data) => CreateOracleScript.success(data)
    | Msg.CreateOracleScript.Failure(data) => CreateOracleScript.failed(data)
    }
  | Msg.EditOracleScriptMsg(data) => EditOracleScript.factory(data)
  | Msg.RequestMsg(m) =>
    switch m {
    | Msg.Request.Success(data) => Request.success(data)
    | Msg.Request.Failure(data) => Request.failed(data)
    }
  | Msg.SendMsg(data) => Send.factory(data)
  | Msg.ReportMsg(data) => Report.factory(data)
  | Msg.GrantMsg(data) => Grant.factory(data)
  | Msg.RevokeMsg(data) => Revoke.factory(data)
  | Msg.RevokeAllowanceMsg(data) => RevokeAllowance.factory(data)
  | Msg.CreateValidatorMsg(data) => CreateValidator.factory(data)
  | Msg.EditValidatorMsg(data) => EditValidator.factory(data)
  | Msg.DelegateMsg(m) =>
    switch m {
    | Msg.Delegate.Success(data) => Delegate.success(data)
    | Msg.Delegate.Failure(data) => Delegate.failed(data)
    }
  | Msg.UndelegateMsg(m) =>
    switch m {
    | Msg.Undelegate.Success(data) => Undelegate.success(data)
    | Msg.Undelegate.Failure(data) => Undelegate.failed(data)
    }
  | Msg.RedelegateMsg(m) =>
    switch m {
    | Msg.Redelegate.Success(data) => Redelegate.success(data)
    | Msg.Redelegate.Failure(data) => Redelegate.failed(data)
    }
  | Msg.WithdrawRewardMsg(m) =>
    switch m {
    | Msg.WithdrawReward.Success(data) => WithdrawReward.success(data)
    | Msg.WithdrawReward.Failure(data) => WithdrawReward.failed(data)
    }
  | Msg.WithdrawCommissionMsg(m) =>
    switch m {
    | Msg.WithdrawCommission.Success(data) => WithdrawCommission.success(data)
    | Msg.WithdrawCommission.Failure(data) => WithdrawCommission.failed(data)
    }
  | Msg.UnjailMsg(data) => Unjail.factory(data)
  | Msg.SetWithdrawAddressMsg(data) => SetWithdrawAddress.factory(data)
  | Msg.SubmitProposalMsg(m) =>
    switch m {
    | Msg.SubmitProposal.Success(data) => SubmitProposal.success(data)
    | Msg.SubmitProposal.Failure(data) => SubmitProposal.failed(data)
    }
  | Msg.DepositMsg(m) =>
    switch m {
    | Msg.Deposit.Success(data) => Deposit.success(data)
    | Msg.Deposit.Failure(data) => Deposit.failed(data)
    }
  | Msg.VoteMsg(m) =>
    switch m {
    | Msg.Vote.Success(data) => Vote.success(data)
    | Msg.Vote.Failure(data) => Vote.failed(data)
    }
  | Msg.VoteWeightedMsg(m) =>
    switch m {
    | Msg.VoteWeighted.Success(data) => VoteWeighted.success(data)
    | Msg.VoteWeighted.Failure(data) => VoteWeighted.failed(data)
    }
  | Msg.UpdateClientMsg(data) => UpdateClient.factory(data)
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
        <Col col=Col.Four mb=16 mbSm=8>
          <Heading
            value={content.title}
            size=Heading.H4
            weight=Heading.Regular
            marginBottom=8
            color=theme.neutral_600
          />
        </Col>
        <Col col=Col.Eight mb=16 mbSm=8 key={i->Belt.Int.toString}>
          {renderValue(content.content)}
        </Col>
      </Row>
    })
    ->React.array
  }
}
