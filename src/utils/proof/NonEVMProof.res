type request_t =
  | Request(RequestSub.t)
  | RequestMini(RequestSub.Mini.t)

type request_packet_t = {
  clientID: string,
  oracleScriptID: int,
  calldata: JsBuffer.t,
  askCount: int,
  minCount: int,
}

type response_packet_t = {
  clientID: string,
  requestID: int,
  ansCount: int,
  requestTime: int,
  resolveTime: int,
  resolveStatus: int,
  result: JsBuffer.t,
}

type iavl_merkle_path_t = {
  isDataOnRight: bool,
  subtreeHeight: int,
  subtreeSize: int,
  subtreeVersion: int,
  siblingHash: JsBuffer.t,
}

type oracle_data_proof_t = {
  requestPacket: request_packet_t,
  responsePacket: response_packet_t,
  version: int,
  iavlMerklePaths: list<iavl_merkle_path_t>,
}

type multi_store_proof_t = {
  accToGovStoresMerkleHash: JsBuffer.t,
  mainAndMintStoresMerkleHash: JsBuffer.t,
  oracleIAVLStateHash: JsBuffer.t,
  paramsStoresMerkleHash: JsBuffer.t,
  slashingToUpgradeStoresMerkleHash: JsBuffer.t,
}

type block_header_merkle_parts_t = {
  versionAndChainIdHash: JsBuffer.t,
  timeSecond: int,
  timeNanoSecond: int,
  lastBlockIDAndOther: JsBuffer.t,
  nextValidatorHashAndConsensusHash: JsBuffer.t,
  lastResultsHash: JsBuffer.t,
  evidenceAndProposerHash: JsBuffer.t,
}

type tm_signature_t = {
  r: JsBuffer.t,
  s: JsBuffer.t,
  v: int,
  signedDataPrefix: JsBuffer.t,
  signedDataSuffix: JsBuffer.t,
}

type block_relay_proof_t = {
  multiStoreProof: multi_store_proof_t,
  blockHeaderMerkleParts: block_header_merkle_parts_t,
  signatures: list<tm_signature_t>,
}

type proof_t = {
  blockHeight: int,
  oracleDataProof: oracle_data_proof_t,
  blockRelayProof: block_relay_proof_t,
}

let decodeRequestPacket = {
  open JsonUtils.Decode
  object(fields => {
    clientID: fields.optional(. "client_id", string)->Belt.Option.getWithDefault(""),
    oracleScriptID: fields.required(. "oracle_script_id", intstr),
    calldata: fields.required(. "calldata", bufferFromBase64),
    askCount: fields.required(. "ask_count", intstr),
    minCount: fields.required(. "min_count", intstr),
  })
}

let decodeResponsePacket = {
  open JsonUtils.Decode
  object(fields => {
    clientID: fields.optional(. "client_id", string)->Belt.Option.getWithDefault(""),
    requestID: fields.required(. "request_id", intstr),
    ansCount: fields.required(. "ans_count", intstr),
    requestTime: fields.required(. "request_time", intstr),
    resolveTime: fields.required(. "resolve_time", intstr),
    resolveStatus: fields.required(. "resolve_status", int),
    result: fields.required(. "result", bufferFromBase64),
  })
}

let decodeIAVLMerklePath = {
  open JsonUtils.Decode
  object(fields => {
    isDataOnRight: fields.required(. "isDataOnRight", bool),
    subtreeHeight: fields.required(. "subtreeHeight", int),
    subtreeSize: fields.required(. "subtreeSize", intstr),
    subtreeVersion: fields.required(. "subtreeVersion", intstr),
    siblingHash: fields.required(. "siblingHash", bufferFromHex),
  })
}

let decodeOracleDataProof = {
  open JsonUtils.Decode
  object(fields => {
    requestPacket: fields.required(. "requestPacket", decodeRequestPacket),
    responsePacket: fields.required(. "responsePacket", decodeResponsePacket),
    version: fields.required(. "version", intstr),
    iavlMerklePaths: fields.required(. "merklePaths", list(decodeIAVLMerklePath)),
  })
}

