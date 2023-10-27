type sort_direction_t =
  | ASC
  | DESC

type sort_t =
  | ID
  | Name
  | GroupID
  | ProposalStatus

type sort_by_t =
  | IDAsc
  | IDDesc
  | NameAsc
  | NameDesc
  | GroupIDAsc
  | GroupIDDesc
  | ProposalStatusAsc
  | ProposalStatusDesc

let getDirection = x =>
  switch x {
  | IDAsc
  | NameAsc
  | GroupIDAsc
  | ProposalStatusAsc =>
    ASC
  | IDDesc
  | NameDesc
  | GroupIDDesc
  | ProposalStatusDesc =>
    DESC
  }
let compareString = (a, b) => {
  let removeEmojiRegex = %re(`/([\u2700-\u27BF]|[\uE000-\uF8FF]|\uD83C[\uDC00-\uDFFF]|\uD83D[\uDC00-\uDFFF]|[\u2011-\u26FF]|\uD83E[\uDD10-\uDDFF])/g`)
  // let removeEmojiRegex = %re("/([\u2700-\u27BF]|[\uE000-\uF8FF]|/g")
  let a_ = a->Js.String2.replaceByRe(removeEmojiRegex, "")
  let b_ = b->Js.String2.replaceByRe(removeEmojiRegex, "")
  Js.String2.localeCompare(a_, b_)->Belt.Float.toInt
}

let compareVersion = (a: OracleScriptSub.version_t, b: OracleScriptSub.version_t) => {
  let parseVersion = v => {
    switch v {
    | OracleScriptSub.Ok => "upgraded"
    | Redeploy => "redeploy"
    | Nothing => "xxx"
    }
  }

  compareString(a->parseVersion, b->parseVersion)
}

let defaultCompare = (a: Group.Proposal.t, b: Group.Proposal.t) =>
  if a.title != b.title {
    compare(b.id, a.id)
  } else {
    compareString(b.title, a.title)
  }

let sorting = (proposals: array<Group.Proposal.t>, ~sortedBy, ~direction) => {
  proposals
  ->Belt.List.fromArray
  ->Belt.List.sort((a, b) => {
    let result = {
      switch (sortedBy, direction) {
      | (ID, ASC) => compare(a.id, b.id)
      | (ID, DESC) => compare(b.id, a.id)
      | (Name, ASC) => Js.String2.localeCompare(b.title, a.title)->Belt.Float.toInt
      | (Name, DESC) => Js.String2.localeCompare(a.title, b.title)->Belt.Float.toInt
      | (GroupID, ASC) => compare(a.groupID, b.groupID)
      | (GroupID, DESC) => compare(b.groupID, a.groupID)
      | (ProposalStatus, ASC) => compare(a.status, b.status)
      | (ProposalStatus, DESC) => compare(b.status, a.status)
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
  | ID => "Proposal ID"
  | Name => "Proposal Name"
  | GroupID => "Group"
  | ProposalStatus => "Status"
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
  | GroupIDAsc
  | GroupIDDesc =>
    GroupID
  | ProposalStatusAsc
  | ProposalStatusDesc =>
    ProposalStatus
  }
}
