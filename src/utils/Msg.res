module Bank = {
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
      buildObject(json => {
        address: json.required(list{"address"}, address),
        coins: json.required(list{"coins"}, list(Coin.decodeCoin)),
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
}

module Oracle = {
  module CreateDataSource = {
    type internal_t<'a> = {
      owner: Address.t,
      name: string,
      executable: JsBuffer.t,
      treasury: Address.t,
      fee: list<Coin.t>,
      sender: Address.t,
      id: 'a,
    }

    type fail_t = internal_t<unit>
    type success_t = internal_t<ID.DataSource.t>

    type t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = idDecoder => {
      open JsonUtils.Decode
      buildObject(json => {
        owner: json.required(list{"msg", "owner"}, address),
        name: json.required(list{"msg", "name"}, string),
        executable: json.required(list{"msg", "executable"}, bufferFromBase64),
        treasury: json.required(list{"msg", "treasury"}, address),
        fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
        sender: json.required(list{"msg", "sender"}, address),
        id: json->idDecoder,
      })
    }

    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = decodeFactory(json =>
      json.required(list{"msg", "id"}, ID.DataSource.decoder)
    )
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
        executable: json.required(list{"msg", "executable"}, bufferFromBase64),
        treasury: json.required(list{"msg", "treasury"}, address),
        fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
        sender: json.required(list{"msg", "sender"}, address),
      })
    }
  }

  module CreateOracleScript = {
    type t<'a> = {
      owner: Address.t,
      name: string,
      code: JsBuffer.t,
      sender: Address.t,
      id: 'a,
    }

    type fail_t = t<unit>
    type success_t = t<ID.OracleScript.t>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = idDecoder => {
      open JsonUtils.Decode
      buildObject(json => {
        owner: json.required(list{"msg", "owner"}, address),
        name: json.required(list{"msg", "name"}, string),
        code: json.required(list{"msg", "code"}, bufferFromBase64),
        sender: json.required(list{"msg", "sender"}, address),
        id: json->idDecoder,
      })
    }
    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = decodeFactory(json =>
      json.required(list{"msg", "id"}, ID.OracleScript.decoder)
    )
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
        code: json.required(list{"msg", "code"}, bufferFromBase64),
        sender: json.required(list{"msg", "sender"}, address),
      })
    }
  }

  module Request = {
    type t<'a, 'b, 'c> = {
      oracleScriptID: ID.OracleScript.t,
      calldata: JsBuffer.t,
      askCount: int,
      minCount: int,
      prepareGas: int,
      executeGas: int,
      feeLimit: list<Coin.t>,
      sender: Address.t,
      id: 'a,
      oracleScriptName: 'b,
      schema: 'c,
    }

    type fail_t = t<unit, unit, unit>
    type success_t = t<ID.Request.t, string, string>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = (decoderID, decoderString, decoderSchema) => {
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
        id: json->decoderID,
        oracleScriptName: json->decoderString,
        schema: json->decoderSchema,
      })
    }

    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => (), _ => (), _ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(
        json => json.required(list{"msg", "id"}, ID.Request.decoder),
        json => json.required(list{"msg", "name"}, string),
        json => json.required(list{"msg", "schema"}, string),
      )
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
      buildObject(json => {
        externalDataID: json.optional(list{"external_id"}, int)->Belt.Option.getWithDefault(0),
        exitCode: json.optional(list{"exit_code"}, int)->Belt.Option.getWithDefault(0),
        data: json.required(list{"data"}, bufferWithDefault),
      })
    }
  }

  module Report = {
    type t = {
      requestID: ID.Request.t,
      rawReports: list<RawDataReport.t>,
      validator: Address.t,
    }

    let decode = {
      open JsonUtils.Decode
      buildObject(json => {
        requestID: json.required(list{"msg", "request_id"}, ID.Request.decoder),
        rawReports: json.required(list{"msg", "raw_reports"}, list(RawDataReport.decode)),
        validator: json.required(list{"msg", "validator"}, address),
      })
    }
  }
}

// Authz
module Authz = {
  module Grant = {
    type t = {
      granter: Address.t,
      grantee: Address.t,
      url: string,
      expiration: MomentRe.Moment.t,
      msgTypeUrl: string,
    }

