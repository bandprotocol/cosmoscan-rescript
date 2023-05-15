type badge_t =
  | SendBadge
  | ReceiveBadge
  | CreateDataSourceBadge
  | EditDataSourceBadge
  | CreateOracleScriptBadge
  | EditOracleScriptBadge
  | RequestBadge
  | ReportBadge
  | AddReporterBadge
  | RemoveReporterBadge
  | CreateValidatorBadge
  | EditValidatorBadge
  | DelegateBadge
  | UndelegateBadge
  | RedelegateBadge
  | WithdrawRewardBadge
  | UnjailBadge
  | SetWithdrawAddressBadge
  | SubmitProposalBadge
  | DepositBadge
  | VoteBadge
  | WithdrawCommissionBadge
  | MultiSendBadge
  | ActivateBadge
  | CreateClientBadge
  | UpdateClientBadge
  | UpgradeClientBadge
  | SubmitClientMisbehaviourBadge
  | ConnectionOpenInitBadge
  | ConnectionOpenTryBadge
  | ConnectionOpenAckBadge
  | ConnectionOpenConfirmBadge
  | ChannelOpenInitBadge
  | ChannelOpenTryBadge
  | ChannelOpenAckBadge
  | ChannelOpenConfirmBadge
  | ChannelCloseInitBadge
  | ChannelCloseConfirmBadge
  | AcknowledgePacketBadge
  | RecvPacketBadge
  | TimeoutBadge
  | TimeoutOnCloseBadge
  | TransferBadge
  | UnknownBadge

type msg_cat_t =
  | TokenMsg
  | ValidatorMsg
  | ProposalMsg
  | DataMsg
  | IBCClientMsg
  | IBCConnectionMsg
  | IBCChannelMsg
  | IBCPacketMsg
  | IBCTransferMsg
  | UnknownMsg

let getBadgeVariantFromString = badge => {
  switch badge {
  | "send" => SendBadge
  | "receive" => raise(Not_found)
  | "create_data_source" => CreateDataSourceBadge
  | "edit_data_source" => EditDataSourceBadge
  | "create_oracle_script" => CreateOracleScriptBadge
  | "edit_oracle_script" => EditOracleScriptBadge
  | "/oracle.v1.MsgRequestData" => RequestBadge
  | "report" => ReportBadge
  | "add_reporter" => AddReporterBadge
  | "remove_reporter" => RemoveReporterBadge
  | "create_validator" => CreateValidatorBadge
  | "edit_validator" => EditValidatorBadge
  | "delegate" => DelegateBadge
  | "begin_unbonding" => UndelegateBadge
  | "begin_redelegate" => RedelegateBadge
  | "withdraw_delegator_reward" => WithdrawRewardBadge
  | "unjail" => UnjailBadge
  | "set_withdraw_address" => SetWithdrawAddressBadge
  | "submit_proposal" => SubmitProposalBadge
  | "deposit" => DepositBadge
  | "vote" => VoteBadge
  | "withdraw_validator_commission" => WithdrawCommissionBadge
  | "multisend" => MultiSendBadge
  | "activate" => ActivateBadge
  | "create_client" => CreateClientBadge
  | "update_client" => UpdateClientBadge
  | "upgrade_client" => UpgradeClientBadge
  | "submit_client_misbehaviour" => SubmitClientMisbehaviourBadge
  | "connection_open_init" => ConnectionOpenInitBadge
  | "connection_open_try" => ConnectionOpenTryBadge
  | "connection_open_ack" => ConnectionOpenAckBadge
  | "connection_open_confirm" => ConnectionOpenConfirmBadge
  | "channel_open_init" => ChannelOpenInitBadge
  | "channel_open_try" => ChannelOpenTryBadge
  | "channel_open_ack" => ChannelOpenAckBadge
  | "channel_open_confirm" => ChannelOpenConfirmBadge
  | "channel_close_init" => ChannelCloseInitBadge
  | "channel_close_confirm" => ChannelCloseConfirmBadge
  | "timeout" => TimeoutBadge
  | "timeout_on_close" => TimeoutOnCloseBadge
  | "recv_packet" => RecvPacketBadge
  | "acknowledge_packet" => AcknowledgePacketBadge
  | "transfer" => TransferBadge
  | _ => UnknownBadge
  }
}

// for handling the empty value
let getDefaultValue = value => value->Belt.Option.getWithDefault(_, "")

module Send = {
  type t = {
    fromAddress: Address.t,
    toAddress: Address.t,
    amount: list<Coin.t>,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      fromAddress: json.required(list{"msg", "from_address"}, address),
      toAddress: json.required(list{"msg", "to_address"}, address),
      amount: json.required(list{"msg", "amount"}, list(Coin.decodeCoin)),
    })
  }
}

module Receive = {
  type t = {
    fromAddress: Address.t,
    toAddress: Address.t,
    amount: list<Coin.t>,
  }
}

module CreateDataSource = {
  type success_t = {
    id: ID.DataSource.t,
    owner: Address.t,
    name: string,
    executable: JsBuffer.t,
    treasury: Address.t,
    fee: list<Coin.t>,
    sender: Address.t,
  }

  type fail_t = {
    owner: Address.t,
    name: string,
    executable: JsBuffer.t,
    treasury: Address.t,
    fee: list<Coin.t>,
    sender: Address.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      id: json.required(list{"msg", "id"}, ID.DataSource.decoder),
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      executable: json.required(list{"msg", "executable"}, string)->JsBuffer.fromBase64,
      treasury: json.required(list{"msg", "treasury"}, address),
      fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
      sender: json.required(list{"msg", "sender"}, address),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      executable: json.required(list{"msg", "executable"}, string)->JsBuffer.fromBase64,
      treasury: json.required(list{"msg", "treasury"}, address),
      fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
      sender: json.required(list{"msg", "sender"}, address),
    })
  }
}

module EditDataSource = {
  type t = {
    id: ID.DataSource.t,
    owner: Address.t,
    name: string,
    executable: JsBuffer.t,
    treasury: Address.t,
    fee: list<Coin.t>,
    sender: Address.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      id: json.required(list{"msg", "data_source_id"}, ID.DataSource.decoder),
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      executable: json.required(list{"msg", "executable"}, string)->JsBuffer.fromBase64,
      treasury: json.required(list{"msg", "treasury"}, address),
      fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
      sender: json.required(list{"msg", "sender"}, address),
    })
  }
}

module CreateOracleScript = {
  type success_t = {
    id: ID.OracleScript.t,
    owner: Address.t,
    name: string,
    code: JsBuffer.t,
    sender: Address.t,
  }

  type fail_t = {
    owner: Address.t,
    name: string,
    code: JsBuffer.t,
    sender: Address.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      id: json.required(list{"msg", "id"}, ID.OracleScript.decoder),
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      code: json.required(list{"msg", "code"}, string)->JsBuffer.fromBase64,
      sender: json.required(list{"msg", "sender"}, address),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      code: json.required(list{"msg", "code"}, string)->JsBuffer.fromBase64,
      sender: json.required(list{"msg", "sender"}, address),
    })
  }
}

module EditOracleScript = {
  type t = {
    id: ID.OracleScript.t,
    owner: Address.t,
    name: string,
    code: JsBuffer.t,
    sender: Address.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      id: json.required(list{"msg", "oracle_script_id"}, ID.OracleScript.decoder),
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      code: json.required(list{"msg", "code"}, string)->JsBuffer.fromBase64,
      sender: json.required(list{"msg", "sender"}, address),
    })
  }
}

