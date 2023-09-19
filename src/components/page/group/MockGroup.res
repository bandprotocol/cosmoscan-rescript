// for mock only
// nothing can be used in production

type policy_type = Threshold | Percentage
type proposal_status = Passed | Rejected | VotingPeriod

type group_proposal = {
  id: ID.GroupProposal.t,
  name: string,
  message: array<string>,
  _policy_type: policy_type,
  result: float,
  status: proposal_status,
}

type group_policy = {
  address: Address.t,
  _type: policy_type,
  value: float,
  voting_period: int,
  min_execution_period: int,
}

type group_member = {
  address: Address.t,
  weight: int,
  metadata: string,
}

type group_information = {
  admin: Address.t,
  total_member: int,
  total_weight: int,
  description: string,
  website: string,
  forum: string,
  created_date: string,
}

type group = {
  id: ID.Group.t,
  name: string,
  proposals: array<group_proposal>,
  members: array<group_member>,
  policies: array<group_policy>,
  information: group_information,
}

let mock: group = {
  id: 1->ID.Group.fromInt,
  name: "mock group",
  proposals: [
    {
      id: 1->ID.GroupProposal.fromInt,
      name: "mock group proposal 1",
      message: ["msg"],
      _policy_type: Threshold,
      result: 100.,
      status: Passed,
    },
  ],
  members: [
    {
      address: Address("band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"),
      weight: 1,
      metadata: "metadata",
    },
  ],
  policies: [
    {
      address: Address("band1dfc8q7h0auc8akhrkfaclln9nmaxuy49fpcjas"),
      _type: Threshold,
      value: 1.,
      voting_period: 1,
      min_execution_period: 1,
    },
  ],
  information: {
    admin: Address("band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"),
    total_member: 1,
    total_weight: 1,
    description: "description",
    website: "website",
    forum: "forum",
    created_date: "created_date",
  },
}