    let decode = {
      open JsonUtils.Decode
      buildObject(json => {
        granter: json.required(list{"msg", "granter"}, address),
        grantee: json.required(list{"msg", "grantee"}, address),
        url: json.required(list{"msg", "url"}, string),
        expiration: json.required(list{"msg", "grant", "expiration"}, GraphQLParser.timeString),
        msgTypeUrl: json.required(list{"msg", "grant", "authorization", "msg"}, string),
      })
    }
  }

  module Revoke = {
    type t = {
      validator: Address.t,
      reporter: Address.t,
      msgTypeUrl: string,
    }

    let decode = {
      open JsonUtils.Decode
      buildObject(json => {
        validator: json.required(list{"msg", "granter"}, address),
        reporter: json.required(list{"msg", "grantee"}, address),
        msgTypeUrl: json.required(list{"msg", "msg_type_url"}, string),
      })
    }
  }

  module Exec = {
    type t<'a> = {
      grantee: Address.t,
      msgs: list<'a>,
    }
  }
}

module FeeGrant = {
  module BasicAllowance = {
    type t = {
      spendLimit: list<Coin.t>,
      expiration: option<MomentRe.Moment.t>,
    }

    let decoder = {
      open JsonUtils.Decode
      buildObject(json => {
        spendLimit: json.required(list{"spend_limit"}, list(Coin.decodeCoin)),
        expiration: json.optional(list{"expiration"}, moment),
      })
    }
  }

  module PeriodicAllowance = {
    type t = {
      basic: BasicAllowance.t,
      period: MomentRe.Moment.t,
      periodSpendLimit: list<Coin.t>,
      periodCanSpend: list<Coin.t>,
      periodReset: MomentRe.Moment.t,
    }

    let decoder = {
      open JsonUtils.Decode
      buildObject(json => {
        basic: json.required(list{"basic"}, BasicAllowance.decoder),
        period: json.required(list{"period"}, moment),
        periodSpendLimit: json.required(list{"period_spend_limit"}, list(Coin.decodeCoin)),
        periodCanSpend: json.required(list{"period_can_spend"}, list(Coin.decodeCoin)),
        periodReset: json.required(list{"period_reset"}, moment),
      })
    }
  }

  module Allowance = {
    type t =
      | BasicAllowance(BasicAllowance.t)
      | PeriodicAllowance(PeriodicAllowance.t)
      | UnknownMsg

    let decoder = {
      open JsonUtils.Decode
      buildObject(json => {
        let allowance = json.required(list{"type"}, string)
        switch allowance {
        | "/cosmos.feegrant.v1beta1.BasicAllowance" => {
            let allowance = json.required(list{"allowance"}, BasicAllowance.decoder)
            BasicAllowance(allowance)
          }

        | "/cosmos.feegrant.v1beta1.PeriodicAllowance" => {
            let allowance = json.required(list{"allowance"}, PeriodicAllowance.decoder)
            PeriodicAllowance(allowance)
          }

        | _ => UnknownMsg
        }
      })
    }
  }

  module GrantAllowance = {
    type t = {
      grantee: Address.t,
      granter: Address.t,
      allowance: Allowance.t,
      allowedMessages: list<string>,
    }

    let decode = {
      open JsonUtils.Decode
      buildObject(json => {
        granter: json.required(list{"msg", "granter"}, address),
        grantee: json.required(list{"msg", "grantee"}, address),
        allowance: json.required(list{"msg", "allowance"}, Allowance.decoder),
        allowedMessages: json.required(list{"msg", "allowance", "allowed_messages"}, list(string)),
      })
    }
  }

  module RevokeAllowance = {
    type t = {
      granter: Address.t,
      grantee: Address.t,
    }

    let decode = {
      open JsonUtils.Decode
      buildObject(json => {
        granter: json.required(list{"msg", "granter"}, string)->Address.fromBech32,
        grantee: json.required(list{"msg", "grantee"}, string)->Address.fromBech32,
      })
    }
  }
}

