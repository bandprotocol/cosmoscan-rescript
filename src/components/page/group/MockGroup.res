// for mock only
// nothing can be used in production

type policy_type = Threshold | Percentage
type proposal_status = Passed | Rejected | VotingPeriod

type group_proposal = {
  id: ID.GroupProposal.t,
  name: string,
  message: array<string>,
  _policy_type: policy_type,
  result: string,
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

let policy_type_to_string = policy_type => {
  switch policy_type {
  | Threshold => "Threshold"
  | Percentage => "Percentage"
  }
}

let mock: group = {
  id: 1->ID.Group.fromInt,
  name: "mock group",
  proposals: [
    {
      id: 1->ID.GroupProposal.fromInt,
      name: "mock group proposal 1",
      message: ["Send"],
      _policy_type: Threshold,
      result: "10 (min5)",
      status: Passed,
    },
    {
      id: 2->ID.GroupProposal.fromInt,
      name: "mock group proposal 2",
      message: ["Withdraw"],
      _policy_type: Percentage,
      result: "60% /50%",
      status: Passed,
    },
    {
      id: 3->ID.GroupProposal.fromInt,
      name: "mock group proposal 3",
      message: ["Delegate"],
      _policy_type: Threshold,
      result: "10%",
      status: Passed,
    },
  ],
  members: [
    {
      address: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
      weight: 1,
      metadata: "metadata",
    },
    {
      address: "band10z6xjl9vjrk38zdmhsxc2w0tkl7ahzg954xw2y"->Address.fromBech32,
      weight: 2,
      metadata: "metadata",
    },
    {
      address: "band1ts0txaqa0sgq3x2gevhvaxez55fzn8pzju9jl9"->Address.fromBech32,
      weight: 3,
      metadata: "metadata",
    },
  ],
  policies: [
    {
      address: "band1dfc8q7h0auc8akhrkfaclln9nmaxuy49fpcjas"->Address.fromBech32,
      _type: Threshold,
      value: 1.,
      voting_period: 1,
      min_execution_period: 1,
    },
  ],
  information: {
    admin: "band120q5vvspxlczc8c72j7c3c4rafyndaelqccksu"->Address.fromBech32,
    total_member: 3,
    total_weight: 6,
    description: "Praesent vulputate lacus sed facilisis venenatis. Fusce vel ullamcorper velit. Donec vel elit sit amet neque pellentesque blandit eget id elit. In sollicitudin ",
    website: "example.com",
    forum: "forum.example.com",
    created_date: "2023-04-25 06:29:18",
  },
}