module Request = {
  type success_t = {
    id: ID.Request.t,
    oracleScriptID: ID.OracleScript.t,
    oracleScriptName: string,
    calldata: JsBuffer.t,
    askCount: int,
    minCount: int,
    prepareGas: int,
    executeGas: int,
    feeLimit: list<Coin.t>,
    schema: string,
    sender: Address.t,
  }

  type fail_t = {
    oracleScriptID: ID.OracleScript.t,
    calldata: JsBuffer.t,
    askCount: int,
    minCount: int,
    prepareGas: int,
    executeGas: int,
    feeLimit: list<Coin.t>,
    sender: Address.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      id: json.required(list{"msg", "id"}, ID.Request.decoder),
      oracleScriptID: json.required(list{"msg", "oracle_script_id"}, ID.OracleScript.decoder),
      oracleScriptName: json.required(list{"msg", "name"}, string),
      calldata: json.required(list{"msg", "calldata"}, bufferWithDefault),
      askCount: json.required(list{"msg", "ask_count"}, int),
      minCount: json.required(list{"msg", "min_count"}, int),
      prepareGas: json.required(list{"msg", "prepare_gas"}, int),
      executeGas: json.required(list{"msg", "execute_gas"}, int),
      feeLimit: json.required(list{"msg", "fee_limit"}, list(Coin.decodeCoin)),
      schema: json.required(list{"msg", "schema"}, string),
      sender: json.required(list{"msg", "sender"}, address),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      oracleScriptID: json.required(list{"msg", "oracle_script_id"}, ID.OracleScript.decoder),
      calldata: json.required(list{"msg", "calldata"}, bufferWithDefault),
      askCount: json.required(list{"msg", "ask_count"}, int),
      minCount: json.required(list{"msg", "min_count"}, int),
      prepareGas: json.required(list{"msg", "prepare_gas"}, int),
      executeGas: json.required(list{"msg", "execute_gas"}, int),
      feeLimit: json.required(list{"msg", "fee_limit"}, list(Coin.decodeCoin)),
      sender: json.required(list{"msg", "sender"}, address),
    })
  }
}

module RawDataReport = {
  type t = {
    externalDataID: int,
    exitCode: int,
    data: JsBuffer.t,
  }

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      externalDataID: fields.required(. "external_id", intWithDefault(0)),
      exitCode: fields.required(. "exit_code", intWithDefault(0)),
      data: fields.required(. "data", bufferWithDefault),
    })
  }
}

module Report = {
  type t = {
    requestID: ID.Request.t,
    rawReports: list<RawDataReport.t>,
    validator: Address.t,
    reporter: Address.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      requestID: json.required(list{"msg", "request_id"}, ID.Request.decoder),
      rawReports: json.required(list{"msg", "raw_reports"}, list(RawDataReport.decode)),
      validator: json.required(list{"msg", "validator"}, address),
      reporter: json.required(list{"msg", "reporter"}, address),
    })
  }
}

module AddReporter = {
  type success_t = {
    validator: Address.t,
    reporter: Address.t,
    validatorMoniker: string,
  }

  type fail_t = {
    validator: Address.t,
    reporter: Address.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      validator: json.required(list{"msg", "validator"}, address),
      reporter: json.required(list{"msg", "reporter"}, address),
      validatorMoniker: json.required(list{"msg", "validator_moniker"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      validator: json.required(list{"msg", "validator"}, address),
      reporter: json.required(list{"msg", "reporter"}, address),
    })
  }
}

module RemoveReporter = {
  type success_t = {
    validator: Address.t,
    reporter: Address.t,
    validatorMoniker: string,
  }

  type fail_t = {
    validator: Address.t,
    reporter: Address.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      validator: json.required(list{"msg", "validator"}, address),
      reporter: json.required(list{"msg", "reporter"}, address),
      validatorMoniker: json.required(list{"msg", "validator_moniker"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      validator: json.required(list{"msg", "validator"}, address),
      reporter: json.required(list{"msg", "reporter"}, address),
    })
  }
}

module CreateValidator = {
  type t = {
    moniker: string,
    identity: string,
    website: string,
    details: string,
    commissionRate: float,
    commissionMaxRate: float,
    commissionMaxChange: float,
    delegatorAddress: Address.t,
    validatorAddress: Address.t,
    publicKey: PubKey.t,
    minSelfDelegation: Coin.t,
    selfDelegation: Coin.t,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      moniker: json.required(list{"msg", "description", "moniker"}, string),
      identity: json.required(list{"msg", "description", "identity"}, string),
      website: json.required(list{"msg", "description", "website"}, string),
      details: json.required(list{"msg", "description", "details"}, string),
      commissionRate: json.required(list{"msg", "commission", "rate"}, floatstr),
      commissionMaxRate: json.required(list{"msg", "commission", "max_rate"}, floatstr),
      commissionMaxChange: json.required(list{"msg", "commission", "max_change_rate"}, floatstr),
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      publicKey: json.required(list{"msg", "pubkey"}, string)->PubKey.fromBech32,
      minSelfDelegation: json.required(
        list{"msg", "min_self_delegation"},
        floatstr,
      )->Coin.newUBANDFromAmount,
      selfDelegation: json.required(list{"msg", "value"}, Coin.decodeCoin),
    })
  }
}

module EditValidator = {
  type t = {
    moniker: string,
    identity: string,
    website: string,
    details: string,
    commissionRate: option<float>,
    sender: Address.t,
    minSelfDelegation: option<Coin.t>,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      moniker: json.required(list{"msg", "description", "moniker"}, string),
      identity: json.required(list{"msg", "description", "identity"}, string),
      website: json.required(list{"msg", "description", "website"}, string),
      details: json.required(list{"msg", "description", "details"}, string),
      commissionRate: json.required(list{"msg", "commission_rate"}, option(floatstr)),
      sender: json.required(list{"msg", "validator_address"}, address),
      minSelfDelegation: json.required(
        list{"msg", "min_self_delegation"},
        option(floatstr)->map((. a) => a->(Coin.newUBANDFromAmount->Belt.Option.map)),
      ),
    })
  }
}

module Delegate = {
  type success_t = {
    validatorAddress: Address.t,
    delegatorAddress: Address.t,
    amount: Coin.t,
    moniker: string,
    identity: string,
  }
  type fail_t = {
    validatorAddress: Address.t,
    delegatorAddress: Address.t,
    amount: Coin.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
      moniker: json.required(list{"msg", "moniker"}, string),
      identity: json.required(list{"msg", "identity"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
    })
  }
}

module Undelegate = {
  type success_t = {
    validatorAddress: Address.t,
    delegatorAddress: Address.t,
    amount: Coin.t,
    moniker: string,
    identity: string,
  }
  type fail_t = {
    validatorAddress: Address.t,
    delegatorAddress: Address.t,
    amount: Coin.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
      moniker: json.required(list{"msg", "moniker"}, string),
      identity: json.required(list{"msg", "identity"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
    })
  }
}

module Redelegate = {
  type success_t = {
    validatorSourceAddress: Address.t,
    validatorDestinationAddress: Address.t,
    delegatorAddress: Address.t,
    amount: Coin.t,
    monikerSource: string,
    monikerDestination: string,
    identitySource: string,
    identityDestination: string,
  }

