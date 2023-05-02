type data_source_tab_t =
  | DataSourceExecute
  | DataSourceCode
  | DataSourceRequests

type oracle_script_tab_t =
  | OracleScriptExecute
  | OracleScriptCode
  | OracleScriptBridgeCode
  | OracleScriptRequests

type account_tab_t =
  | AccountDelegations
  | AccountUnbonding
  | AccountRedelegate

type validator_tab_t =
  | ProposedBlocks
  | Delegators
  | Reports
  | Reporters

type t =
  | NotFound
  | HomePage
  | DataSourcePage
  | DataSourceDetailsPage(int, data_source_tab_t)
  | OracleScriptPage
  | OracleScriptDetailsPage(int, oracle_script_tab_t)
  | TxHomePage
  | TxIndexPage(Hash.t)
  | BlockPage
  | BlockDetailsPage(int)
  | RequestHomePage
  | RequestDetailsPage(int)
  | AccountIndexPage(Address.t, account_tab_t)
  | ValidatorsPage
  | ValidatorDetailsPage(Address.t, validator_tab_t)
  | ProposalPage
  | ProposalDetailsPage(int)
  | RelayersHomepage
  | ChannelDetailsPage(string, string, string)

let fromUrl = (url: RescriptReactRouter.url) =>
  // TODO: We'll handle the NotFound case for Datasources and Oraclescript later
  switch (url.path, url.hash) {
  | (list{"data-sources"}, _) => DataSourcePage
  | (list{"data-source", dataSourceID}, hash) =>
    let urlHash = hash =>
      switch hash {
      | "code" => DataSourceCode
      | "execute" => DataSourceExecute
      | _ => DataSourceRequests
      }
    switch dataSourceID->Belt.Int.fromString {
    | Some(dataSourceIDInt) => DataSourceDetailsPage(dataSourceIDInt, urlHash(hash))
    | None => NotFound
    }
  | (list{"oracle-scripts"}, _) => OracleScriptPage
  | (list{"oracle-script", oracleScriptID}, hash) =>
    let urlHash = hash =>
      switch hash {
      | "code" => OracleScriptCode
      | "bridge" => OracleScriptBridgeCode
      | "execute" => OracleScriptExecute
      | "revisions" => OracleScriptRequests
      | _ => OracleScriptRequests
      }
    switch oracleScriptID->Belt.Int.fromString {
    | Some(oracleScriptIDInt) => OracleScriptDetailsPage(oracleScriptIDInt, urlHash(hash))
    | None => NotFound
    }

  | (list{"txs"}, _) => TxHomePage
  | (list{"tx", txHash}, _) => TxIndexPage(Hash.fromHex(txHash))
  | (list{"validators"}, _) => ValidatorsPage
  | (list{"blocks"}, _) => BlockPage
  | (list{"block", blockHeight}, _) =>
    let blockHeightIntOpt = blockHeight->Belt.Int.fromString
    switch blockHeightIntOpt {
    | Some(block) => BlockDetailsPage(block)
    | None => NotFound
    }

  | (list{"requests"}, _) => RequestHomePage
  | (list{"request", reqID}, _) => RequestDetailsPage(reqID->Parse.mustParseInt)
  | (list{"account", address}, hash) =>
    let urlHash = hash =>
      switch hash {
      | "unbonding" => AccountUnbonding
      | "redelegate" => AccountRedelegate
      | _ => AccountDelegations
      }
    switch address->Address.fromBech32Opt {
    | Some(address) => AccountIndexPage(address, urlHash(hash))
    | None => NotFound
    }
  | (list{"validator", address}, hash) =>
    let urlHash = hash =>
      switch hash {
      | "delegators" => Delegators
      | "reporters" => Reporters
      | "proposed-blocks" => ProposedBlocks
      | _ => Reports
      }
    switch address->Address.fromBech32Opt {
    | Some(address) => ValidatorDetailsPage(address, urlHash(hash))
    | None => NotFound
    }
  | (list{"proposals"}, _) => ProposalPage
  | (list{"proposal", proposalID}, _) => ProposalDetailsPage(proposalID->Parse.mustParseInt)
  | (list{"relayers"}, _) => RelayersHomepage
  | (list{"relayers", counterparty, port, channelID}, _) =>
    ChannelDetailsPage(counterparty, port, channelID)
  | (list{}, _) => HomePage
  | (_, _) => NotFound
  }

let toAbsoluteString = route =>
  switch route {
  | DataSourcePage => "/data-sources"
  | OracleScriptPage => "/oracle-scripts"
  | TxHomePage => "/txs"
  | ValidatorsPage => "/validators"
  | BlockPage => "/blocks"
  | RequestHomePage => "/requests"
  | AccountIndexPage(address, AccountDelegations) => {
      let addressBech32 = address->Address.toBech32
      `/account/${addressBech32}#delegations`
    }

  | AccountIndexPage(address, AccountUnbonding) => {
      let addressBech32 = address->Address.toBech32
      `/account/${addressBech32}#unbonding`
    }

  | AccountIndexPage(address, AccountRedelegate) => {
      let addressBech32 = address->Address.toBech32
      `/account/${addressBech32}#redelegate`
    }

  | ValidatorDetailsPage(validatorAddress, Delegators) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#delegators`
    }

  | ValidatorDetailsPage(validatorAddress, Reports) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#reports`
    }

  | ValidatorDetailsPage(validatorAddress, Reporters) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#reporters`
    }

  | ValidatorDetailsPage(validatorAddress, ProposedBlocks) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#proposed-blocks`
    }

  | ProposalPage => "/proposals"
  | RelayersHomepage => "/relayers"
  | HomePage => "/"
  | NotFound => "/notfound"
  | _ => "/"
  }