module Staking = {
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
        commissionRate: json.optional(list{"msg", "commission_rate"}, floatstr),
        sender: json.required(list{"msg", "validator_address"}, address),
        minSelfDelegation: json.optional(list{"msg", "min_self_delegation"}, Coin.decodeCoin),
      })
    }
  }

  module Delegate = {
    type t<'a, 'b> = {
      validatorAddress: Address.t,
      delegatorAddress: Address.t,
      amount: Coin.t,
      moniker: 'a,
      identity: 'b,
    }

    type fail_t = t<unit, unit>
    type success_t = t<string, string>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = (monikerDecoder, identityDecoder) => {
      open JsonUtils.Decode
      buildObject(json => {
        delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
        validatorAddress: json.required(list{"msg", "validator_address"}, address),
        amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
        moniker: json->monikerDecoder,
        identity: json->identityDecoder,
      })
    }
    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => (), _ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(
        json => json.required(list{"msg", "moniker"}, string),
        json => json.required(list{"msg", "identity"}, string),
      )
    }
  }

  module Undelegate = {
    type t<'a, 'b> = {
      validatorAddress: Address.t,
      delegatorAddress: Address.t,
      amount: Coin.t,
      moniker: 'a,
      identity: 'b,
    }

    type fail_t = t<unit, unit>
    type success_t = t<string, string>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = (monikerDecoder, identityDecoder) => {
      open JsonUtils.Decode
      buildObject(json => {
        delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
        validatorAddress: json.required(list{"msg", "validator_address"}, address),
        amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
        moniker: json->monikerDecoder,
        identity: json->identityDecoder,
      })
    }
    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => (), _ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(
        json => json.required(list{"msg", "moniker"}, string),
        json => json.required(list{"msg", "identity"}, string),
      )
    }
  }

  module Redelegate = {
    type t<'a, 'b, 'c, 'd> = {
      validatorSourceAddress: Address.t,
      validatorDestinationAddress: Address.t,
      delegatorAddress: Address.t,
      amount: Coin.t,
      monikerSource: 'a,
      monikerDestination: 'b,
      identitySource: 'c,
      identityDestination: 'd,
    }

    type fail_t = t<unit, unit, unit, unit>
    type success_t = t<string, string, string, string>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = (monikerSourceD, monikerDestD, identityD, identityDestD) => {
      open JsonUtils.Decode
      buildObject(json => {
        validatorSourceAddress: json.required(list{"msg", "validator_src_address"}, address),
        validatorDestinationAddress: json.required(list{"msg", "validator_dst_address"}, address),
        delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
        amount: json.required(list{"msg", "amount"}, Coin.decodeCoin),
        monikerSource: json->monikerSourceD,
        monikerDestination: json->monikerDestD,
        identitySource: json->identityD,
        identityDestination: json->identityDestD,
      })
    }
    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => (), _ => (), _ => (), _ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(
        json => json.required(list{"msg", "val_src_moniker"}, string),
        json => json.required(list{"msg", "val_dst_moniker"}, string),
        json => json.required(list{"msg", "val_src_identity"}, string),
        json => json.required(list{"msg", "val_dst_identity"}, string),
      )
    }
  }
}

module Distribution = {
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
  module WithdrawReward = {
    type t<'a, 'b, 'c> = {
      validatorAddress: Address.t,
      delegatorAddress: Address.t,
      amount: 'a,
      moniker: 'b,
      identity: 'c,
    }

    type fail_t = t<unit, unit, unit>
    type success_t = t<list<Coin.t>, string, string>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = (amountD, monikerD, identityD) => {
      open JsonUtils.Decode
      buildObject(json => {
        validatorAddress: json.required(list{"msg", "validator_address"}, address),
        delegatorAddress: json.required(list{"msg", "delegator_address"}, address),
        amount: json->amountD,
        moniker: json->monikerD,
        identity: json->identityD,
      })
    }
    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => (), _ => (), _ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(
        json => json.required(list{"msg", "reward_amount"}, string)->GraphQLParser.coins,
        json => json.required(list{"msg", "moniker"}, string),
        json => json.required(list{"msg", "identity"}, string),
      )
    }
  }

  module WithdrawCommission = {
    type t<'a, 'b, 'c> = {
      validatorAddress: Address.t,
      amount: 'a,
      moniker: 'b,
      identity: 'c,
    }

    type fail_t = t<unit, unit, unit>
    type success_t = t<list<Coin.t>, string, string>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = (amountD, monikerD, identityD) => {
      open JsonUtils.Decode
      buildObject(json => {
        validatorAddress: json.required(list{"msg", "validator_address"}, address),
        amount: json->amountD,
        moniker: json->monikerD,
        identity: json->identityD,
      })
    }
    let decodeFail: JsonUtils.Decode.t<fail_t> = decodeFactory(_ => (), _ => (), _ => ())
    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(
        json => json.required(list{"msg", "commission_amount"}, string)->GraphQLParser.coins,
        json => json.required(list{"msg", "moniker"}, string),
        json => json.required(list{"msg", "identity"}, string),
      )
    }
  }
}

