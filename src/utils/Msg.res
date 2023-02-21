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
  type t = {
    // User message fields
    owner: Address.t,
    name: string,
    executable: JsBuffer.t,
    treasury: Address.t,
    fee: list<Coin.t>,
    sender: Address.t,
    // Success only fields
    id: option<ID.DataSource.t>,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      owner: json.required(list{"msg", "owner"}, address),
      name: json.required(list{"msg", "name"}, string),
      executable: json.required(list{"msg", "executable"}, string)->JsBuffer.fromBase64,
      treasury: json.required(list{"msg", "treasury"}, address),
      fee: json.required(list{"msg", "fee"}, list(Coin.decodeCoin)),
      sender: json.required(list{"msg", "sender"}, address),
      id: json.required(list{"msg", "id"}, option(ID.DataSource.decoder)),
    })
  }
}

module Request = {
  type t = {
    // User message fields
    oracleScriptID: ID.OracleScript.t,
    calldata: JsBuffer.t,
    askCount: int,
    minCount: int,
    prepareGas: int,
    executeGas: int,
    feeLimit: list<Coin.t>,
    sender: Address.t,
    // Success only fields
    id: option<ID.Request.t>,
    oracleScriptName: option<string>,
    schema: option<string>,
  }

  let decode = {
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
      id: json.optional(list{"msg", "id"}, ID.Request.decoder),
      oracleScriptName: json.optional(list{"msg", "name"}, string),
      schema: json.optional(list{"msg", "schema"}, string),
    })
  }
}

type msg_t =
  | SendMsg(Send.t)
  | CreateDataSourceMsg(CreateDataSource.t)
  | RequestMsg(Request.t)
  | UnknownMsg

type t = {
  raw: Js.Json.t,
  decoded: msg_t,
  sender: Address.t,
  isIBC: bool,
}

let isIBC = msg =>
  switch msg {
  | SendMsg(_)
  | CreateDataSourceMsg(_)
  | RequestMsg(_)
  | UnknownMsg => false
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
  | RequestMsg(_) => {name: "Request", category: OracleMsg}
  | _ => {name: "Unknown msg", category: UnknownMsg}
  }
}

let decodeMsg = json => {
  let (decoded, sender) = {
    open JsonUtils.Decode
    switch json->mustGet("type", string) {
    | "/cosmos.bank.v1beta1.MsgSend" => {
        let msg = json->mustDecode(Send.decode)
        (SendMsg(msg), msg.fromAddress)
      }

    | "/oracle.v1.MsgCreateDataSource" => {
        let msg = json->mustDecode(CreateDataSource.decode)
        (CreateDataSourceMsg(msg), msg.sender)
      }

    | "/oracle.v1.MsgRequestData" => {
        let msg = json->mustDecode(Request.decode)
        (RequestMsg(msg), msg.sender)
      }

    | _ => (UnknownMsg, Address.Address(""))
    }
  }
  {raw: json, decoded, sender, isIBC: decoded->isIBC}
}