  type fail_t = {
    validatorSourceAddress: Address.t,
    validatorDestinationAddress: Address.t,
    delegatorAddress: Address.t,
    amount: Coin.t,
  }
  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      validatorSourceAddress: json.required(
        list{"msg", "validator_src_address"},
        string,
      )->Address.fromBech32,
      validatorDestinationAddress: json.required(
        list{"msg", "validator_dst_address"},
        string,
      )->Address.fromBech32,
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
      monikerSource: json.required(list{"msg", "val_src_moniker"}, string),
      monikerDestination: json.required(list{"msg", "val_dst_moniker"}, string),
      identitySource: json.required(list{"msg", "val_src_identity"}, string),
      identityDestination: json.required(list{"msg", "val_dst_identity"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      validatorSourceAddress: json.required(
        list{"msg", "validator_src_address"},
        string,
      )->Address.fromBech32,
      validatorDestinationAddress: json.required(
        list{"msg", "validator_dst_address"},
        string,
      )->Address.fromBech32,
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
    })
  }
}

module WithdrawReward = {
  type success_t = {
    validatorAddress: Address.t,
    delegatorAddress: Address.t,
    amount: list<Coin.t>,
    moniker: string,
    identity: string,
  }
  type fail_t = {
    validatorAddress: Address.t,
    delegatorAddress: Address.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      amount: json.required(list{"msg", "reward_amount"}, string)->GraphQLParser.coins,
      moniker: json.required(list{"msg", "moniker"}, string),
      identity: json.required(list{"msg", "identity"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
    })
  }
}

module Unjail = {
  type t = {address: Address.t}

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      address: json.required(list{"msg", "validator_address"}, address),
    })
  }
}

module SetWithdrawAddress = {
  type t = {
    delegatorAddress: Address.t,
    withdrawAddress: Address.t,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
      withdrawAddress: json.required(list{"msg", "withdraw_address"}, address),
    })
  }
}

module SubmitProposal = {
  type success_t = {
    proposer: Address.t,
    title: string,
    description: string,
    initialDeposit: list<Coin.t>,
    proposalID: ID.Proposal.t,
  }

  type fail_t = {
    proposer: Address.t,
    title: string,
    description: string,
    initialDeposit: list<Coin.t>,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      proposer: json.required(list{"msg", "proposer"}, address),
      title: json.required(list{"msg", "content", "title"}, string),
      description: json.required(list{"msg", "content", "description"}, string),
      initialDeposit: json.required(list{"msg", "initial_deposit"}, list(Coin.decodeCoin)),
      proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      proposer: json.required(list{"msg", "proposer"}, address),
      title: json.required(list{"msg", "content", "title"}, string),
      description: json.required(list{"msg", "content", "description"}, string),
      initialDeposit: json.required(list{"msg", "initial_deposit"}, list(Coin.decodeCoin)),
    })
  }
}

module Deposit = {
  type success_t = {
    depositor: Address.t,
    proposalID: ID.Proposal.t,
    amount: list<Coin.t>,
    title: string,
  }

  type fail_t = {
    depositor: Address.t,
    proposalID: ID.Proposal.t,
    amount: list<Coin.t>,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      depositor: json.required(list{"msg", "depositor"}, address),
      proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
      amount: json.required(list{"msg", "amount"}, list(Coin.decodeCoin)),
      title: json.required(list{"msg", "title"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      depositor: json.required(list{"msg", "depositor"}, address),
      proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
      amount: json.required(list{"msg", "amount"}, list(Coin.decodeCoin)),
    })
  }
}

module Vote = {
  exception ParseVoteNotMatch
  let parse = vote =>
    switch vote {
    | 0 => "Unspecified"
    | 1 => "Yes"
    | 2 => "Abstain"
    | 3 => "No"
    | 4 => "NoWithVeto"
    | _ => raise(ParseVoteNotMatch)
    }

  type success_t = {
    voterAddress: Address.t,
    proposalID: ID.Proposal.t,
    option: string,
    title: string,
  }

  type fail_t = {
    voterAddress: Address.t,
    proposalID: ID.Proposal.t,
    option: string,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      voterAddress: json.required(list{"msg", "voter"}, address),
      proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
      option: json.required(list{"msg", "option"}, int)->parse,
      title: json.required(list{"msg", "title"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      voterAddress: json.required(list{"msg", "voter"}, address),
      proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
      option: json.required(list{"msg", "option"}, string),
    })
  }
}

module WithdrawCommission = {
  type success_t = {
    validatorAddress: Address.t,
    amount: list<Coin.t>,
    moniker: string,
    identity: string,
  }
  type fail_t = {validatorAddress: Address.t}

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
      amount: json.required(list{"msg", "commission_amount"}, string)->GraphQLParser.coins,
      moniker: json.required(list{"msg", "moniker"}, string),
      identity: json.required(list{"msg", "identity"}, string),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      validatorAddress: json.required(list{"msg", "validator_address"}, address),
    })
  }
}

module MultiSend = {
  type send_tx_t = {
    address: Address.t,
    coins: list<Coin.t>,
  }
  type t = {
    inputs: list<send_tx_t>,
    outputs: list<send_tx_t>,
  }
  let decodeSendTx = {
    open JsonUtils.Decode
    object(fields => {
      address: fields.required(. "address", address),
      coins: fields.required(. "coins", list(Coin.decodeCoin)),
    })
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      inputs: json.required(list{"msg", "inputs"}, list(decodeSendTx)),
      outputs: json.required(list{"msg", "outputs"}, list(decodeSendTx)),
    })
  }
}

module Activate = {
  type t = {validatorAddress: Address.t}

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      validatorAddress: json.required(list{"msg", "validator"}, address),
    })
  }
}

module CreateClient = {
  type t = {signer: Address.t}

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {signer: json.required(list{"msg", "signer"}, address)})
  }
}

module UpdateClient = {
  type t = {
    signer: Address.t,
    clientID: string,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      clientID: json.required(list{"msg", "client_id"}, string),
    })
  }
}

module UpgradeClient = {
  type t = {
    signer: Address.t,
    clientID: string,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      clientID: json.required(list{"msg", "client_id"}, string),
    })
  }
}

module SubmitClientMisbehaviour = {
  type t = {
    signer: Address.t,
    clientID: string,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      clientID: json.required(list{"msg", "client_id"}, string),
    })
  }
}

module Height = {
  type t = {
    revisionHeight: int,
    revisionNumber: int,
  }

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      revisionHeight: fields.required(. "revision_height", int),
      revisionNumber: fields.required(. "revision_number", int),
    })
  }
}

module ConnectionCounterParty = {
  type t = {
    clientID: string,
    connectionID: string,
  }

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      clientID: fields.required(. "client_id", string),
      connectionID: fields.optional(. "connection_id", string)->getDefaultValue,
    })
  }
}

module ConnectionOpenInit = {
  type t = {
    signer: Address.t,
    clientID: string,
    delayPeriod: int,
    counterparty: ConnectionCounterParty.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      clientID: json.required(list{"msg", "client_id"}, string),
      delayPeriod: json.required(list{"msg", "delay_period"}, int),
      counterparty: json.required(list{"msg", "counterparty"}, ConnectionCounterParty.decode),
    })
  }
}

