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

module CreateDataSource = {
  type t<'a> = {
    owner: Address.t,
    name: string,
    executable: JsBuffer.t,
    treasury: Address.t,
    fee: list<Coin.t>,
    sender: Address.t,
    id: 'a,
  }

  type failed_t = t<unit>
  type success_t = t<ID.DataSource.t>

  type decoded_t =
    | Success(success_t)
    | Failure(failed_t)

  let decodeFactory = idDecoder => {
    open JsonUtils.Decode
    buildObject(json => {
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      executable: json.required(list{"msg", "executable"}, bufferWithDefault),
      treasury: json.required(list{"msg", "treasury"}, address),
      fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
      sender: json.required(list{"msg", "sender"}, address),
      id: json->idDecoder,
    })
  }
  let decodeFail: JsonUtils.Decode.t<failed_t> = decodeFactory(_ => ())
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
      owner: json.required(list{"msg", "owner"}, string)->Address.fromBech32,
      name: json.required(list{"msg", "name"}, string),
      executable: json.required(list{"msg", "executable"}, string)->JsBuffer.fromBase64,
      treasury: json.required(list{"msg", "treasury"}, string)->Address.fromBech32,
      fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
      sender: json.required(list{"msg", "sender"}, string)->Address.fromBech32,
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

  type failed_t = t<unit>
  type success_t = t<ID.OracleScript.t>

  type decoded_t =
    | Success(success_t)
    | Failure(failed_t)

  let decodeFactory = idDecoder => {
    open JsonUtils.Decode
    buildObject(json => {
      owner: json.required(list{"msg", "owner"}, string)->Address.fromBech32,
      name: json.required(list{"msg", "name"}, string),
      code: json.required(list{"msg", "code"}, string)->JsBuffer.fromBase64,
      sender: json.required(list{"msg", "sender"}, string)->Address.fromBech32,
      id: json->idDecoder,
    })
  }
  let decodeFail: JsonUtils.Decode.t<failed_t> = decodeFactory(_ => ())
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
      owner: json.required(list{"msg", "owner"}, string)->Address.fromBech32,
      name: json.required(list{"msg", "name"}, string),
      code: json.required(list{"msg", "code"}, string)->JsBuffer.fromBase64,
      sender: json.required(list{"msg", "sender"}, string)->Address.fromBech32,
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

  type failed_t = t<unit, unit, unit>
  type success_t = t<ID.Request.t, string, string>

  type decoded_t =
    | Success(success_t)
    | Failure(failed_t)

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

  let decodeFail: JsonUtils.Decode.t<failed_t> = decodeFactory(_ => (), _ => (), _ => ())
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
      externalDataID: json.required(list{"msg", "external_id"}, int),
      exitCode: json.required(list{"msg", "exit_code"}, int),
      data: json.required(list{"msg", "data"}, bufferWithDefault),
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
      validator: json.required(list{"msg", "validator"}, string)->Address.fromBech32,
      reporter: json.required(list{"msg", "reporter"}, string)->Address.fromBech32,
    })
  }
}

module Grant = {
  type t = {
    validator: Address.t,
    reporter: Address.t,
    url: option<string>,
    expiration: MomentRe.Moment.t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      validator: json.required(list{"msg", "granter"}, string)->Address.fromBech32,
      reporter: json.required(list{"msg", "grantee"}, string)->Address.fromBech32,
      url: json.optional(list{"msg", "url"}, string),
      expiration: json.required(list{"msg", "grant", "expiration"}, GraphQLParser.timeString),
    })
  }
}

module BasicAllowance = {
  type t = {
    spendLimit: list<Coin.t>,
    expiration: option<MomentRe.Moment.t>,
  }

  let decodeAllowance = json => {
    open JsonUtils.Decode
    buildObject(json => {
      spendLimit: json.required(list{"spend_limit"}, list(Coin.decodeCoin)),
      expiration: json.optional(list{"expiration"}, moment),
    })
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      spendLimit: json.required(list{"spend_limit"}, list(Coin.decodeCoin)),
      expiration: json.optional(list{"expiration"}, moment),
    })
  }

  // let decode = json => json->decodeAllowance
}

