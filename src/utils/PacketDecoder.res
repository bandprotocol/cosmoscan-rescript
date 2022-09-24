module OracleRequestPacket = {
  type t = {
    requestID: ID.Request.t,
    oracleScriptID: ID.OracleScript.t,
    oracleScriptName: string,
    clientID: string,
    calldata: JsBuffer.t,
    askCount: int,
    minCount: int,
    feeLimit: string,
    executeGas: int,
    prepareGas: int,
    schema: string,
    requestKey: string,
    payer: Address.t,
  }

  open JsonUtils.Decode
  let decode = buildObject(json => {
    requestID: json.at(list{"id"}, ID.Request.decoder),
    oracleScriptID: json.at(list{"decoded_data", "oracle_script_id"}, ID.OracleScript.decoder),
    oracleScriptName: json.at(list{"decoded_data", "oracle_script_name"}, string),
    clientID: json.at(list{"decoded_data", "client_id"}, string),
    calldata: json.at(list{"decoded_data", "calldata"}, bufferWithDefault),
    askCount: json.at(list{"decoded_data", "ask_count"}, int),
    minCount: json.at(list{"decoded_data", "min_count"}, int),
    feeLimit: json.at(list{"decoded_data", "fee_limit"}, string),
    executeGas: json.at(list{"decoded_data", "execute_gas"}, int),
    prepareGas: json.at(list{"decoded_data", "prepare_gas"}, int),
    schema: json.at(list{"decoded_data", "oracle_script_schema"}, string),
    requestKey: json.at(list{"decoded_data", "request_key"}, string),
    payer: json.at(list{"decoded_data", "payer"}, string)->Address.fromBech32,
  })
}

module FungibleTokenPacket = {
  type t = {
    amount: int,
    denom: string,
    receiver: string,
    sender: string,
  }

  open JsonUtils.Decode
  let decode = buildObject(json => {
    amount: json.at(list{"amount"}, int),
    denom: json.at(list{"denom"}, string),
    receiver: json.at(list{"receiver"}, string),
    sender: json.at(list{"sender"}, string),
  })
}

type packet_t =
  | OracleRequestPacket(OracleRequestPacket.t)
  | FungibleTokenPacket(FungibleTokenPacket.t)
  | Unknown

type t = {
  packetDetail: packet_t,
  packetType: string,
}

let getPacketTypeText = packetType =>
  switch packetType {
  | "oracle_request" => "Oracle Request"
  | "oracle_response" => "Oracle Response"
  | "fungible_token" => "Fungible Token"
  | _ => "Unknown"
  }

let decodeAction = {
  open JsonUtils.Decode
  custom((. json) => {
    {
      packetDetail: {
        switch json->mustDecode(at(list{"msg", "packet_type"}, string)) {
        | "oracle_request" =>
          OracleRequestPacket(json->mustDecode(at(list{"msg"}, OracleRequestPacket.decode)))
        | "fungible_token" =>
          FungibleTokenPacket(
            json->mustDecode(at(list{"msg", "decoded_data"}, FungibleTokenPacket.decode)),
          )
        | _ => Unknown
        }
      },
      packetType: json->mustDecode(at(list{"msg", "packet_type"}, string))->getPacketTypeText,
    }
  })
}
