type aggregate_t = {count: int}
type account_t = {address: Address.t}

type group_member_t = {
  account: account_t,
  metadata: string,
  weight: int,
  addedAt: MomentRe.Moment.t,
}

type group_policy_t = {
  address: Address.t,
  decisionPolicy: Js.Json.t,
  createdAt: MomentRe.Moment.t,
  metadata: string,
}

type group_proposal_t = {id: ID.GroupProposal.t}

type t = {
  id: ID.Group.t,
  name: string,
  admin: Address.t,
  totalWeight: int,
  createdAt: MomentRe.Moment.t,
  metadata: string,
  memberCount: int,
  policiesCount: int,
  proposalsCount: int,
  proposalOnVoting: array<group_proposal_t>,
  description: string,
  website: string,
  forum: string,
}

type group_members_aggregate_t = {aggregate: option<aggregate_t>}
type group_policies_aggregate_t = {aggregate: option<aggregate_t>}
type group_proposals_aggregate_t = {aggregate: option<aggregate_t>}

type internal_t = {
  id: ID.Group.t,
  admin: Address.t,
  totalWeight: int,
  createdAt: MomentRe.Moment.t,
  metadata: string,
  group_members_aggregate: group_members_aggregate_t,
  group_policies_aggregate: group_policies_aggregate_t,
  group_proposals_aggregate: group_proposals_aggregate_t,
  proposalOnVoting: array<group_proposal_t>,
}

type metadata_t = {
  name: string,
  description: string,
  website: string,
  forum: string,
}

// TODO: extractMetadata
let extractMetadata = metadata => {
  name: "Group Name",
  description: "description",
  website: "website",
  forum: "forum",
}

let toExternal = ({
  id,
  admin,
  totalWeight,
  createdAt,
  metadata,
  group_members_aggregate,
  group_policies_aggregate,
  group_proposals_aggregate,
  proposalOnVoting,
}) => {
  let metadataExtracted = metadata->extractMetadata

  {
    id,
    name: metadataExtracted.name,
    admin,
    totalWeight,
    createdAt,
    metadata,
    memberCount: (group_members_aggregate.aggregate->Belt.Option.getExn).count,
    policiesCount: (group_policies_aggregate.aggregate->Belt.Option.getExn).count,
    proposalsCount: (group_proposals_aggregate.aggregate->Belt.Option.getExn).count,
    proposalOnVoting,
    description: metadataExtracted.description,
    website: metadataExtracted.website,
    forum: metadataExtracted.forum,
  }
}

module PolicyType = {
  type t = Threshold | Percentage | Unspecified

  let parse = str => {
    switch str {
    | "cosmos.group.v1.ThresholdDecisionPolicy" => Threshold
    | "cosmos.group.v1.PercentageDecisionPolicy" => Percentage
    | _ => Unspecified
    }
  }

  let toString = _type => {
    switch _type {
    | Threshold => "Threshold"
    | Percentage => "Percentage"
    | Unspecified => "Unspecified"
    }
  }
}

module DecisionPolicy = {
  type windows_t = {
    votingPeriod: float,
    minExecutionPeriod: float,
  }

  let windowDecoder = {
    open JsonUtils.Decode
    buildObject(json => {
      votingPeriod: json.required(list{"voting_period"}, JsonUtils.Decode.float),
      minExecutionPeriod: json.required(list{"min_execution_period"}, JsonUtils.Decode.float),
    })
  }

  type t = {
    percentage: option<int>,
    threshold: option<int>,
    windows: windows_t,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      percentage: json.optional(list{"percentage"}, intstr),
      threshold: json.optional(list{"threshold"}, intstr),
      windows: json.required(list{"windows"}, windowDecoder),
    })
  }

  let getValue = (policyType, decisionPolicy) =>
    switch policyType {
    | PolicyType.Threshold => decisionPolicy.threshold->Belt.Option.getExn
    | Percentage => decisionPolicy.percentage->Belt.Option.getExn
    | Unspecified => 0
    }
}