module ConnectionOpenTry = {
  type t = {
    signer: Address.t,
    clientID: string,
    previousConnectionID: string,
    delayPeriod: int,
    counterparty: ConnectionCounterParty.t,
    consensusHeight: Height.t,
    proofHeight: Height.t,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      clientID: json.required(list{"msg", "client_id"}, string),
      previousConnectionID: json.required(list{"msg", "previous_connection_id"}, string),
      delayPeriod: json.required(list{"msg", "delay_period"}, int),
      counterparty: json.required(list{"msg", "counterparty"}, ConnectionCounterParty.decode),
      consensusHeight: json.required(list{"msg", "consensus_height"}, Height.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module ConnectionOpenAck = {
  type t = {
    signer: Address.t,
    connectionID: string,
    counterpartyConnectionID: string,
    consensusHeight: Height.t,
    proofHeight: Height.t,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      connectionID: json.required(list{"msg", "connection_id"}, string),
      counterpartyConnectionID: json.required(list{"msg", "counterparty_connection_id"}, string),
      consensusHeight: json.required(list{"msg", "consensus_height"}, Height.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module ConnectionOpenConfirm = {
  type t = {
    signer: Address.t,
    connectionID: string,
    proofHeight: Height.t,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      connectionID: json.required(list{"msg", "connection_id"}, string),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module ChannelCounterParty = {
  type t = {
    portID: string,
    channelID: string,
  }

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      portID: fields.required(. "port_id", string),
      channelID: fields.optional(. "channel_id", string)->getDefaultValue,
    })
  }
}

let getStateText = state =>
  switch state {
  | 0 => "Uninitialized"
  | 1 => "Init"
  | 2 => "Try Open"
  | 3 => "Open"
  | 4 => "Closed"
  | _ => "Unknown"
  }

let getOrderText = order =>
  switch order {
  | 0 => "None"
  | 1 => "Unordered"
  | 2 => "Ordered"
  | _ => "Unknown"
  }

module Channel = {
  type t = {
    state: string,
    ordering: string,
    counterparty: ChannelCounterParty.t,
  }

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      state: fields.required(. "state", int)->getStateText,
      ordering: fields.required(. "ordering", int)->getOrderText,
      counterparty: fields.required(. "counterparty", ChannelCounterParty.decode),
    })
  }
}

module ChannelOpenInit = {
  type t = {
    signer: Address.t,
    portID: string,
    channel: Channel.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      portID: json.required(list{"msg", "port_id"}, string),
      channel: json.required(list{"msg", "channel"}, Channel.decode),
    })
  }
}