module Slashing = {
  module Unjail = {
    type t = {address: Address.t}

    let decode = {
      open JsonUtils.Decode
      buildObject(json => {
        address: json.required(list{"msg", "validator_address"}, address),
      })
    }
  }
}

module Gov = {
  module SubmitProposal = {
    type t<'a> = {
      proposer: Address.t,
      title: string,
      description: string,
      initialDeposit: list<Coin.t>,
      proposalID: 'a,
    }

    type success_t = t<ID.Proposal.t>
    type fail_t = t<unit>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = proposalIDD => {
      open JsonUtils.Decode
      buildObject(json => {
        proposer: json.required(list{"msg", "proposer"}, address),
        title: json.required(list{"msg", "content", "title"}, string),
        description: json.required(list{"msg", "content", "description"}, string),
        initialDeposit: json.required(list{"msg", "initial_deposit"}, list(Coin.decodeCoin)),
        proposalID: json->proposalIDD,
      })
    }

    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(json => json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder))
    }

    let decodeFail: JsonUtils.Decode.t<fail_t> = {
      open JsonUtils.Decode
      decodeFactory(_ => ())
    }
  }

  module Deposit = {
    type t<'a> = {
      depositor: Address.t,
      proposalID: ID.Proposal.t,
      amount: list<Coin.t>,
      title: 'a,
    }

    type success_t = t<string>
    type fail_t = t<unit>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = titleD => {
      open JsonUtils.Decode
      buildObject(json => {
        depositor: json.required(list{"msg", "depositor"}, address),
        proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
        amount: json.required(list{"msg", "amount"}, list(Coin.decodeCoin)),
        title: json->titleD,
      })
    }

    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(json => json.required(list{"msg", "title"}, string))
    }

    let decodeFail: JsonUtils.Decode.t<fail_t> = {
      open JsonUtils.Decode
      decodeFactory(_ => ())
    }
  }

  module Vote = {
    exception ParseVoteNotMatch
    let parse = vote => {
      switch vote {
      | 0 => "Unspecified"
      | 1 => "Yes"
      | 2 => "Abstain"
      | 3 => "No"
      | 4 => "NoWithVeto"
      | _ => raise(ParseVoteNotMatch)
      }
    }

    type t<'a> = {
      voterAddress: Address.t,
      proposalID: ID.Proposal.t,
      option: string,
      title: 'a,
    }

    type success_t = t<string>
    type fail_t = t<unit>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = titleD => {
      open JsonUtils.Decode
      buildObject(json => {
        voterAddress: json.required(list{"msg", "voter"}, address),
        proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
        option: json.required(list{"msg", "option"}, int)->parse,
        title: json->titleD,
      })
    }

    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(json => json.required(list{"msg", "title"}, string))
    }

    let decodeFail: JsonUtils.Decode.t<fail_t> = {
      open JsonUtils.Decode
      decodeFactory(_ => ())
    }
  }

  module VoteWeighted = {
    module Options = {
      type t = {
        option: string,
        weight: float,
      }

      let decoder = {
        open JsonUtils.Decode
        buildObject(json => {
          option: json.required(list{"option"}, int)->Vote.parse,
          weight: json.required(list{"weight"}, floatstr),
        })
      }
    }

    type t<'a> = {
      voterAddress: Address.t,
      proposalID: ID.Proposal.t,
      options: list<Options.t>,
      title: 'a,
    }

    type success_t = t<string>
    type fail_t = t<unit>

    type decoded_t =
      | Success(success_t)
      | Failure(fail_t)

    let decodeFactory = titleD => {
      open JsonUtils.Decode
      buildObject(json => {
        voterAddress: json.required(list{"msg", "voter"}, address),
        proposalID: json.required(list{"msg", "proposal_id"}, ID.Proposal.decoder),
        options: json.required(list{"msg", "options"}, list(Options.decoder)),
        title: json->titleD,
      })
    }

    let decodeSuccess: JsonUtils.Decode.t<success_t> = {
      open JsonUtils.Decode
      decodeFactory(json => json.required(list{"msg", "title"}, string))
    }

    let decodeFail: JsonUtils.Decode.t<fail_t> = {
      open JsonUtils.Decode
      decodeFactory(_ => ())
    }
  }
}

