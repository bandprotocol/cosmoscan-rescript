type sort_direction_t =
  | ASC
  | DESC

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

let sorting = (oraclescripts: array<OracleScriptSub.t_with_stats>, sortedBy) => {
  oraclescripts
  ->Belt.List.fromArray
  ->Belt.List.sort((a, b) => {
    let result = {
      switch sortedBy {
      | IDAsc => compare(a.id, b.id)
      | IDDesc => compare(b.id, a.id)
      | NameAsc => compareString(b.name, a.name)
      | NameDesc => compareString(a.name, b.name)
      | VersionAsc => compareVersion(a.version, b.version)
      | VersionDesc => compareVersion(b.version, a.version)
      | RequestAsc => compare(a.stat.count, b.stat.count)
      | RequestDesc => compare(b.stat.count, a.stat.count)
      | ResponseAsc => compare(a.stat.responseTime, b.stat.responseTime)
      | ResponseDesc => compare(b.stat.responseTime, a.stat.responseTime)
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