module PeriodicAllowance = {
  type t = {
    spendLimit: list<Coin.t>,
    expiration: option<MomentRe.Moment.t>,
    period: int,
    periodSpendLimit: list<Coin.t>,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      spendLimit: json.required(list{"basic", "spend_limit"}, list(Coin.decodeCoin)),
      expiration: json.optional(list{"basic", "expiration"}, moment),
      period: json.required(list{"period"}, stringOrInt),
      periodSpendLimit: json.required(list{"period_spend_limit"}, list(Coin.decodeCoin)),
    })
  }
}

module Allowance = {
  type t =
    | BasicAllowance(BasicAllowance.t)
    | PeriodicAllowance(PeriodicAllowance.t)
    | UnknownMsg

  let decode = json => {
    open JsonUtils.Decode

    switch json->mustGet("type", string) {
    | "/cosmos.feegrant.v1beta1.BasicAllowance" => {
        let allowance = json->mustDecode(BasicAllowance.decode)
        BasicAllowance(allowance)
      }

    | "/cosmos.feegrant.v1beta1.PeriodicAllowance" => {
        let allowance = json->mustDecode(PeriodicAllowance.decode)
        PeriodicAllowance(allowance)
      }

    | _ => UnknownMsg
    }
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
      validator: json.required(list{"msg", "granter"}, string)->Address.fromBech32,
      reporter: json.required(list{"msg", "grantee"}, string)->Address.fromBech32,
      msgTypeUrl: json.required(list{"msg", "msg_type_url"}, string),
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

// module GrantAllowance = {
//   type t = {
//     grantee: Address.t,
//     granter: Address.t,
//     allowance: Allowance.t,
//     allowedMessages: list<string>,
//   }

//   let decode = {
//     open JsonUtils.Decode
//     buildObject(json => {
//       grantee: json.required(list{"msg", "grantee"}, string)->Address.fromBech32,
//       granter: json.required(list{"msg", "granter"}, string)->Address.fromBech32,
//       allowance: json.required(list{"msg", "allowance", "allowance"}, Allowance.decode),
//       allowedMessages: json.required(list{"msg", "allowance", "allowed_messages"}, list(string)),
//     })
//   }
// }

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
      delegatorAddress: json.required(list{"msg", "delegator_address"}, string)->Address.fromBech32,
      validatorAddress: json.required(list{"msg", "validator_address"}, string)->Address.fromBech32,
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
      sender: json.required(list{"msg", "validator_address"}, string)->Address.fromBech32,
      minSelfDelegation: json.optional(
        list{"msg", "min_self_delegation"},
        floatstr,
      )->Belt.Option.map(_, Coin.newUBANDFromAmount),
    })
  }
}

type msg_t =
  | SendMsg(Send.t)
  | CreateDataSourceMsg(CreateDataSource.decoded_t)
  | EditDataSourceMsg(EditDataSource.t)
  | CreateOracleScriptMsg(CreateOracleScript.decoded_t)
  | EditOracleScriptMsg(EditOracleScript.t)
  | RequestMsg(Request.decoded_t)
  | ReportMsg(Report.t)
  | GrantMsg(Grant.t)
  | RevokeMsg(Revoke.t)
  | RevokeAllowanceMsg(RevokeAllowance.t)
  | CreateValidatorMsg(CreateValidator.t)
  | EditValidatorMsg(EditValidator.t)
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
  | CreateDataSourceMsg(_) => {name: "Create Data Source", category: OracleMsg}
  | EditDataSourceMsg(_) => {name: "Edit Data Source", category: OracleMsg}
  | CreateOracleScriptMsg(_) => {name: "Create Oracle Script", category: OracleMsg}
  | EditOracleScriptMsg(_) => {name: "Edit Oracle Script", category: OracleMsg}
  | RequestMsg(_) => {name: "Request", category: OracleMsg}
  | ReportMsg(_) => {name: "Report", category: OracleMsg}
  | GrantMsg(_) => {name: "Grant", category: ValidatorMsg}
  | RevokeMsg(_) => {name: "Revoke", category: ValidatorMsg}
  | RevokeAllowanceMsg(_) => {name: "Revoke Allowance", category: ValidatorMsg}
  | CreateValidatorMsg(_) => {name: "Create Validator", category: ValidatorMsg}
  | EditValidatorMsg(_) => {name: "Edit Validator", category: ValidatorMsg}
  | _ => {name: "Unknown msg", category: UnknownMsg}
  }
}