type rec msg_t =
  | SendMsg(Bank.Send.t)
  | MultiSendMsg(Bank.MultiSend.t)
  | CreateDataSourceMsg(Oracle.CreateDataSource.t)
  | EditDataSourceMsg(Oracle.EditDataSource.t)
  | CreateOracleScriptMsg(Oracle.CreateOracleScript.decoded_t)
  | EditOracleScriptMsg(Oracle.EditOracleScript.t)
  | RequestMsg(Oracle.Request.decoded_t)
  | ReportMsg(Oracle.Report.t)
  | GrantMsg(Authz.Grant.t)
  | RevokeMsg(Authz.Revoke.t)
  | GrantAllowanceMsg(FeeGrant.GrantAllowance.t)
  | RevokeAllowanceMsg(FeeGrant.RevokeAllowance.t)
  | CreateValidatorMsg(Staking.CreateValidator.t)
  | EditValidatorMsg(Staking.EditValidator.t)
  | DelegateMsg(Staking.Delegate.decoded_t)
  | UndelegateMsg(Staking.Undelegate.decoded_t)
  | RedelegateMsg(Staking.Redelegate.decoded_t)
  | WithdrawRewardMsg(Distribution.WithdrawReward.decoded_t)
  | WithdrawCommissionMsg(Distribution.WithdrawCommission.decoded_t)
  | SetWithdrawAddressMsg(Distribution.SetWithdrawAddress.t)
  | UnjailMsg(Slashing.Unjail.t)
  | SubmitProposalMsg(Gov.SubmitProposal.decoded_t)
  | DepositMsg(Gov.Deposit.decoded_t)
  | VoteMsg(Gov.Vote.decoded_t)
  | VoteWeightedMsg(Gov.VoteWeighted.decoded_t)
  | ExecMsg(Authz.Exec.t<msg_t>)
  | UnknownMsg

type t = {
  raw: Js.Json.t,
  decoded: msg_t,
  sender: Address.t,
  isIBC: bool,
}

type msg_cat_t =
  | TokenMsg
  | ValidatorMsg
  | ProposalMsg
  | OracleMsg
  | IBCMsg
  | UnknownMsg

type badge_theme_t = {
  name: string,
  category: msg_cat_t,
}

let getBadge = msg => {
  switch msg {
  | SendMsg(_) => {name: "Send", category: TokenMsg}
  | MultiSendMsg(_) => {name: "Multi Send", category: TokenMsg}
  | CreateDataSourceMsg(_) => {name: "Create Data Source", category: OracleMsg}
  | EditDataSourceMsg(_) => {name: "Edit Data Source", category: OracleMsg}
  | CreateOracleScriptMsg(_) => {name: "Create Oracle Script", category: OracleMsg}
  | EditOracleScriptMsg(_) => {name: "Edit Oracle Script", category: OracleMsg}
  | RequestMsg(_) => {name: "Request", category: OracleMsg}
  | ReportMsg(_) => {name: "Report", category: OracleMsg}
  | GrantMsg(_) => {name: "Grant", category: ValidatorMsg}
  | RevokeMsg(_) => {name: "Revoke", category: ValidatorMsg}
  | RevokeAllowanceMsg(_) => {name: "Revoke Allowance", category: ValidatorMsg}
  | GrantAllowanceMsg(_) => {name: "Grant Allowance", category: ValidatorMsg}
  | CreateValidatorMsg(_) => {name: "Create Validator", category: ValidatorMsg}
  | EditValidatorMsg(_) => {name: "Edit Validator", category: ValidatorMsg}
  | DelegateMsg(_) => {name: "Delegate", category: TokenMsg}
  | UndelegateMsg(_) => {name: "Undelegate", category: TokenMsg}
  | RedelegateMsg(_) => {name: "Redelegate", category: TokenMsg}
  | WithdrawRewardMsg(_) => {name: "Withdraw Reward", category: TokenMsg}
  | WithdrawCommissionMsg(_) => {name: "Withdraw Commission", category: TokenMsg}
  | UnjailMsg(_) => {name: "Unjail", category: ValidatorMsg}
  | SetWithdrawAddressMsg(_) => {name: "Set Withdraw Address", category: ValidatorMsg}
  | SubmitProposalMsg(_) => {name: "Submit Proposal", category: ProposalMsg}
  | DepositMsg(_) => {name: "Deposit", category: ProposalMsg}
  | VoteMsg(_) => {name: "Vote", category: ProposalMsg}
  | VoteWeightedMsg(_) => {name: "Vote Weighted", category: ProposalMsg}
  | ExecMsg(_) => {name: "Exec", category: ValidatorMsg}
  | _ => {name: "Unknown msg", category: UnknownMsg}
  }
}

