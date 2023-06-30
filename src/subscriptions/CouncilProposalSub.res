type council_t = {
  id: int,
  name: string,
}

type internal_t = {
  council: council_t,
  id: int,
  councilId: int,
  status: string,
  totalWeight: int,
  vetoId: option<int>,
  yesVote: option<float>,
  noVote: option<float>,
  submitTime: MomentRe.Moment.t,
  vetoEndTime: option<MomentRe.Moment.t>,
  votingEndTime: MomentRe.Moment.t,
  metadata: string,
  messages: Js.Json.t,
}

module SingleConfig = %graphql(`
  subscription CouncilProposal($id: Int!) {
    council_proposals_by_pk(id: $id) @ppxAs(type: "internal_t") {
      council @ppxAs(type: "council_t") {
        name
        id
      }
      id
      councilId: council_id
      vetoId: veto_id
      status @ppxCustom(module: "GraphQLParserModule.String")
      totalWeight: total_weight @ppxCustom(module: "GraphQLParserModule.IntString")
      yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      vetoEndTime: veto_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      metadata
      messages
    }
  }
`)

module MultiConfig = %graphql(`
  subscription CouncilProposal($limit: Int!, $offset: Int!) {
    council_proposals(limit: $limit, offset: $offset, order_by: [{id: desc}]) @ppxAs(type: "internal_t") {
      council @ppxAs(type: "council_t") {
        name
        id
      }
      id
      councilId: council_id
      vetoId: veto_id
      status @ppxCustom(module: "GraphQLParserModule.String")
      totalWeight: total_weight @ppxCustom(module: "GraphQLParserModule.IntString")
      yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      vetoEndTime: veto_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingEndTime: voting_end_time @ppxCustom(module: "GraphQLParserModule.Date")
      metadata
      messages
    }
  }
`)

let toExternal = ({
  council,
  id,
  councilId,
  status,
  vetoId,
  vetoEndTime,
  yesVote,
  noVote,
  votingEndTime,
  metadata,
  messages,
  submitTime,
  totalWeight,
}) => {
  {
    id,
    councilId,
    status,
    vetoId,
    vetoEndTime,
    council,
    yesVote,
    noVote,
    votingEndTime,
    metadata,
    messages,
    submitTime,
    totalWeight,
  }
}

let get = id => {
  let result = SingleConfig.use({id: id})

  result
  ->Sub.fromData
  ->Sub.flatMap(({council_proposals_by_pk}) => {
    switch council_proposals_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.council_proposals->Belt.Array.map(toExternal))
}