module ChannelOpenTry = {
  type t = {
    signer: Address.t,
    portID: string,
    channel: Channel.t,
    proofHeight: Height.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      portID: json.required(list{"msg", "port_id"}, string),
      channel: json.required(list{"msg", "channel"}, Channel.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module ChannelOpenAck = {
  type t = {
    signer: Address.t,
    portID: string,
    channelID: string,
    counterpartyChannelID: string,
    proofHeight: Height.t,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      portID: json.required(list{"msg", "port_id"}, string),
      channelID: json.required(list{"msg", "channel_id"}, string),
      counterpartyChannelID: json.required(list{"msg", "counterparty_channel_id"}, string),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module ChannelOpenConfirm = {
  type t = {
    signer: Address.t,
    portID: string,
    channelID: string,
    proofHeight: Height.t,
  }
  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      portID: json.required(list{"msg", "port_id"}, string),
      channelID: json.required(list{"msg", "channel_id"}, string),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module ChannelCloseInit = {
  type t = {
    signer: Address.t,
    portID: string,
    channelID: string,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      portID: json.required(list{"msg", "port_id"}, string),
      channelID: json.required(list{"msg", "channel_id"}, string),
    })
  }
}

module ChannelCloseConfirm = {
  type t = {
    signer: Address.t,
    portID: string,
    channelID: string,
    proofHeight: Height.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      portID: json.required(list{"msg", "port_id"}, string),
      channelID: json.required(list{"msg", "channel_id"}, string),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module Packet = {
  type t = {
    sequence: int,
    sourcePort: string,
    sourceChannel: string,
    destinationPort: string,
    destinationChannel: string,
    timeoutHeight: int,
    timeoutTimestamp: MomentRe.Moment.t,
    data: string,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      sequence: json.required(list{"sequence"}, int),
      sourcePort: json.required(list{"source_port"}, string),
      sourceChannel: json.required(list{"source_channel"}, string),
      destinationPort: json.required(list{"destination_port"}, string),
      destinationChannel: json.required(list{"destination_channel"}, string),
      timeoutHeight: json.required(list{"timeout_height", "revision_height"}, int),
      timeoutTimestamp: json.required(list{"timeout_timestamp"}, timeNS),
      data: json.required(list{"data"}, string),
    })
  }
}

module RecvPacket = {
  type success_t = {
    signer: Address.t,
    packet: Packet.t,
    proofHeight: Height.t,
    packetData: PacketDecoder.t,
  }

  type fail_t = {
    signer: Address.t,
    packet: Packet.t,
    proofHeight: Height.t,
  }

  let decodeSuccess = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      packet: json.required(list{"msg", "packet"}, Packet.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
      packetData: json.required(list{}, PacketDecoder.decodeAction),
    })
  }

  let decodeFail = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      packet: json.required(list{"msg", "packet"}, Packet.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module AcknowledgePacket = {
  type t = {
    signer: Address.t,
    packet: Packet.t,
    proofHeight: Height.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      packet: json.required(list{"msg", "packet"}, Packet.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module Timeout = {
  type t = {
    signer: Address.t,
    packet: Packet.t,
    proofHeight: Height.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      packet: json.required(list{"msg", "packet"}, Packet.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module TimeoutOnClose = {
  type t = {
    signer: Address.t,
    packet: Packet.t,
    proofHeight: Height.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      signer: json.required(list{"msg", "signer"}, address),
      packet: json.required(list{"msg", "packet"}, Packet.decode),
      proofHeight: json.required(list{"msg", "proof_height"}, Height.decode),
    })
  }
}

module Transfer = {
  type t = {
    sender: Address.t,
    receiver: string,
    sourcePort: string,
    sourceChannel: string,
    token: Coin.t,
    timeoutHeight: Height.t,
    timeoutTimestamp: MomentRe.Moment.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      sender: json.required(list{"msg", "sender"}, address),
      receiver: json.required(list{"msg", "receiver"}, string),
      sourcePort: json.required(list{"msg", "source_port"}, string),
      sourceChannel: json.required(list{"msg", "source_channel"}, string),
      token: json.required(list{"msg", "token"}, Coin.decodeCoin),
      timeoutHeight: json.required(list{"msg", "timeout_height"}, Height.decode),
      timeoutTimestamp: json.required(list{"msg", "timeout_timestamp"}, timeNS),
    })
  }
}

type decoded_t =
  | SendMsgSuccess(Send.t)
  | SendMsgFail(Send.t)
  | ReceiveMsg(Receive.t)
  | CreateDataSourceMsgSuccess(CreateDataSource.success_t)
  | CreateDataSourceMsgFail(CreateDataSource.fail_t)
  | EditDataSourceMsgSuccess(EditDataSource.t)
  | EditDataSourceMsgFail(EditDataSource.t)
  | CreateOracleScriptMsgSuccess(CreateOracleScript.success_t)
  | CreateOracleScriptMsgFail(CreateOracleScript.fail_t)
  | EditOracleScriptMsgSuccess(EditOracleScript.t)
  | EditOracleScriptMsgFail(EditOracleScript.t)
  | RequestMsgSuccess(Request.success_t)
  | RequestMsgFail(Request.fail_t)
  | ReportMsgSuccess(Report.t)
  | ReportMsgFail(Report.t)
  | AddReporterMsgSuccess(AddReporter.success_t)
  | AddReporterMsgFail(AddReporter.fail_t)
  | RemoveReporterMsgSuccess(RemoveReporter.success_t)
  | RemoveReporterMsgFail(RemoveReporter.fail_t)
  | CreateValidatorMsgSuccess(CreateValidator.t)
  | CreateValidatorMsgFail(CreateValidator.t)
  | EditValidatorMsgSuccess(EditValidator.t)
  | EditValidatorMsgFail(EditValidator.t)
  | DelegateMsgSuccess(Delegate.success_t)
  | DelegateMsgFail(Delegate.fail_t)
  | UndelegateMsgSuccess(Undelegate.success_t)
  | UndelegateMsgFail(Undelegate.fail_t)
  | RedelegateMsgSuccess(Redelegate.success_t)
  | RedelegateMsgFail(Redelegate.fail_t)
  | WithdrawRewardMsgSuccess(WithdrawReward.success_t)
  | WithdrawRewardMsgFail(WithdrawReward.fail_t)
  | UnjailMsgSuccess(Unjail.t)
  | UnjailMsgFail(Unjail.t)
  | SetWithdrawAddressMsgSuccess(SetWithdrawAddress.t)
  | SetWithdrawAddressMsgFail(SetWithdrawAddress.t)
  | SubmitProposalMsgSuccess(SubmitProposal.success_t)
  | SubmitProposalMsgFail(SubmitProposal.fail_t)
  | DepositMsgSuccess(Deposit.success_t)
  | DepositMsgFail(Deposit.fail_t)
  | VoteMsgSuccess(Vote.success_t)
  | VoteMsgFail(Vote.fail_t)
  | WithdrawCommissionMsgSuccess(WithdrawCommission.success_t)
  | WithdrawCommissionMsgFail(WithdrawCommission.fail_t)
  | MultiSendMsgSuccess(MultiSend.t)
  | MultiSendMsgFail(MultiSend.t)
  | ActivateMsgSuccess(Activate.t)
  | ActivateMsgFail(Activate.t)
  // IBC
  | CreateClientMsg(CreateClient.t)
  | UpdateClientMsg(UpdateClient.t)
  | UpgradeClientMsg(UpgradeClient.t)
  | SubmitClientMisbehaviourMsg(SubmitClientMisbehaviour.t)
  | ConnectionOpenInitMsg(ConnectionOpenInit.t)
  | ConnectionOpenTryMsg(ConnectionOpenTry.t)
  | ConnectionOpenAckMsg(ConnectionOpenAck.t)
  | ConnectionOpenConfirmMsg(ConnectionOpenConfirm.t)
  | ChannelOpenInitMsg(ChannelOpenInit.t)
  | ChannelOpenTryMsg(ChannelOpenTry.t)
  | ChannelOpenAckMsg(ChannelOpenAck.t)
  | ChannelOpenConfirmMsg(ChannelOpenConfirm.t)
  | ChannelCloseInitMsg(ChannelCloseInit.t)
  | ChannelCloseConfirmMsg(ChannelCloseConfirm.t)
  | AcknowledgePacketMsg(AcknowledgePacket.t)
  | RecvPacketMsgSuccess(RecvPacket.success_t)
  | RecvPacketMsgFail(RecvPacket.fail_t)
  | TimeoutMsg(Timeout.t)
  | TimeoutOnCloseMsg(TimeoutOnClose.t)
  | TransferMsg(Transfer.t)
  | UnknownMsg

type t = {
  raw: Js.Json.t,
  decoded: decoded_t,
  isIBC: bool,
}

let isIBC = msg =>
  switch msg {
  | SendMsgSuccess(_)
  | SendMsgFail(_)
  | ReceiveMsg(_)
  | CreateDataSourceMsgSuccess(_)
  | CreateDataSourceMsgFail(_)
  | EditDataSourceMsgSuccess(_)
  | EditDataSourceMsgFail(_)
  | CreateOracleScriptMsgSuccess(_)
  | CreateOracleScriptMsgFail(_)
  | EditOracleScriptMsgSuccess(_)
  | EditOracleScriptMsgFail(_)
  | RequestMsgSuccess(_)
  | RequestMsgFail(_)
  | ReportMsgSuccess(_)
  | ReportMsgFail(_)
  | AddReporterMsgSuccess(_)
  | AddReporterMsgFail(_)
  | RemoveReporterMsgSuccess(_)
  | RemoveReporterMsgFail(_)
  | CreateValidatorMsgSuccess(_)
  | CreateValidatorMsgFail(_)
  | EditValidatorMsgSuccess(_)
  | EditValidatorMsgFail(_)
  | DelegateMsgSuccess(_)
  | DelegateMsgFail(_)
  | UndelegateMsgSuccess(_)
  | UndelegateMsgFail(_)
  | RedelegateMsgSuccess(_)
  | RedelegateMsgFail(_)
  | WithdrawRewardMsgSuccess(_)
  | WithdrawRewardMsgFail(_)
  | UnjailMsgSuccess(_)
  | UnjailMsgFail(_)
  | SetWithdrawAddressMsgSuccess(_)
  | SetWithdrawAddressMsgFail(_)
  | SubmitProposalMsgSuccess(_)
  | SubmitProposalMsgFail(_)
  | DepositMsgSuccess(_)
  | DepositMsgFail(_)
  | VoteMsgSuccess(_)
  | VoteMsgFail(_)
  | WithdrawCommissionMsgSuccess(_)
  | WithdrawCommissionMsgFail(_)
  | MultiSendMsgSuccess(_)
  | MultiSendMsgFail(_)
  | ActivateMsgSuccess(_)
  | ActivateMsgFail(_)
  | UnknownMsg => false
  // IBC
  | CreateClientMsg(_)
  | UpdateClientMsg(_)
  | UpgradeClientMsg(_)
  | SubmitClientMisbehaviourMsg(_)
  | ConnectionOpenInitMsg(_)
  | ConnectionOpenTryMsg(_)
  | ConnectionOpenAckMsg(_)
  | ConnectionOpenConfirmMsg(_)
  | ChannelOpenInitMsg(_)
  | ChannelOpenTryMsg(_)
  | ChannelOpenAckMsg(_)
  | ChannelOpenConfirmMsg(_)
  | ChannelCloseInitMsg(_)
  | ChannelCloseConfirmMsg(_)
  | AcknowledgePacketMsg(_)
  | RecvPacketMsgSuccess(_)
  | RecvPacketMsgFail(_)
  | TimeoutMsg(_)
  | TimeoutOnCloseMsg(_)
  | TransferMsg(_) => true
  }

let getCreator = msg => {
  switch msg.decoded {
  | ReceiveMsg(receive) => receive.fromAddress
  | SendMsgSuccess(send)
  | SendMsgFail(send) =>
    send.fromAddress
  | CreateDataSourceMsgSuccess(dataSource) => dataSource.sender
  | CreateDataSourceMsgFail(dataSource) => dataSource.sender
  | EditDataSourceMsgSuccess(dataSource) => dataSource.sender
  | EditDataSourceMsgFail(dataSource) => dataSource.sender
  | CreateOracleScriptMsgSuccess(oracleScript) => oracleScript.sender
  | CreateOracleScriptMsgFail(oracleScript) => oracleScript.sender
  | EditOracleScriptMsgSuccess(oracleScript) => oracleScript.sender
  | EditOracleScriptMsgFail(oracleScript) => oracleScript.sender
  | RequestMsgSuccess(request) => request.sender
  | RequestMsgFail(request) => request.sender
  | ReportMsgSuccess(report)
  | ReportMsgFail(report) =>
    report.reporter
  | AddReporterMsgSuccess(address) => address.validator
  | AddReporterMsgFail(address) => address.validator
  | RemoveReporterMsgSuccess(address) => address.validator
  | RemoveReporterMsgFail(address) => address.validator
  | CreateValidatorMsgSuccess(validator)
  | CreateValidatorMsgFail(validator) =>
    validator.delegatorAddress
  | EditValidatorMsgSuccess(validator)
  | EditValidatorMsgFail(validator) =>
    validator.sender
  | DelegateMsgSuccess(delegation) => delegation.delegatorAddress
  | DelegateMsgFail(delegation) => delegation.delegatorAddress
  | UndelegateMsgSuccess(delegation) => delegation.delegatorAddress
  | UndelegateMsgFail(delegation) => delegation.delegatorAddress
  | RedelegateMsgSuccess(delegation) => delegation.delegatorAddress
  | RedelegateMsgFail(delegation) => delegation.delegatorAddress
  | WithdrawRewardMsgSuccess(withdrawal) => withdrawal.delegatorAddress
  | WithdrawRewardMsgFail(withdrawal) => withdrawal.delegatorAddress
  | UnjailMsgSuccess(validator) => validator.address
  | UnjailMsgFail(validator) => validator.address
  | SetWithdrawAddressMsgSuccess(set)
  | SetWithdrawAddressMsgFail(set) =>
    set.delegatorAddress
  | SubmitProposalMsgSuccess(proposal) => proposal.proposer
  | SubmitProposalMsgFail(proposal) => proposal.proposer
  | DepositMsgSuccess(deposit) => deposit.depositor
  | DepositMsgFail(deposit) => deposit.depositor
  | VoteMsgSuccess(vote) => vote.voterAddress
  | VoteMsgFail(vote) => vote.voterAddress
  | WithdrawCommissionMsgSuccess(withdrawal) => withdrawal.validatorAddress
  | WithdrawCommissionMsgFail(withdrawal) => withdrawal.validatorAddress
  | MultiSendMsgSuccess(tx)
  | MultiSendMsgFail(tx) =>
    let firstInput = tx.inputs->Belt.List.getExn(_, 0)
    firstInput.address
  | ActivateMsgSuccess(activator)
  | ActivateMsgFail(activator) =>
    activator.validatorAddress
  //IBC
  | CreateClientMsg(client) => client.signer
  | UpdateClientMsg(client) => client.signer
  | UpgradeClientMsg(client) => client.signer
  | SubmitClientMisbehaviourMsg(client) => client.signer
  | ConnectionOpenInitMsg(connection) => connection.signer
  | ConnectionOpenTryMsg(connection) => connection.signer
  | ConnectionOpenAckMsg(connection) => connection.signer
  | ConnectionOpenConfirmMsg(connection) => connection.signer
  | ChannelOpenInitMsg(channel) => channel.signer
  | ChannelOpenTryMsg(channel) => channel.signer
  | ChannelOpenAckMsg(channel) => channel.signer
  | ChannelOpenConfirmMsg(channel) => channel.signer
  | ChannelCloseInitMsg(channel) => channel.signer
  | ChannelCloseConfirmMsg(channel) => channel.signer
  | RecvPacketMsgSuccess(packet) => packet.signer
  | RecvPacketMsgFail(packet) => packet.signer
  | AcknowledgePacketMsg(packet) => packet.signer
  | TimeoutMsg(timeout) => timeout.signer
  | TimeoutOnCloseMsg(timeout) => timeout.signer
  | TransferMsg(message) => message.sender
  | _ => ""->Address.fromHex
  }
}

type badge_theme_t = {
  name: string,
  category: msg_cat_t,
}

let getBadge = badgeVariant => {
  switch badgeVariant {
  | SendBadge => {name: "Send", category: TokenMsg}
  | ReceiveBadge => {name: "Receive", category: TokenMsg}
  | CreateDataSourceBadge => {name: "Create Data Source", category: DataMsg}
  | EditDataSourceBadge => {name: "Edit Data Source", category: DataMsg}
  | CreateOracleScriptBadge => {name: "Create Oracle Script", category: DataMsg}
  | EditOracleScriptBadge => {name: "Edit Oracle Script", category: DataMsg}
  | RequestBadge => {name: "Request", category: DataMsg}
  | ReportBadge => {name: "Report", category: DataMsg}
  | AddReporterBadge => {name: "Add Reporter", category: ValidatorMsg}
  | RemoveReporterBadge => {name: "Remove Reporter", category: ValidatorMsg}
  | CreateValidatorBadge => {name: "Create Validator", category: ValidatorMsg}
  | EditValidatorBadge => {name: "Edit Validator", category: ValidatorMsg}
  | DelegateBadge => {name: "Delegate", category: TokenMsg}
  | UndelegateBadge => {name: "Undelegate", category: TokenMsg}
  | RedelegateBadge => {name: "Redelegate", category: TokenMsg}
  | VoteBadge => {name: "Vote", category: ProposalMsg}
  | WithdrawRewardBadge => {name: "Withdraw Reward", category: TokenMsg}
  | UnjailBadge => {name: "Unjail", category: ValidatorMsg}
  | SetWithdrawAddressBadge => {name: "Set Withdraw Address", category: ValidatorMsg}
  | SubmitProposalBadge => {name: "Submit Proposal", category: ProposalMsg}
  | DepositBadge => {name: "Deposit", category: ProposalMsg}
  | WithdrawCommissionBadge => {name: "Withdraw Commission", category: TokenMsg}
  | MultiSendBadge => {name: "Multi Send", category: TokenMsg}
  | ActivateBadge => {name: "Activate", category: ValidatorMsg}
  | UnknownBadge => {name: "Unknown", category: TokenMsg}
  //IBC
  | CreateClientBadge => {name: "Create Client", category: IBCClientMsg}
  | UpdateClientBadge => {name: "Update Client", category: IBCClientMsg}
  | UpgradeClientBadge => {name: "Upgrade Client", category: IBCClientMsg}
  | SubmitClientMisbehaviourBadge => {name: "Submit Client Misbehaviour", category: IBCClientMsg}
  | ConnectionOpenInitBadge => {name: "Connection Open Init", category: IBCConnectionMsg}
  | ConnectionOpenTryBadge => {name: "Connection Open Try", category: IBCConnectionMsg}
  | ConnectionOpenAckBadge => {name: "Connection Open Ack", category: IBCConnectionMsg}
  | ConnectionOpenConfirmBadge => {name: "Connection Open Confirm", category: IBCConnectionMsg}
  | ChannelOpenInitBadge => {name: "Channel Open Init", category: IBCChannelMsg}
  | ChannelOpenTryBadge => {name: "Channel Open Try", category: IBCChannelMsg}
  | ChannelOpenAckBadge => {name: "Channel Open Ack", category: IBCChannelMsg}
  | ChannelOpenConfirmBadge => {name: "Channel Open Confirm", category: IBCChannelMsg}
  | ChannelCloseInitBadge => {name: "Channel Close Init", category: IBCChannelMsg}
  | ChannelCloseConfirmBadge => {name: "Channel Close Confirm", category: IBCPacketMsg}
  | RecvPacketBadge => {name: "Recv Packet", category: IBCPacketMsg}
  | AcknowledgePacketBadge => {name: "Acknowledge Packet", category: IBCPacketMsg}
  | TimeoutBadge => {name: "Timeout", category: IBCPacketMsg}
  | TimeoutOnCloseBadge => {name: "Timeout", category: IBCPacketMsg}
  | TransferBadge => {name: "Transfer", category: IBCTransferMsg}
  }
}

let getBadgeTheme = msg => {
  switch msg.decoded {
  | SendMsgSuccess(_)
  | SendMsgFail(_) =>
    getBadge(SendBadge)
  | ReceiveMsg(_) => getBadge(ReceiveBadge)
  | CreateDataSourceMsgSuccess(_)
  | CreateDataSourceMsgFail(_) =>
    getBadge(CreateDataSourceBadge)
  | EditDataSourceMsgSuccess(_)
  | EditDataSourceMsgFail(_) =>
    getBadge(EditDataSourceBadge)
  | CreateOracleScriptMsgSuccess(_)
  | CreateOracleScriptMsgFail(_) =>
    getBadge(CreateOracleScriptBadge)
  | EditOracleScriptMsgSuccess(_)
  | EditOracleScriptMsgFail(_) =>
    getBadge(EditOracleScriptBadge)
  | RequestMsgSuccess(_)
  | RequestMsgFail(_) =>
    getBadge(RequestBadge)
  | ReportMsgSuccess(_)
  | ReportMsgFail(_) =>
    getBadge(ReportBadge)
  | AddReporterMsgSuccess(_)
  | AddReporterMsgFail(_) =>
    getBadge(AddReporterBadge)
  | RemoveReporterMsgSuccess(_)
  | RemoveReporterMsgFail(_) =>
    getBadge(RemoveReporterBadge)
  | CreateValidatorMsgSuccess(_)
  | CreateValidatorMsgFail(_) =>
    getBadge(CreateValidatorBadge)
  | EditValidatorMsgSuccess(_)
  | EditValidatorMsgFail(_) =>
    getBadge(EditValidatorBadge)
  | DelegateMsgSuccess(_)
  | DelegateMsgFail(_) =>
    getBadge(DelegateBadge)
  | UndelegateMsgSuccess(_)
  | UndelegateMsgFail(_) =>
    getBadge(UndelegateBadge)
  | RedelegateMsgSuccess(_)
  | RedelegateMsgFail(_) =>
    getBadge(RedelegateBadge)
  | VoteMsgSuccess(_)
  | VoteMsgFail(_) =>
    getBadge(VoteBadge)
  | WithdrawRewardMsgSuccess(_)
  | WithdrawRewardMsgFail(_) =>
    getBadge(WithdrawRewardBadge)
  | UnjailMsgSuccess(_)
  | UnjailMsgFail(_) =>
    getBadge(UnjailBadge)
  | SetWithdrawAddressMsgSuccess(_)
  | SetWithdrawAddressMsgFail(_) =>
    getBadge(SetWithdrawAddressBadge)
  | SubmitProposalMsgSuccess(_)
  | SubmitProposalMsgFail(_) =>
    getBadge(SubmitProposalBadge)
  | DepositMsgSuccess(_)
  | DepositMsgFail(_) =>
    getBadge(DepositBadge)
  | WithdrawCommissionMsgSuccess(_)
  | WithdrawCommissionMsgFail(_) =>
    getBadge(WithdrawCommissionBadge)
  | MultiSendMsgSuccess(_) => getBadge(MultiSendBadge)
  | MultiSendMsgFail(_) => getBadge(MultiSendBadge)
  | ActivateMsgSuccess(_) => getBadge(ActivateBadge)
  | ActivateMsgFail(_) => getBadge(ActivateBadge)
  | UnknownMsg => getBadge(UnknownBadge)
  //IBC
  | CreateClientMsg(_) => getBadge(CreateClientBadge)
  | UpdateClientMsg(_) => getBadge(UpdateClientBadge)
  | UpgradeClientMsg(_) => getBadge(UpgradeClientBadge)
  | SubmitClientMisbehaviourMsg(_) => getBadge(SubmitClientMisbehaviourBadge)
  | ConnectionOpenInitMsg(_) => getBadge(ConnectionOpenInitBadge)
  | ConnectionOpenTryMsg(_) => getBadge(ConnectionOpenTryBadge)
  | ConnectionOpenAckMsg(_) => getBadge(ConnectionOpenAckBadge)
  | ConnectionOpenConfirmMsg(_) => getBadge(ConnectionOpenConfirmBadge)
  | ChannelOpenInitMsg(_) => getBadge(ChannelOpenInitBadge)
  | ChannelOpenTryMsg(_) => getBadge(ChannelOpenTryBadge)
  | ChannelOpenAckMsg(_) => getBadge(ChannelOpenAckBadge)
  | ChannelOpenConfirmMsg(_) => getBadge(ChannelOpenConfirmBadge)
  | ChannelCloseInitMsg(_) => getBadge(ChannelCloseInitBadge)
  | ChannelCloseConfirmMsg(_) => getBadge(ChannelCloseConfirmBadge)
  | RecvPacketMsgSuccess(_)
  | RecvPacketMsgFail(_) =>
    getBadge(RecvPacketBadge)
  | AcknowledgePacketMsg(_) => getBadge(AcknowledgePacketBadge)
  | TimeoutMsg(_) => getBadge(TimeoutBadge)
  | TimeoutOnCloseMsg(_) => getBadge(TimeoutOnCloseBadge)
  | TransferMsg(_) => getBadge(TransferBadge)
  }
}

let decodeAction = json => {
  let decoded = {
    open JsonUtils.Decode
    switch json->mustGet("type", string)->getBadgeVariantFromString {
    | SendBadge => SendMsgSuccess(json->mustDecode(Send.decode))
    | ReceiveBadge => raise(Not_found)
    | CreateDataSourceBadge =>
      CreateDataSourceMsgSuccess(json->mustDecode(CreateDataSource.decodeSuccess))
    | EditDataSourceBadge => EditDataSourceMsgSuccess(json->mustDecode(EditDataSource.decode))
    | CreateOracleScriptBadge =>
      CreateOracleScriptMsgSuccess(json->mustDecode(CreateOracleScript.decodeSuccess))
    | EditOracleScriptBadge => EditOracleScriptMsgSuccess(json->mustDecode(EditOracleScript.decode))
    | RequestBadge => RequestMsgSuccess(json->mustDecode(Request.decodeSuccess))
    | ReportBadge => ReportMsgSuccess(json->mustDecode(Report.decode))
    | AddReporterBadge => AddReporterMsgSuccess(json->mustDecode(AddReporter.decodeSuccess))
    | RemoveReporterBadge =>
      RemoveReporterMsgSuccess(json->mustDecode(RemoveReporter.decodeSuccess))
    | CreateValidatorBadge => CreateValidatorMsgSuccess(json->mustDecode(CreateValidator.decode))
    | EditValidatorBadge => EditValidatorMsgSuccess(json->mustDecode(EditValidator.decode))
    | DelegateBadge => DelegateMsgSuccess(json->mustDecode(Delegate.decodeSuccess))
    | UndelegateBadge => UndelegateMsgSuccess(json->mustDecode(Undelegate.decodeSuccess))
    | RedelegateBadge => RedelegateMsgSuccess(json->mustDecode(Redelegate.decodeSuccess))
    | WithdrawRewardBadge =>
      WithdrawRewardMsgSuccess(json->mustDecode(WithdrawReward.decodeSuccess))
    | UnjailBadge => UnjailMsgSuccess(json->mustDecode(Unjail.decode))
    | SetWithdrawAddressBadge =>
      SetWithdrawAddressMsgSuccess(json->mustDecode(SetWithdrawAddress.decode))
    | SubmitProposalBadge =>
      SubmitProposalMsgSuccess(json->mustDecode(SubmitProposal.decodeSuccess))
    | DepositBadge => DepositMsgSuccess(json->mustDecode(Deposit.decodeSuccess))
    | VoteBadge => VoteMsgSuccess(json->mustDecode(Vote.decodeSuccess))
    | WithdrawCommissionBadge =>
      WithdrawCommissionMsgSuccess(json->mustDecode(WithdrawCommission.decodeSuccess))
    | MultiSendBadge => MultiSendMsgSuccess(json->mustDecode(MultiSend.decode))
    | ActivateBadge => ActivateMsgSuccess(json->mustDecode(Activate.decode))
    | UnknownBadge => UnknownMsg
    //IBC
    | CreateClientBadge => CreateClientMsg(json->mustDecode(CreateClient.decode))
    | UpdateClientBadge => UpdateClientMsg(json->mustDecode(UpdateClient.decode))
    | UpgradeClientBadge => UpgradeClientMsg(json->mustDecode(UpgradeClient.decode))
    | SubmitClientMisbehaviourBadge =>
      SubmitClientMisbehaviourMsg(json->mustDecode(SubmitClientMisbehaviour.decode))
    | ConnectionOpenInitBadge => ConnectionOpenInitMsg(json->mustDecode(ConnectionOpenInit.decode))
    | ConnectionOpenTryBadge => ConnectionOpenTryMsg(json->mustDecode(ConnectionOpenTry.decode))
    | ConnectionOpenAckBadge => ConnectionOpenAckMsg(json->mustDecode(ConnectionOpenAck.decode))
    | ConnectionOpenConfirmBadge =>
      ConnectionOpenConfirmMsg(json->mustDecode(ConnectionOpenConfirm.decode))
    | ChannelOpenInitBadge => ChannelOpenInitMsg(json->mustDecode(ChannelOpenInit.decode))
    | ChannelOpenTryBadge => ChannelOpenTryMsg(json->mustDecode(ChannelOpenTry.decode))
    | ChannelOpenAckBadge => ChannelOpenAckMsg(json->mustDecode(ChannelOpenAck.decode))
    | ChannelOpenConfirmBadge => ChannelOpenConfirmMsg(json->mustDecode(ChannelOpenConfirm.decode))
    | ChannelCloseInitBadge => ChannelCloseInitMsg(json->mustDecode(ChannelCloseInit.decode))
    | ChannelCloseConfirmBadge =>
      ChannelCloseConfirmMsg(json->mustDecode(ChannelCloseConfirm.decode))
    | RecvPacketBadge => RecvPacketMsgSuccess(json->mustDecode(RecvPacket.decodeSuccess))
    | AcknowledgePacketBadge => AcknowledgePacketMsg(json->mustDecode(AcknowledgePacket.decode))
    | TimeoutBadge => TimeoutMsg(json->mustDecode(Timeout.decode))
    | TimeoutOnCloseBadge => TimeoutOnCloseMsg(json->mustDecode(TimeoutOnClose.decode))
    | TransferBadge => TransferMsg(json->mustDecode(Transfer.decode))
    }
  }
  {raw: json, decoded, isIBC: decoded->isIBC}
}

let decodeFailAction = json => {
  let decoded = {
    open JsonUtils.Decode
    switch json->mustGet("type", string)->getBadgeVariantFromString {
    | SendBadge => SendMsgFail(json->mustDecode(Send.decode))
    | ReceiveBadge => raise(Not_found)
    | CreateDataSourceBadge =>
      CreateDataSourceMsgFail(json->mustDecode(CreateDataSource.decodeFail))
    | EditDataSourceBadge => EditDataSourceMsgFail(json->mustDecode(EditDataSource.decode))
    | CreateOracleScriptBadge =>
      CreateOracleScriptMsgFail(json->mustDecode(CreateOracleScript.decodeFail))
    | EditOracleScriptBadge => EditOracleScriptMsgFail(json->mustDecode(EditOracleScript.decode))
    | RequestBadge => RequestMsgFail(json->mustDecode(Request.decodeFail))
    | ReportBadge => ReportMsgFail(json->mustDecode(Report.decode))
    | AddReporterBadge => AddReporterMsgFail(json->mustDecode(AddReporter.decodeFail))
    | RemoveReporterBadge => RemoveReporterMsgFail(json->mustDecode(RemoveReporter.decodeFail))
    | CreateValidatorBadge => CreateValidatorMsgFail(json->mustDecode(CreateValidator.decode))
    | EditValidatorBadge => EditValidatorMsgFail(json->mustDecode(EditValidator.decode))
    | DelegateBadge => DelegateMsgFail(json->mustDecode(Delegate.decodeFail))
    | UndelegateBadge => UndelegateMsgFail(json->mustDecode(Undelegate.decodeFail))
    | RedelegateBadge => RedelegateMsgFail(json->mustDecode(Redelegate.decodeFail))
    | WithdrawRewardBadge => WithdrawRewardMsgFail(json->mustDecode(WithdrawReward.decodeFail))
    | UnjailBadge => UnjailMsgFail(json->mustDecode(Unjail.decode))
    | SetWithdrawAddressBadge =>
      SetWithdrawAddressMsgFail(json->mustDecode(SetWithdrawAddress.decode))
    | SubmitProposalBadge => SubmitProposalMsgFail(json->mustDecode(SubmitProposal.decodeFail))
    | DepositBadge => DepositMsgFail(json->mustDecode(Deposit.decodeFail))
    | VoteBadge => VoteMsgFail(json->mustDecode(Vote.decodeFail))
    | WithdrawCommissionBadge =>
      WithdrawCommissionMsgFail(json->mustDecode(WithdrawCommission.decodeFail))
    | MultiSendBadge => MultiSendMsgFail(json->mustDecode(MultiSend.decode))
    | ActivateBadge => ActivateMsgFail(json->mustDecode(Activate.decode))
    | UnknownBadge => UnknownMsg
    //IBC
    | CreateClientBadge => CreateClientMsg(json->mustDecode(CreateClient.decode))
    | UpdateClientBadge => UpdateClientMsg(json->mustDecode(UpdateClient.decode))
    | UpgradeClientBadge => UpgradeClientMsg(json->mustDecode(UpgradeClient.decode))
    | SubmitClientMisbehaviourBadge =>
      SubmitClientMisbehaviourMsg(json->mustDecode(SubmitClientMisbehaviour.decode))
    | ConnectionOpenInitBadge => ConnectionOpenInitMsg(json->mustDecode(ConnectionOpenInit.decode))
    | ConnectionOpenTryBadge => ConnectionOpenTryMsg(json->mustDecode(ConnectionOpenTry.decode))
    | ConnectionOpenAckBadge => ConnectionOpenAckMsg(json->mustDecode(ConnectionOpenAck.decode))
    | ConnectionOpenConfirmBadge =>
      ConnectionOpenConfirmMsg(json->mustDecode(ConnectionOpenConfirm.decode))
    | ChannelOpenInitBadge => ChannelOpenInitMsg(json->mustDecode(ChannelOpenInit.decode))
    | ChannelOpenTryBadge => ChannelOpenTryMsg(json->mustDecode(ChannelOpenTry.decode))
    | ChannelOpenAckBadge => ChannelOpenAckMsg(json->mustDecode(ChannelOpenAck.decode))
    | ChannelOpenConfirmBadge => ChannelOpenConfirmMsg(json->mustDecode(ChannelOpenConfirm.decode))
    | ChannelCloseInitBadge => ChannelCloseInitMsg(json->mustDecode(ChannelCloseInit.decode))
    | ChannelCloseConfirmBadge =>
      ChannelCloseConfirmMsg(json->mustDecode(ChannelCloseConfirm.decode))
    | RecvPacketBadge => RecvPacketMsgFail(json->mustDecode(RecvPacket.decodeFail))
    | AcknowledgePacketBadge => AcknowledgePacketMsg(json->mustDecode(AcknowledgePacket.decode))
    | TimeoutBadge => TimeoutMsg(json->mustDecode(Timeout.decode))
    | TimeoutOnCloseBadge => TimeoutOnCloseMsg(json->mustDecode(TimeoutOnClose.decode))
    | TransferBadge => TransferMsg(json->mustDecode(Transfer.decode))
    }
  }
  {raw: json, decoded, isIBC: decoded->isIBC}
}
