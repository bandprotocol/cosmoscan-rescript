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

  type t_base = t<unit>
  type t_success = t<ID.DataSource.t>

  type msg_t =
    | Success(t_success)
    | Failure(t_base)

  let decodeUnit = idDecoder => {
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
  let decodeBase: JsonUtils.Decode.t<t_base> = decodeUnit(_ => ())
  let decodeSuccess: JsonUtils.Decode.t<t_success> = decodeUnit(json =>
    json.required(list{"msg", "id"}, ID.DataSource.decoder)
  )
  // let decodeSuccess = decode((list{"msg", "id"}, ID.DataSource.decoder))
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
  | CreateDataSourceMsg(CreateDataSource.msg_t)
  | RequestMsg(Request.t)
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
      // let createSuccess = json => {
      //   let msg = json->mustDecode(CreateDataSource.decodeSuccess)
      //   (CreateDataSourceMsg(Success(msg)), msg.sender, false)
      // }
      // let createFail = json => {
      //   let msg = json->mustDecode(CreateDataSource.decodeBase)
      //   (CreateDataSourceMsg(Failure(msg)), msg.sender, false)
      // }

      switch isSuccess {
      | true => {
          let msg = json->mustDecode(CreateDataSource.decodeSuccess)
          (CreateDataSourceMsg(Success(msg)), msg.sender, false)
        }

      | false => {
          let msg = json->mustDecode(CreateDataSource.decodeBase)
          (CreateDataSourceMsg(Failure(msg)), msg.sender, false)
        }
      }
    | "/oracle.v1.MsgRequestData" => {
        let msg = json->mustDecode(Request.decode)
        (RequestMsg(msg), msg.sender, false)
      }

    | _ => (UnknownMsg, Address.Address(""), false)
    }
  }
  {raw: json, decoded, sender, isIBC}
}
