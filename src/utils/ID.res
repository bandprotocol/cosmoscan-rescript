module type RawIDSig = {
  type tab_t
  let prefix: string
  let route: (int, tab_t) => Route.t
  let defaultTab: tab_t
}

module RawDataSourceID = {
  type tab_t = Route.data_source_tab_t
  let prefix = "#D"
  let route = (id, tab) => Route.DataSourceDetailsPage(id, tab)
  let defaultTab = Route.DataSourceRequests
}

module RawOracleScriptID = {
  type tab_t = Route.oracle_script_tab_t
  let prefix = "#O"
  let route = (id, tab) => Route.OracleScriptDetailsPage(id, tab)
  let defaultTab = Route.OracleScriptRequests
}

module RawRequestID = {
  type tab_t = unit
  let prefix = "#R"
  let route = (id, _) => Route.RequestIndexPage(id)
  let defaultTab = ()
}

module RawProposalID = {
  type tab_t = unit
  let prefix = "#P"
  let route = (id, _) => Route.ProposalDetailsPage(id)
  let defaultTab = ()
}

module RawBlock = {
  type tab_t = unit
  let prefix = "#B"
  let route = (height, _) => Route.BlockDetailsPage(height)
  let defaultTab = ()
}

module type IDSig = {
  include RawIDSig
  type t
  let getRoute: t => Route.t
  let toString: t => string
}

module IDCreator = (RawID: RawIDSig) => {
  include RawID

  type t = ID(int)

  let getRoute = x =>
    switch x {
    | ID(id) => RawID.route(id, RawID.defaultTab)
    }

  let getRouteWithTab = (ID(id), tab) => RawID.route(id, tab)

  let toString = x =>
    switch x {
    | ID(id) => RawID.prefix ++ Belt.Int.toString(id)
    }

  let toInt = x =>
    switch x {
    | ID(id) => id
    }

  let decoder = {
    open JsonUtils.Decode
    int->map((. a) => ID(a))
  }
  let fromJson = json => ID(json->Js.Json.decodeNumber->Belt.Option.getExn->Belt.Float.toInt)

  let fromInt = x => ID(x)

  let fromIntExn = x => ID(x->Belt.Option.getExn)

  let toJson = x =>
    switch x {
    | ID(id) => id->Belt.Int.toFloat->Js.Json.number
    }
}

module DataSource = IDCreator(RawDataSourceID)
module OracleScript = IDCreator(RawOracleScriptID)
module Request = IDCreator(RawRequestID)
module Proposal = IDCreator(RawProposalID)
module Block = IDCreator(RawBlock)