let decodeMsg = (json, isSuccess) => {
  let (decoded, sender, isIBC) = {
    open JsonUtils.Decode
    switch json->mustGet("type", string) {
    | "/cosmos.bank.v1beta1.MsgSend" => {
        let msg = json->mustDecode(Send.decode)
        (SendMsg(msg), msg.fromAddress, false)
      }

    | "/oracle.v1.MsgCreateDataSource" =>
      isSuccess
        ? {
            let msg = json->mustDecode(CreateDataSource.decodeSuccess)
            (CreateDataSourceMsg(Success(msg)), msg.sender, false)
          }
        : {
            let msg = json->mustDecode(CreateDataSource.decodeFail)
            (CreateDataSourceMsg(Failure(msg)), msg.sender, false)
          }

    | "/oracle.v1.MsgEditDataSource" =>
      let msg = json->mustDecode(EditDataSource.decode)
      (EditDataSourceMsg(msg), msg.sender, false)
    | "/oracle.v1.MsgCreateOracleScript" =>
      isSuccess
        ? {
            let msg = json->mustDecode(CreateOracleScript.decodeSuccess)
            (CreateOracleScriptMsg(Success(msg)), msg.sender, false)
          }
        : {
            let msg = json->mustDecode(CreateOracleScript.decodeFail)
            (CreateOracleScriptMsg(Failure(msg)), msg.sender, false)
          }

    | "/oracle.v1.MsgEditOracleScript" =>
      let msg = json->mustDecode(EditOracleScript.decode)
      (EditOracleScriptMsg(msg), msg.sender, false)

    | "/oracle.v1.MsgRequestData" =>
      isSuccess
        ? {
            let msg = json->mustDecode(Request.decodeSuccess)
            (RequestMsg(Success(msg)), msg.sender, false)
          }
        : {
            let msg = json->mustDecode(Request.decodeFail)
            (RequestMsg(Failure(msg)), msg.sender, false)
          }

    | "/oracle.v1.MsgReportData" =>
      let msg = json->mustDecode(Report.decode)
      (ReportMsg(msg), msg.reporter, false)
    | "/cosmos.authz.v1beta1.MsgGrant" =>
      let msg = json->mustDecode(Grant.decode)
      (GrantMsg(msg), msg.validator, false)
    | "/cosmos.authz.v1beta1.MsgRevoke" =>
      let msg = json->mustDecode(Revoke.decode)
      (RevokeMsg(msg), msg.validator, false)
    | "/cosmos.feegrant.v1beta1.MsgRevokeAllowance" =>
      let msg = json->mustDecode(RevokeAllowance.decode)
      (RevokeAllowanceMsg(msg), msg.granter, false)
    // | "/cosmos.feegrant.v1beta1.MsgGrantAllowance" =>
    //   let msg = json->mustDecode(GrantAllowance.decode)
    //   (GrantAllowanceMsg(msg), msg.granter, false)
    | "/cosmos.staking.v1beta1.MsgCreateValidator" =>
      let msg = json->mustDecode(CreateValidator.decode)
      (CreateValidatorMsg(msg), msg.delegatorAddress, false)
    | "/cosmos.staking.v1beta1.MsgEditValidator" =>
      let msg = json->mustDecode(EditValidator.decode)
      (EditValidatorMsg(msg), msg.sender, false)
    | _ => (UnknownMsg, Address.Address(""), false)
    }
  }
  {raw: json, decoded, sender, isIBC}
}
