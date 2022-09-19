type data_source_tab_t =
  | DataSourceExecute
  | DataSourceCode
  | DataSourceRequests
  | DataSourceRevisions

type oracle_script_tab_t =
  | OracleScriptExecute
  | OracleScriptCode
  | OracleScriptBridgeCode
  | OracleScriptRequests
  | OracleScriptRevisions

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
  | DataSourceHomePage
  | DataSourceIndexPage(int, data_source_tab_t)
  | OracleScriptPage
  | OracleScriptDetailsPage(int, oracle_script_tab_t)
  | TxHomePage
  | TxIndexPage(Hash.t)
  | BlockHomePage
  | BlockIndexPage(int)
  | RequestHomePage
  | RequestIndexPage(int)
  | AccountIndexPage(Address.t, account_tab_t)
  | ValidatorsPage
  | ValidatorDetailsPage(Address.t, validator_tab_t)
  | ProposalPage
  | ProposalDetailsPage(int)
  | IBCHomePage

let fromUrl = (url: RescriptReactRouter.url) =>
  // TODO: We'll handle the NotFound case for Datasources and Oraclescript later
  switch (url.path, url.hash) {
  | (list{"data-sources"}, _) => DataSourceHomePage
  | (list{"data-source", dataSourceID}, hash) =>
    let urlHash = hash =>
      switch hash {
      | "code" => DataSourceCode
      | "execute" => DataSourceExecute
      | "revisions" => DataSourceRevisions
      | _ => DataSourceRequests
      }
    switch dataSourceID |> int_of_string_opt {
    | Some(dataSourceIDInt) => DataSourceIndexPage(dataSourceIDInt, urlHash(hash))
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
    switch oracleScriptID |> int_of_string_opt {
    | Some(oracleScriptIDInt) => OracleScriptDetailsPage(oracleScriptIDInt, urlHash(hash))
    | None => NotFound
    }

  | (list{"txs"}, _) => TxHomePage
  | (list{"tx", txHash}, _) => TxIndexPage(Hash.fromHex(txHash))
  | (list{"validators"}, _) => ValidatorsPage
  | (list{"blocks"}, _) => BlockHomePage
  | (list{"block", blockHeight}, _) =>
    let blockHeightIntOpt = blockHeight |> int_of_string_opt
    switch blockHeightIntOpt {
    | Some(block) => BlockIndexPage(block)
    | None => NotFound
    }

  | (list{"requests"}, _) => RequestHomePage
  | (list{"request", reqID}, _) => RequestIndexPage(reqID |> int_of_string)
  | (list{"account", address}, hash) =>
    let urlHash = hash =>
      switch hash {
      | "unbonding" => AccountUnbonding
      | "redelegate" => AccountRedelegate
      | _ => AccountDelegations
      }
    switch address |> Address.fromBech32Opt {
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
    switch address |> Address.fromBech32Opt {
    | Some(address) => ValidatorDetailsPage(address, urlHash(hash))
    | None => NotFound
    }
  | (list{"proposals"}, _) => ProposalPage
  | (list{"proposal", proposalID}, _) => ProposalDetailsPage(proposalID |> int_of_string)
  | (list{"ibcs"}, _) => IBCHomePage
  | (list{}, _) => HomePage
  | (_, _) => NotFound
  }

let toString = route =>
  switch route {
  | DataSourceHomePage => "/data-sources"
  | DataSourceIndexPage(dataSourceID, DataSourceRequests) =>
    `/data-source/${dataSourceID |> string_of_int}`
  | DataSourceIndexPage(dataSourceID, DataSourceCode) =>
    `/data-source/${dataSourceID |> string_of_int}#code`
  | DataSourceIndexPage(dataSourceID, DataSourceExecute) =>
    `/data-source/${dataSourceID |> string_of_int}#execute`
  | DataSourceIndexPage(dataSourceID, DataSourceRevisions) =>
    `/data-source/${dataSourceID |> string_of_int}#revisions`
  | OracleScriptPage => "/oracle-scripts"
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptRequests) =>
    `/oracle-script/${oracleScriptID |> string_of_int}`
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptCode) =>
    `/oracle-script/${oracleScriptID |> string_of_int}#code`
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptBridgeCode) =>
    `/oracle-script/${oracleScriptID |> string_of_int}#bridge`
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptExecute) =>
    `/oracle-script/${oracleScriptID |> string_of_int}#execute`
  | OracleScriptDetailsPage(oracleScriptID, OracleScriptRevisions) =>
    `/oracle-script/${oracleScriptID |> string_of_int}#revisions`
  | TxHomePage => "/txs"
  | TxIndexPage(txHash) => `/tx/${txHash |> Hash.toHex}`
  | ValidatorsPage => "/validators"
  | BlockHomePage => "/blocks"
  | BlockIndexPage(height) => `/block/${height |> string_of_int}`
  | RequestHomePage => "/requests"
  | RequestIndexPage(reqID) => `/request/${reqID |> string_of_int}`
  | AccountIndexPage(address, AccountDelegations) => {
      let addressBech32 = address |> Address.toBech32
      `/account/${addressBech32}#delegations`
    }
  | AccountIndexPage(address, AccountUnbonding) => {
      let addressBech32 = address |> Address.toBech32
      `/account/${addressBech32}#unbonding`
    }
  | AccountIndexPage(address, AccountRedelegate) => {
      let addressBech32 = address |> Address.toBech32
      `/account/${addressBech32}#redelegate`
    }
  | ValidatorDetailsPage(validatorAddress, Delegators) => {
      let validatorAddressBech32 = validatorAddress |> Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#delegators`
    }
  | ValidatorDetailsPage(validatorAddress, Reports) => {
      let validatorAddressBech32 = validatorAddress |> Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#reports`
    }
  | ValidatorDetailsPage(validatorAddress, Reporters) => {
      let validatorAddressBech32 = validatorAddress |> Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#reporters`
    }
  | ValidatorDetailsPage(validatorAddress, ProposedBlocks) => {
      let validatorAddressBech32 = validatorAddress |> Address.toOperatorBech32
      `/validator/${validatorAddressBech32}#proposed-blocks`
    }
  | ProposalPage => "/proposals"
  | ProposalDetailsPage(proposalID) => `/proposal/${proposalID |> string_of_int}`
  | IBCHomePage => "/ibcs"
  | HomePage => "/"
  | NotFound => "/notfound"
  }

