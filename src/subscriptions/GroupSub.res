module ProposalConfig = %graphql(`
  subscription GroupProposal($groupID: Int!, $limit: Int!, $offset: Int!) {
    group_proposals(where: {group_id: { _eq: $groupID }}, limit: $limit, offset: $offset) @ppxAs(type: "Group.Proposal.internal_t") {
      id @ppxCustom(module:"GraphQLParserModule.GroupProposalID")
      title
      messages
      group_policy @ppxAs(type: "Group.Proposal.group_policy_internal_t") {
        _type: type
        decisionPolicy: decision_policy
      }
      yesVote :yes_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      noVote: no_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      noWithVetoVote: no_with_veto_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      abstainVote: abstain_vote @ppxCustom(module: "GraphQLParserModule.FloatString")
      status @ppxCustom(module:"GraphQLParserModule.GroupProposalStatus")
    }
  }
`)

module MemberConfig = %graphql(`
  subscription GroupMember($groupID: Int!, $limit: Int!, $offset: Int!) {
    group_members(where: {group_id: { _eq: $groupID }}, limit: $limit, offset: $offset) @ppxAs(type: "Group.group_member_t") {
      account @ppxAs(type: "Group.account_t") {
        address @ppxCustom(module:"GraphQLParserModule.Address")
      }
      metadata
      weight @ppxCustom(module:"GraphQLParserModule.IntString")
      addedAt: added_at @ppxCustom(module: "GraphQLParserModule.Date")
    }
  }
`)

module PolicyConfig = %graphql(`
  subscription GroupPolicy($groupID: Int!, $limit: Int!, $offset: Int!) {
    group_policies(where: {group_id: { _eq: $groupID }}, limit: $limit, offset: $offset) @ppxAs(type: "Group.Policy.internal_t") {
      _type: type @ppxCustom(module:"GraphQLParserModule.GroupPolicyType")
      address @ppxCustom(module:"GraphQLParserModule.Address")
      decisionPolicy: decision_policy
      createdAt: created_at @ppxCustom(module: "GraphQLParserModule.Date")
      metadata
      version
    }
  }
`)

module SingleConfig = %graphql(`
  subscription Group($id: Int!)  {
    groups_by_pk(id: $id) @ppxAs(type: "Group.internal_t") {
      id @ppxCustom(module: "GraphQLParserModule.GroupID")
      admin @ppxCustom(module:"GraphQLParserModule.Address")
      totalWeight: total_weight @ppxCustom(module:"GraphQLParserModule.IntString")
      createdAt: created_at @ppxCustom(module: "GraphQLParserModule.Date")
      metadata
      group_members_aggregate @ppxAs(type: "Group.group_members_aggregate_t") {
        aggregate @ppxAs(type: "Group.aggregate_t") {
          count
        }
      }
      group_policies_aggregate @ppxAs(type: "Group.group_policies_aggregate_t") {
        aggregate @ppxAs(type: "Group.aggregate_t") {
          count
        }
      }
      group_proposals_aggregate @ppxAs(type: "Group.group_proposals_aggregate_t") {
        aggregate @ppxAs(type: "Group.aggregate_t") {
          count
        }
      }
    }
  }
`)

module MultiConfig = %graphql(`
  subscription Groups($limit: Int!, $offset: Int!)  {
      groups(limit: $limit, offset: $offset) @ppxAs(type: "Group.internal_t"){
          id @ppxCustom(module: "GraphQLParserModule.GroupID")
          admin @ppxCustom(module:"GraphQLParserModule.Address")
          totalWeight: total_weight @ppxCustom(module:"GraphQLParserModule.IntString")
          createdAt: created_at @ppxCustom(module: "GraphQLParserModule.Date")
          metadata
          group_members_aggregate @ppxAs(type: "Group.group_members_aggregate_t") {
            aggregate @ppxAs(type: "Group.aggregate_t") {
              count
            }
          }
          group_policies_aggregate @ppxAs(type: "Group.group_policies_aggregate_t") {
            aggregate @ppxAs(type: "Group.aggregate_t") {
              count
            }
          }
          group_proposals_aggregate @ppxAs(type: "Group.group_proposals_aggregate_t") {
            aggregate @ppxAs(type: "Group.aggregate_t") {
              count
            }
          }
      }
  }
`)

let get = id => {
  let result = SingleConfig.use({id: id})

  result
  ->Sub.fromData
  ->Sub.flatMap(({groups_by_pk}) => {
    switch groups_by_pk {
    | Some(data) => Sub.resolve(data->Group.toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.groups->Belt.Array.map(Group.toExternal))
}

let getProposals = (~groupID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = ProposalConfig.use({groupID, limit: pageSize, offset})

  result
  ->Sub.fromData
  ->Sub.map(internal => internal.group_proposals->Belt.Array.map(Group.Proposal.toExternal))
}

let getPolicies = (~groupID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = PolicyConfig.use({groupID, limit: pageSize, offset})

  result
  ->Sub.fromData
  ->Sub.map(internal => internal.group_policies->Belt.Array.map(Group.Policy.toExternal))
}

let getMembers = (~groupID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MemberConfig.use({groupID, limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.group_members)
}