let decodeMultiStoreProof = {
  open JsonUtils.Decode
  object(fields => {
    accToGovStoresMerkleHash: fields.required(. "accToGovStoresMerkleHash", bufferFromHex),
    mainAndMintStoresMerkleHash: fields.required(. "mainAndMintStoresMerkleHash", bufferFromHex),
    oracleIAVLStateHash: fields.required(. "oracleIAVLStateHash", bufferFromHex),
    paramsStoresMerkleHash: fields.required(. "paramsStoresMerkleHash", bufferFromHex),
    slashingToUpgradeStoresMerkleHash: fields.required(.
      "slashingToUpgradeStoresMerkleHash",
      bufferFromHex,
    ),
  })
}

let decodeBlockHeaderMerkleParts = {
  open JsonUtils.Decode
  object(fields => {
    versionAndChainIdHash: fields.required(. "versionAndChainIdHash", bufferFromHex),
    timeSecond: fields.required(. "timeSecond", intstr),
    timeNanoSecond: fields.required(. "timeNanoSecond", int),
    lastBlockIDAndOther: fields.required(. "lastBlockIDAndOther", bufferFromHex),
    nextValidatorHashAndConsensusHash: fields.required(.
      "nextValidatorHashAndConsensusHash",
      bufferFromHex,
    ),
    lastResultsHash: fields.required(. "lastResultsHash", bufferFromHex),
    evidenceAndProposerHash: fields.required(. "evidenceAndProposerHash", bufferFromHex),
  })
}

let decodeTMSignature = {
  open JsonUtils.Decode
  object(fields => {
    r: fields.required(. "r", bufferFromHex),
    s: fields.required(. "s", bufferFromHex),
    v: fields.required(. "v", int),
    signedDataPrefix: fields.required(. "signedDataPrefix", bufferFromHex),
    signedDataSuffix: fields.required(. "signedDataSuffix", bufferFromHex),
  })
}

let decodeBlockRelayProof = {
  open JsonUtils.Decode
  object(fields => {
    multiStoreProof: fields.required(. "multiStoreProof", decodeMultiStoreProof),
    blockHeaderMerkleParts: fields.required(.
      "blockHeaderMerkleParts",
      decodeBlockHeaderMerkleParts,
    ),
    signatures: fields.required(. "signatures", list(decodeTMSignature)),
  })
}

let decodeProof = {
  open JsonUtils.Decode
  object(fields => {
    blockHeight: fields.required(. "blockHeight", intstr),
    oracleDataProof: fields.required(. "oracleDataProof", decodeOracleDataProof),
    blockRelayProof: fields.required(. "blockRelayProof", decodeBlockRelayProof),
  })
}
let obi_encode_int = (i, n) =>
  Obi.encode(
    "{x: " ++ n ++ "}/{_:u64}",
    "input",
    [{fieldName: "x", fieldValue: i->Belt.Int.toString}],
  )->Belt_Option.getExn

type variant_of_proof_t =
  | RequestPacket(request_packet_t)
  | ResponsePacket(response_packet_t)
  | IAVLMerklePath(iavl_merkle_path_t)
  | IAVLMerklePaths(list<iavl_merkle_path_t>)
  | MultiStoreProof(multi_store_proof_t)
  | BlockHeaderMerkleParts(block_header_merkle_parts_t)
  | Signature(tm_signature_t)
  | Signatures(list<tm_signature_t>)
  | Proof(proof_t)