module Policy = {
  type t = {
    _type: PolicyType.t,
    address: Address.t,
    value: int,
    votingPeriod: MomentRe.Duration.t,
    minExecutionPeriod: MomentRe.Duration.t,
    createdAt: MomentRe.Moment.t,
    metadata: string,
    version: int,
  }

  type internal_t = {
    _type: PolicyType.t,
    address: Address.t,
    decisionPolicy: Js.Json.t,
    createdAt: MomentRe.Moment.t,
    metadata: string,
    version: int,
  }

  let toExternal = ({_type, address, decisionPolicy, createdAt, metadata, version}) => {
    let decisionPolicyDecoded = decisionPolicy->JsonUtils.Decode.mustDecode(DecisionPolicy.decode)

    {
      _type,
      address,
      value: _type->DecisionPolicy.getValue(decisionPolicyDecoded),
      votingPeriod: decisionPolicyDecoded.windows.votingPeriod
      ->(x => x /. 1e9)
      ->MomentRe.duration(#seconds),
      minExecutionPeriod: decisionPolicyDecoded.windows.minExecutionPeriod
      ->(x => x /. 1e9)
      ->MomentRe.duration(#seconds),
      createdAt,
      metadata,
      version,
    }
  }
}

module Proposal = {
  type t = {
    id: ID.GroupProposal.t,
    title: string,
    groupID: ID.Group.t,
    groupName: string,
    messages: list<Msg.result_t>,
    policyType: PolicyType.t,
    yesVote: float,
    totalVote: float,
    status: GroupProposalStatus.t,
    summary: string,
    submitTime: MomentRe.Moment.t,
    votingPeriodEnd: MomentRe.Moment.t,
    result: string,
  }

  type group_policy_internal_t = {
    _type: string,
    decisionPolicy: Js.Json.t,
  }
  type group_internal_t = {metadata: string}

  type internal_t = {
    id: ID.GroupProposal.t,
    title: string,
    groupID: ID.Group.t,
    group: group_internal_t,
    messages: Js.Json.t,
    group_policy: group_policy_internal_t,
    status: GroupProposalStatus.t,
    yesVote: option<float>,
    noVote: option<float>,
    noWithVetoVote: option<float>,
    abstainVote: option<float>,
    summary: string,
    submitTime: MomentRe.Moment.t,
    votingPeriodEnd: MomentRe.Moment.t,
  }

  let toExternal = ({
    id,
    title,
    groupID,
    group,
    messages,
    group_policy,
    status,
    yesVote,
    noVote,
    noWithVetoVote,
    abstainVote,
    summary,
    submitTime,
    votingPeriodEnd,
  }) => {
    let totalVote =
      yesVote->Belt.Option.getExn +.
      noVote->Belt.Option.getExn +.
      noWithVetoVote->Belt.Option.getExn +.
      abstainVote->Belt.Option.getExn

    let groupMetadataExtracted = group.metadata->extractMetadata

    {
      id,
      title,
      groupID,
      groupName: groupMetadataExtracted.name,
      messages: {
        let msg = messages->Js.Json.decodeArray
        switch msg {
        | Some(msg) => msg->Belt.List.fromArray
        | None => []->Belt.List.fromArray
        }->Belt.List.map(each => Msg.decodeMsg(each, false))
      },
      policyType: group_policy._type->PolicyType.parse,
      yesVote: yesVote->Belt.Option.getExn,
      totalVote,
      status,
      summary,
      submitTime,
      votingPeriodEnd,
      result: switch group_policy._type->PolicyType.parse {
      | Threshold => yesVote->Belt.Option.getExn->Belt.Float.toString
      | Percentage => (yesVote->Belt.Option.getExn /. totalVote)->Belt.Float.toString
      | Unspecified => "Unspecified"
      },
    }
  }
}
