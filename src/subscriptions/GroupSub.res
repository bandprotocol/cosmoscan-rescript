module ProposalSingleConfig = %graphql(`
  subscription GroupProposal($groupID: Int!, $limit: Int!, $offset: Int!) {
    group_proposals(where: {group_id: { _eq: $groupID }}, limit: $limit, offset: $offset) @ppxAs(type: "Group.Proposal.internal_t") {
      id @ppxCustom(module:"GraphQLParserModule.GroupProposalID")
      title
      groupID: group_id @ppxCustom(module: "GraphQLParserModule.GroupID")
      group @ppxAs(type: "Group.Proposal.group_internal_t") {
        metadata
      }
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
      summary
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingPeriodEnd: voting_period_end @ppxCustom(module: "GraphQLParserModule.Date")
    }
  }
`)

module ProposalMultiConfig = %graphql(`
  subscription GroupProposal($limit: Int!, $offset: Int!) {
    group_proposals(limit: $limit, offset: $offset) @ppxAs(type: "Group.Proposal.internal_t") {
      id @ppxCustom(module:"GraphQLParserModule.GroupProposalID")
      title
      groupID: group_id @ppxCustom(module: "GraphQLParserModule.GroupID")
      group @ppxAs(type: "Group.Proposal.group_internal_t") {
        metadata
      }
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
      summary
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingPeriodEnd: voting_period_end @ppxCustom(module: "GraphQLParserModule.Date")
    }
  }
`)

module ProposalByAccountConfig = %graphql(`
  subscription GroupProposal($proposers: String!, $limit: Int!, $offset: Int!) {
    group_proposals(where: {proposers: { _eq: $proposers }}, limit: $limit, offset: $offset) @ppxAs(type: "Group.Proposal.internal_t") {
      id @ppxCustom(module:"GraphQLParserModule.GroupProposalID")
      title
      groupID: group_id @ppxCustom(module: "GraphQLParserModule.GroupID")
      group @ppxAs(type: "Group.Proposal.group_internal_t") {
        metadata
      }
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
      summary
      submitTime: submit_time @ppxCustom(module: "GraphQLParserModule.Date")
      votingPeriodEnd: voting_period_end @ppxCustom(module: "GraphQLParserModule.Date")
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
      proposalOnVoting: group_proposals(where: {status: {_eq: "PROPOSAL_STATUS_VOTING_PERIOD"}}) @ppxAs(type: "Group.group_proposal_t") {
        id @ppxCustom(module:"GraphQLParserModule.GroupProposalID")
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
          proposalOnVoting: group_proposals(where: {status: {_eq: "PROPOSAL_STATUS_VOTING_PERIOD"}}) @ppxAs(type: "Group.group_proposal_t") {
            id @ppxCustom(module:"GraphQLParserModule.GroupProposalID")
          }
      }
  }
`)

module GroupByAccountConfig = %graphql(`
  subscription Groups($address: String!, $limit: Int!, $offset: Int!)  {
      groups(where: {group_members: {account: {address: {_eq: $address}}} }, limit: $limit, offset: $offset) @ppxAs(type: "Group.internal_t"){
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
          proposalOnVoting: group_proposals(where: {status: {_eq: "PROPOSAL_STATUS_VOTING_PERIOD"}}) @ppxAs(type: "Group.group_proposal_t") {
            id @ppxCustom(module:"GraphQLParserModule.GroupProposalID")
          }
      }
  }
`)

let get = groupID => {
  let result = SingleConfig.use({id: groupID->ID.Group.toInt})

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

let getListByAccount = (~address, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = GroupByAccountConfig.use({address, limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.groups->Belt.Array.map(Group.toExternal))
}

let getProposalsByGroup = (~groupID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = ProposalSingleConfig.use({groupID: groupID->ID.Group.toInt, limit: pageSize, offset})

  result
  ->Sub.fromData
  ->Sub.map(internal => internal.group_proposals->Belt.Array.map(Group.Proposal.toExternal))
}

let getProposals = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = ProposalMultiConfig.use({limit: pageSize, offset})

  result
  ->Sub.fromData
  ->Sub.map(internal => internal.group_proposals->Belt.Array.map(Group.Proposal.toExternal))
}

let getProposalsByAccount = (~address, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = ProposalByAccountConfig.use({proposers: address, limit: pageSize, offset})

  result
  ->Sub.fromData
  ->Sub.map(internal => internal.group_proposals->Belt.Array.map(Group.Proposal.toExternal))
}

let getPolicies = (~groupID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = PolicyConfig.use({groupID: groupID->ID.Group.toInt, limit: pageSize, offset})

  result
  ->Sub.fromData
  ->Sub.map(internal => internal.group_policies->Belt.Array.map(Group.Policy.toExternal))
}

let getMembers = (~groupID, ~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MemberConfig.use({groupID: groupID->ID.Group.toInt, limit: pageSize, offset})

  result->Sub.fromData->Sub.map(internal => internal.group_members)
}
