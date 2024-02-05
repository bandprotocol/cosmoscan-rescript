type sort_direction_t =
  | ASC
  | DESC

type sort_t =
  | ID
  | Name
  | MembersCount
  | ProposalsCount
  | ProposalsOnVotingCount

type sort_by_t =
  | IDAsc
  | IDDesc
  | NameAsc
  | NameDesc
  | MembersCountAsc
  | MembersCountDesc
  | ProposalsCountAsc
  | ProposalsCountDesc
  | ProposalsOnVotingCountAsc
  | ProposalsOnVotingCountDesc

let getDirection = x =>
  switch x {
  | IDAsc
  | NameAsc
  | MembersCountAsc
  | ProposalsCountAsc
  | ProposalsOnVotingCountAsc =>
    ASC
  | IDDesc
  | NameDesc
  | MembersCountDesc
  | ProposalsCountDesc
  | ProposalsOnVotingCountDesc =>
    DESC
  }
let compareString = (a, b) => {
  let removeEmojiRegex = %re(`/([\u2700-\u27BF]|[\uE000-\uF8FF]|\uD83C[\uDC00-\uDFFF]|\uD83D[\uDC00-\uDFFF]|[\u2011-\u26FF]|\uD83E[\uDD10-\uDDFF])/g`)
  // let removeEmojiRegex = %re("/([\u2700-\u27BF]|[\uE000-\uF8FF]|/g")
  let a_ = a->Js.String2.replaceByRe(removeEmojiRegex, "")
  let b_ = b->Js.String2.replaceByRe(removeEmojiRegex, "")
  Js.String2.localeCompare(a_, b_)->Belt.Float.toInt
}

let defaultCompare = (a: Group.t, b: Group.t) =>
  if a.name != b.name {
    compare(b.id, a.id)
  } else {
    compareString(b.name, a.name)
  }

let sorting = (oraclescripts: array<Group.t>, ~sortedBy, ~direction) => {
  oraclescripts
  ->Belt.List.fromArray
  ->Belt.List.sort((a, b) => {
    let result = {
      switch (sortedBy, direction) {
      | (ID, ASC) => compare(a.id, b.id)
      | (ID, DESC) => compare(b.id, a.id)
      | (Name, ASC) => compareString(b.name, a.name)
      | (Name, DESC) => compareString(a.name, b.name)
      | (MembersCount, ASC) => compare(a.memberCount, b.memberCount)
      | (MembersCount, DESC) => compare(b.memberCount, a.memberCount)
      | (ProposalsCount, ASC) => compare(a.proposalsCount, b.proposalsCount)
      | (ProposalsCount, DESC) => compare(b.proposalsCount, a.proposalsCount)
      | (ProposalsOnVotingCount, ASC) => compare(a.proposalOnVotingCount, b.proposalOnVotingCount)
      | (ProposalsOnVotingCount, DESC) => compare(b.proposalOnVotingCount, a.proposalOnVotingCount)
      }
    }
    if result != 0 {
      result
    } else {
      defaultCompare(a, b)
    }
  })
  ->Belt.List.toArray
}

let parseSortString = sortOption => {
  switch sortOption {
  | ID => "Group ID"
  | Name => "Group Name"
  | MembersCount => "Members"
  | ProposalsCount => "Proposals"
  | ProposalsOnVotingCount => "Proposals On Voting"
  }
}

let parseDirection = dir => {
  switch dir {
  | ASC => "ASC"
  | DESC => "DESC"
  }
}

let parseSortby = s => {
  switch s {
  | IDAsc
  | IDDesc =>
    ID
  | NameAsc
  | NameDesc =>
    Name
  | MembersCountAsc
  | MembersCountDesc =>
    MembersCount
  | ProposalsCountAsc
  | ProposalsCountDesc =>
    ProposalsCount
  | ProposalsOnVotingCountAsc
  | ProposalsOnVotingCountDesc =>
    ProposalsOnVotingCount
  }
}
