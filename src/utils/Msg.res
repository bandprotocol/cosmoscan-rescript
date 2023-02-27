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

type msg_t =
  | SendMsg(Send.t)
  | CreateDataSourceMsg(CreateDataSource.decoded_t)
  | EditDataSourceMsg(EditDataSource.t)
  | RequestMsg(Request.decoded_t)
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
  | RequestMsg(_) => {name: "Request", category: OracleMsg}
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

    | _ => (UnknownMsg, Address.Address(""), false)
    }
  }
  {raw: json, decoded, sender, isIBC}
}
