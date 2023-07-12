type sort_direction_t =
  | ASC
  | DESC

type sort_t =
  | ID
  | Name
  | Version
  | Request
  | Response

type sort_by_t =
  | IDAsc
  | IDDesc
  | NameAsc
  | NameDesc
  | VersionAsc
  | VersionDesc
  | RequestAsc
  | RequestDesc
  | ResponseAsc
  | ResponseDesc

let getDirection = x =>
  switch x {
  | IDAsc
  | NameAsc
  | VersionAsc
  | RequestAsc
  | ResponseAsc =>
    ASC
  | IDDesc
  | NameDesc
  | VersionDesc
  | RequestDesc
  | ResponseDesc =>
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

let defaultCompare = (a: OracleScriptSub.t_with_stats, b: OracleScriptSub.t_with_stats) =>
  if a.name != b.name {
    compare(b.id, a.id)
  } else {
    compareString(b.name, a.name)
  }

let sorting = (oraclescripts: array<OracleScriptSub.t_with_stats>, ~sortedBy, ~direction) => {
  oraclescripts
  ->Belt.List.fromArray
  ->Belt.List.sort((a, b) => {
    let result = {
      switch (sortedBy, direction) {
      | (ID, ASC) => compare(a.id, b.id)
      | (ID, DESC) => compare(b.id, a.id)
      | (Name, ASC) => compareString(b.name, a.name)
      | (Name, DESC) => compareString(a.name, b.name)
      | (Version, ASC) => compareVersion(a.version, b.version)
      | (Version, DESC) => compareVersion(b.version, a.version)
      | (Request, ASC) => compare(a.stat.count, b.stat.count)
      | (Request, DESC) => compare(b.stat.count, a.stat.count)
      | (Response, ASC) => compare(a.stat.responseTime, b.stat.responseTime)
      | (Response, DESC) => compare(b.stat.responseTime, a.stat.responseTime)
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
  | ID => "Oracle Script ID"
  | Name => "Oracle Script Name"
  | Version => "Latest Version"
  | Request => "Most 24 hr Requested"
  | Response => "Response Time"
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
  | VersionAsc
  | VersionDesc =>
    Version
  | RequestAsc
  | RequestDesc =>
    Request
  | ResponseAsc
  | ResponseDesc =>
    Response
  }
}