let toString = route =>
  switch route {
  | DataSourcePage => "/data-sources"
  | DataSourceDetailsPage(dataSourceID, DataSourceRequests) =>
    `/data-source/${dataSourceID->Belt.Int.toString}`
  | DataSourceDetailsPage(dataSourceID, DataSourceCode) =>
    `/data-source/${dataSourceID->Belt.Int.toString}#code`
  | DataSourceDetailsPage(dataSourceID, DataSourceExecute) =>
    `/data-source/${dataSourceID->Belt.Int.toString}#execute`
  | OracleScriptPage => "/oracle-scripts"
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptRequests) =>
    `/oracle-script/${oracleScriptID->Belt.Int.toString}`
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptCode) =>
    `/oracle-script/${oracleScriptID->Belt.Int.toString}#code`
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptBridgeCode) =>
    `/oracle-script/${oracleScriptID->Belt.Int.toString}#bridge`
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptExecute) =>
    `/oracle-script/${oracleScriptID->Belt.Int.toString}#execute`
  | TxHomePage => "/txs"
  | TxIndexPage(txHash) => `/tx/${txHash->Hash.toHex}`
  | ValidatorsPage => "/validators"
  | BlockPage => "/blocks"
  | BlockDetailsPage(height) => `/block/${height->Belt.Int.toString}`
  | RequestHomePage => "/requests"
  | RequestDetailsPage(reqID) => `/request/${reqID->Belt.Int.toString}`
  | AccountIndexPage(address, AccountDelegations) => {
      let addressBech32 = address->Address.toBech32
      `/account/${addressBech32}#delegations`
    }

  | AccountIndexPage(address, AccountUnbonding) => {
      let addressBech32 = address->Address.toBech32
      `/account/${addressBech32}#unbonding`
    }

  | AccountIndexPage(address, AccountRedelegate) => {
      let addressBech32 = address->Address.toBech32
      `/account/${addressBech32}#redelegate`
    }

  | ValidatorDetailsPage(validatorAddress, Delegators) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#delegators`
    }

  | ValidatorDetailsPage(validatorAddress, Reports) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#reports`
    }

  | ValidatorDetailsPage(validatorAddress, Reporters) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#reporters`
    }

  | ValidatorDetailsPage(validatorAddress, ProposedBlocks) => {
      let validatorAddressBech32 = validatorAddress->Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#proposed-blocks`
    }

  | ProposalPage => "/proposals"
  | ProposalDetailsPage(proposalID) => `/proposal/${proposalID->Belt.Int.toString}`
  | RelayersHomepage => "/relayers"
  | ChannelDetailsPage(chainID, port, channel) => `/relayers/${chainID}/${port}/${channel}`
  | HomePage => "/"
  | NotFound => "/notfound"
  }

let redirect = (route: t) => RescriptReactRouter.push(route->toString)

let search = (str: string) => {
  let len = str->String.length
  let capStr = str->String.capitalize_ascii

  if str->Js.String2.startsWith("bandvaloper") {
    Some(ValidatorDetailsPage(str->Address.fromBech32, Reports))
  } else if str->Js.String2.startsWith("band") {
    Some(AccountIndexPage(str->Address.fromBech32, AccountDelegations))
  } else if len == 64 || (str->Js.String2.startsWith("0x") && len == 66) {
    Some(TxIndexPage(str->Hash.fromHex))
  } else if capStr->Js.String2.startsWith("B") {
    let blockIDOpt = str->String.sub(1, len - 1)->Belt.Int.fromString
    blockIDOpt->Belt.Option.map(blockID => BlockDetailsPage(blockID))
  } else if capStr->Js.String2.startsWith("D") {
    let dataSourceIDOpt = str->String.sub(1, len - 1)->Belt.Int.fromString
    dataSourceIDOpt->Belt.Option.map(dataSourceID => DataSourceDetailsPage(
      dataSourceID,
      DataSourceRequests,
    ))
  } else if capStr->Js.String2.startsWith("R") {
    let requestIDOpt = str->String.sub(1, len - 1)->Belt.Int.fromString
    requestIDOpt->Belt.Option.map(requestID => RequestDetailsPage(requestID))
  } else if capStr->Js.String2.startsWith("O") {
    let oracleScriptIDOpt = str->String.sub(1, len - 1)->Belt.Int.fromString
    oracleScriptIDOpt->Belt.Option.map(oracleScriptID => OracleScriptDetailsPage(
      oracleScriptID,
      OracleScriptRequests,
    ))
  } else {
    // switch str->Belt.Int.fromString {
    // | Some(blockID) => Some(BlockDetailsPage(blockID))
    // | None => None
    // }
    None
  }->Belt.Option.getWithDefault(_, NotFound)
}