let redirect = (route: t) => RescriptReactRouter.push(route |> toString)

let search = (str: string) => {
  let len = str |> String.length
  let capStr = str |> String.capitalize_ascii

  switch str |> int_of_string_opt {
  | Some(blockID) => Some(BlockIndexPage(blockID))
  | None =>
    if str |> Js.String.startsWith("bandvaloper") {
      Some(ValidatorDetailsPage(str |> Address.fromBech32, Reports))
    } else if str |> Js.String.startsWith("band") {
      Some(AccountIndexPage(str |> Address.fromBech32, AccountDelegations))
    } else if len == 64 || (str |> Js.String.startsWith("0x") && len == 66) {
      Some(TxIndexPage(str |> Hash.fromHex))
    } else if capStr |> Js.String.startsWith("B") {
      let blockIDOpt = str |> String.sub(_, 1, len - 1) |> int_of_string_opt
      blockIDOpt->Belt.Option.map(blockID => BlockIndexPage(blockID))
    } else if capStr |> Js.String.startsWith("D") {
      let dataSourceIDOpt = str |> String.sub(_, 1, len - 1) |> int_of_string_opt
      dataSourceIDOpt->Belt.Option.map(dataSourceID => DataSourceIndexPage(
        dataSourceID,
        DataSourceRequests,
      ))
    } else if capStr |> Js.String.startsWith("R") {
      let requestIDOpt = str |> String.sub(_, 1, len - 1) |> int_of_string_opt
      requestIDOpt->Belt.Option.map(requestID => RequestIndexPage(requestID))
    } else if capStr |> Js.String.startsWith("O") {
      let oracleScriptIDOpt = str |> String.sub(_, 1, len - 1) |> int_of_string_opt
      oracleScriptIDOpt->Belt.Option.map(oracleScriptID => OracleScriptDetailsPage(
        oracleScriptID,
        OracleScriptRequests,
      ))
    } else {
      None
    }
  } |> Belt.Option.getWithDefault(_, NotFound)
}
