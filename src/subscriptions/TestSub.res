type internal_vote_t = {
  proposal_id: int,
  yesVote: float,
};

module ValidatorVoteByProposalIDConfig = %graphql(`
    subscription Validator_vote_proposals_view {
      validator_vote_proposals_view{
        proposal_id
        yesVote: yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      }
    }
`)

let get = _ => {
  let result = ValidatorVoteByProposalIDConfig.use()
  
  result |> Sub.fromData
  |> Sub.flatMap(_, ({validator_vote_proposals_view}) => {
    validator_vote_proposals_view -> Belt.Array.reduce(0. , (acc, {yesVote}) => acc +. yesVote -> Belt.Option.getExn) -> Sub.resolve
  })
};

let log = id => {
  let result = ValidatorVoteByProposalIDConfig.use()
  result |> Sub.fromData
  |> Sub.flatMap(_, ({validator_vote_proposals_view}) => {
    validator_vote_proposals_view -> Belt.Array.forEach(({proposal_id, yesVote}) => Js.log( (proposal_id -> Belt.Option.getExn -> Belt.Int.toString) ++ "Vote: " ++ (yesVote -> Belt.Option.getExn -> Belt.Float.toString)))
    -> Sub.resolve
  })
}