let rec encode = x =>
  switch x {
  | RequestPacket({clientID, oracleScriptID, calldata, askCount, minCount}) =>
    Obi.encode(
      "{clientID: string, oracleScriptID: u64, calldata: bytes, askCount: u64, minCount: u64}/{_:u64}",
      "input",
      [
        {fieldName: "clientID", fieldValue: clientID},
        {fieldName: "oracleScriptID", fieldValue: oracleScriptID->Belt.Int.toString},
        {fieldName: "calldata", fieldValue: calldata->JsBuffer.toHex(~with0x=true)},
        {fieldName: "askCount", fieldValue: askCount->Belt.Int.toString},
        {fieldName: "minCount", fieldValue: minCount->Belt.Int.toString},
      ],
    )

  | ResponsePacket({
      clientID,
      requestID,
      ansCount,
      requestTime,
      resolveTime,
      resolveStatus,
      result,
    }) =>
    Obi.encode(
      "{clientID: string, requestID: u64, ansCount: u64, requestTime: u64, resolveTime: u64, resolveStatus: u32, result: bytes}/{_:u64}",
      "input",
      [
        {fieldName: "clientID", fieldValue: clientID},
        {fieldName: "requestID", fieldValue: requestID->Belt.Int.toString},
        {fieldName: "ansCount", fieldValue: ansCount->Belt.Int.toString},
        {fieldName: "requestTime", fieldValue: requestTime->Belt.Int.toString},
        {fieldName: "resolveTime", fieldValue: resolveTime->Belt.Int.toString},
        {fieldName: "resolveStatus", fieldValue: resolveStatus->Belt.Int.toString},
        {fieldName: "result", fieldValue: result->JsBuffer.toHex(~with0x=true)},
      ],
    )

  | IAVLMerklePath({isDataOnRight, subtreeHeight, subtreeSize, subtreeVersion, siblingHash}) =>
    Obi.encode(
      "{isDataOnRight: u8, subtreeHeight: u8, subtreeSize: u64, subtreeVersion: u64, siblingHash: bytes}/{_:u64}",
      "input",
      [
        {fieldName: "isDataOnRight", fieldValue: isDataOnRight ? "1" : "0"},
        {fieldName: "subtreeHeight", fieldValue: subtreeHeight->Belt.Int.toString},
        {fieldName: "subtreeSize", fieldValue: subtreeSize->Belt.Int.toString},
        {fieldName: "subtreeVersion", fieldValue: subtreeVersion->Belt.Int.toString},
        {fieldName: "siblingHash", fieldValue: siblingHash->JsBuffer.toHex(~with0x=true)},
      ],
    )

  | IAVLMerklePaths(iavl_merkle_paths) =>
    iavl_merkle_paths
    ->Belt.List.map(_, x => encode(IAVLMerklePath(x)))
    ->Belt.List.reduce(_, Some(JsBuffer.from([])), (a, b) =>
      switch (a, b) {
      | (Some(acc), Some(elem)) => Some(JsBuffer.concat([acc, elem]))
      | _ => None
      }
    )
    ->Belt_Option.map(_, x =>
      JsBuffer.concat([obi_encode_int(iavl_merkle_paths->Belt.List.length, "u32"), x])
    )

  | MultiStoreProof({
      accToGovStoresMerkleHash,
      mainAndMintStoresMerkleHash,
      oracleIAVLStateHash,
      paramsStoresMerkleHash,
      slashingToUpgradeStoresMerkleHash,
    }) =>
    Some(
      JsBuffer.concat([
        accToGovStoresMerkleHash,
        mainAndMintStoresMerkleHash,
        oracleIAVLStateHash,
        paramsStoresMerkleHash,
        slashingToUpgradeStoresMerkleHash,
      ]),
    )

  | BlockHeaderMerkleParts({
      versionAndChainIdHash,
      timeSecond,
      timeNanoSecond,
      lastBlockIDAndOther,
      nextValidatorHashAndConsensusHash,
      lastResultsHash,
      evidenceAndProposerHash,
    }) =>
    Obi.encode(
      "{versionAndChainIdHash: bytes, timeSecond: u64, timeNanoSecond: u32, lastBlockIDAndOther: bytes, nextValidatorHashAndConsensusHash: bytes, lastResultsHash: bytes, evidenceAndProposerHash: bytes}/{_:u64}",
      "input",
      [
        {
          fieldName: "versionAndChainIdHash",
          fieldValue: versionAndChainIdHash->JsBuffer.toHex(~with0x=true),
        },
        {fieldName: "timeSecond", fieldValue: timeSecond->Belt.Int.toString},
        {fieldName: "timeNanoSecond", fieldValue: timeNanoSecond->Belt.Int.toString},
        {
          fieldName: "lastBlockIDAndOther",
          fieldValue: lastBlockIDAndOther->JsBuffer.toHex(~with0x=true),
        },
        {
          fieldName: "nextValidatorHashAndConsensusHash",
          fieldValue: nextValidatorHashAndConsensusHash->JsBuffer.toHex(~with0x=true),
        },
        {
          fieldName: "lastResultsHash",
          fieldValue: lastResultsHash->JsBuffer.toHex(~with0x=true),
        },
        {
          fieldName: "evidenceAndProposerHash",
          fieldValue: evidenceAndProposerHash->JsBuffer.toHex(~with0x=true),
        },
      ],
    )

  | Signature({r, s, v, signedDataPrefix, signedDataSuffix}) =>
    Obi.encode(
      "{r: bytes, s: bytes, v: u8, signedDataPrefix: bytes, signedDataSuffix: bytes}/{_:u64}",
      "input",
      [
        {fieldName: "r", fieldValue: r->JsBuffer.toHex(~with0x=true)},
        {fieldName: "s", fieldValue: s->JsBuffer.toHex(~with0x=true)},
        {fieldName: "v", fieldValue: v->Belt.Int.toString},
        {
          fieldName: "signedDataPrefix",
          fieldValue: signedDataPrefix->JsBuffer.toHex(~with0x=true),
        },
        {
          fieldName: "signedDataSuffix",
          fieldValue: signedDataSuffix->JsBuffer.toHex(~with0x=true),
        },
      ],
    )

  | Signatures(tm_signatures) =>
    tm_signatures
    ->Belt.List.map(_, x => encode(Signature(x)))
    ->Belt.List.reduce(_, Some(JsBuffer.from([])), (a, b) =>
      switch (a, b) {
      | (Some(acc), Some(elem)) => Some(JsBuffer.concat([acc, elem]))
      | _ => None
      }
    )
    ->Belt_Option.map(_, x =>
      JsBuffer.concat([obi_encode_int(tm_signatures->Belt.List.length, "u32"), x])
    )

  | Proof({
      blockHeight,
      oracleDataProof: {requestPacket, responsePacket, version, iavlMerklePaths},
      blockRelayProof: {multiStoreProof, blockHeaderMerkleParts, signatures},
    }) => {
      let encodeMultiStore = encode(MultiStoreProof(multiStoreProof))->Belt.Option.getExn
      let encodeBlockHeaderMerkleParts =
        encode(BlockHeaderMerkleParts(blockHeaderMerkleParts))->Belt.Option.getExn
      let encodeSignatures = encode(Signatures(signatures))->Belt.Option.getExn
      let encodeReq = encode(RequestPacket(requestPacket))->Belt.Option.getExn
      let encodeRes = encode(ResponsePacket(responsePacket))->Belt.Option.getExn
      let encodeIAVLMerklePaths = encode(IAVLMerklePaths(iavlMerklePaths))->Belt.Option.getExn
      Obi.encode(
        "{blockHeight: u64, multiStore: bytes, blockMerkleParts: bytes, signatures: bytes, packet: bytes, version: u64, iavlPaths: bytes}/{_:u64}",
        "input",
        [
          {fieldName: "blockHeight", fieldValue: blockHeight->Belt.Int.toString},
          {
            fieldName: "multiStore",
            fieldValue: encodeMultiStore->JsBuffer.toHex(~with0x=true),
          },
          {
            fieldName: "blockMerkleParts",
            fieldValue: encodeBlockHeaderMerkleParts->JsBuffer.toHex(~with0x=true),
          },
          {
            fieldName: "signatures",
            fieldValue: encodeSignatures->JsBuffer.toHex(~with0x=true),
          },
          {
            fieldName: "packet",
            fieldValue: JsBuffer.concat([encodeReq, encodeRes])->JsBuffer.toHex(~with0x=true),
          },
          {fieldName: "version", fieldValue: version->Belt.Int.toString},
          {
            fieldName: "iavlPaths",
            fieldValue: encodeIAVLMerklePaths->JsBuffer.toHex(~with0x=true),
          },
        ],
      )
    }
  }

let createProofFromJson = proof => {
  switch Proof(proof->JsonUtils.Decode.mustDecode(decodeProof)) {
  | result => result->encode
  | exception _ => None
  }
}