let rec decodeMsg = (json, isSuccess) => {
  let (decoded, sender, isIBC) = {
    open JsonUtils.Decode
    switch json->mustGet("type", string) {
    | "/cosmos.bank.v1beta1.MsgSend" => {
        let msg = json->mustDecode(Bank.Send.decode)
        (SendMsg(msg), msg.fromAddress, false)
      }

    | "/cosmos.bank.v1beta1.MsgMultiSend" =>
      let msg = json->mustDecode(Bank.MultiSend.decode)
      (MultiSendMsg(msg), Belt.List.getExn(msg.inputs, 0).address, false)

    | "/oracle.v1.MsgCreateDataSource" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Oracle.CreateDataSource.decodeSuccess)
            (CreateDataSourceMsg(Success(msg)), msg.sender, false)
          }
        : {
            let msg = json->mustDecode(Oracle.CreateDataSource.decodeFail)
            (CreateDataSourceMsg(Failure(msg)), msg.sender, false)
          }

    | "/oracle.v1.MsgEditDataSource" =>
      let msg = json->mustDecode(Oracle.EditDataSource.decode)
      (EditDataSourceMsg(msg), msg.sender, false)
    | "/oracle.v1.MsgCreateOracleScript" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Oracle.CreateOracleScript.decodeSuccess)
            (CreateOracleScriptMsg(Success(msg)), msg.sender, false)
          }
        : {
            let msg = json->mustDecode(Oracle.CreateOracleScript.decodeFail)
            (CreateOracleScriptMsg(Failure(msg)), msg.sender, false)
          }

    | "/oracle.v1.MsgEditOracleScript" =>
      let msg = json->mustDecode(Oracle.EditOracleScript.decode)
      (EditOracleScriptMsg(msg), msg.sender, false)

    | "/oracle.v1.MsgRequestData" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Oracle.Request.decodeSuccess)
            (RequestMsg(Success(msg)), msg.sender, false)
          }
        : {
            let msg = json->mustDecode(Oracle.Request.decodeFail)
            (RequestMsg(Failure(msg)), msg.sender, false)
          }

    | "/oracle.v1.MsgReportData" =>
      let msg = json->mustDecode(Oracle.Report.decode)
      (ReportMsg(msg), msg.validator, false)
    | "/cosmos.authz.v1beta1.MsgGrant" =>
      let msg = json->mustDecode(Authz.Grant.decode)
      (GrantMsg(msg), msg.granter, false)
    | "/cosmos.authz.v1beta1.MsgRevoke" =>
      let msg = json->mustDecode(Authz.Revoke.decode)
      (RevokeMsg(msg), msg.validator, false)
    | "/cosmos.feegrant.v1beta1.MsgGrantAllowance" =>
      let msg = json->mustDecode(FeeGrant.GrantAllowance.decode)
      (GrantAllowanceMsg(msg), msg.granter, false)
    | "/cosmos.feegrant.v1beta1.MsgRevokeAllowance" =>
      let msg = json->mustDecode(FeeGrant.RevokeAllowance.decode)
      (RevokeAllowanceMsg(msg), msg.granter, false)
    | "/cosmos.staking.v1beta1.MsgCreateValidator" =>
      let msg = json->mustDecode(Staking.CreateValidator.decode)
      (CreateValidatorMsg(msg), msg.delegatorAddress, false)
    | "/cosmos.staking.v1beta1.MsgEditValidator" =>
      let msg = json->mustDecode(Staking.EditValidator.decode)
      (EditValidatorMsg(msg), msg.sender, false)
    | "/cosmos.staking.v1beta1.MsgDelegate" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Staking.Delegate.decodeSuccess)
            (DelegateMsg(Success(msg)), msg.delegatorAddress, false)
          }
        : {
            let msg = json->mustDecode(Staking.Delegate.decodeFail)
            (DelegateMsg(Failure(msg)), msg.delegatorAddress, false)
          }

    | "/cosmos.staking.v1beta1.MsgUndelegate" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Staking.Undelegate.decodeSuccess)
            (UndelegateMsg(Success(msg)), msg.delegatorAddress, false)
          }
        : {
            let msg = json->mustDecode(Staking.Undelegate.decodeFail)
            (UndelegateMsg(Failure(msg)), msg.delegatorAddress, false)
          }

    | "/cosmos.staking.v1beta1.MsgBeginRedelegate" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Staking.Redelegate.decodeSuccess)
            (RedelegateMsg(Success(msg)), msg.delegatorAddress, false)
          }
        : {
            let msg = json->mustDecode(Staking.Redelegate.decodeFail)
            (RedelegateMsg(Failure(msg)), msg.delegatorAddress, false)
          }

    | "/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Distribution.WithdrawReward.decodeSuccess)
            (WithdrawRewardMsg(Success(msg)), msg.delegatorAddress, false)
          }
        : {
            let msg = json->mustDecode(Distribution.WithdrawReward.decodeFail)
            (WithdrawRewardMsg(Failure(msg)), msg.delegatorAddress, false)
          }

    | "/cosmos.distribution.v1beta1.MsgWithdrawValidatorCommission" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Distribution.WithdrawCommission.decodeSuccess)
            (WithdrawCommissionMsg(Success(msg)), msg.validatorAddress, false)
          }
        : {
            let msg = json->mustDecode(Distribution.WithdrawCommission.decodeFail)
            (WithdrawCommissionMsg(Failure(msg)), msg.validatorAddress, false)
          }

    | "/cosmos.distribution.v1beta1.MsgSetWithdrawAddress" =>
      let msg = json->mustDecode(Distribution.SetWithdrawAddress.decode)
      (SetWithdrawAddressMsg(msg), msg.delegatorAddress, false)
    | "/cosmos.slashing.v1beta1.MsgUnjail" =>
      let msg = json->mustDecode(Slashing.Unjail.decode)
      (UnjailMsg(msg), msg.address, false)

    | "/cosmos.gov.v1beta1.MsgSubmitProposal" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Gov.SubmitProposal.decodeSuccess)
            (SubmitProposalMsg(Success(msg)), msg.proposer, false)
          }
        : {
            let msg = json->mustDecode(Gov.SubmitProposal.decodeFail)
            (SubmitProposalMsg(Failure(msg)), msg.proposer, false)
          }

    | "/cosmos.gov.v1beta1.MsgDeposit" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Gov.Deposit.decodeSuccess)
            (DepositMsg(Success(msg)), msg.depositor, false)
          }
        : {
            let msg = json->mustDecode(Gov.Deposit.decodeFail)
            (DepositMsg(Failure(msg)), msg.depositor, false)
          }

    | "/cosmos.gov.v1beta1.MsgVote" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Gov.Vote.decodeSuccess)
            (VoteMsg(Success(msg)), msg.voterAddress, false)
          }
        : {
            let msg = json->mustDecode(Gov.Vote.decodeFail)
            (VoteMsg(Failure(msg)), msg.voterAddress, false)
          }

    | "/cosmos.gov.v1beta1.MsgVoteWeighted" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Gov.VoteWeighted.decodeSuccess)
            (VoteWeightedMsg(Success(msg)), msg.voterAddress, false)
          }
        : {
            let msg = json->mustDecode(Gov.VoteWeighted.decodeFail)
            (VoteWeightedMsg(Failure(msg)), msg.voterAddress, false)
          }

    | "/cosmos.authz.v1beta1.MsgExec" =>
      let msg = json->mustDecode(decodeExecMsg(isSuccess))
      (ExecMsg(msg), msg.grantee, false)
    | _ => (UnknownMsg, Address.Address(""), false)
    }
  }
  {raw: json, decoded, sender, isIBC}
}
and decodeExecMsg = isSuccess => {
  open JsonUtils.Decode
  let f: fd_type => Authz.Exec.t<msg_t> = json => {
    grantee: json.required(list{"msg", "grantee"}, address),
    msgs: json.required(
      list{"msg", "msgs"},
      list(custom((. json) => decodeMsg(json, isSuccess).decoded)),
    ),
  }
  buildObject(f)
}
