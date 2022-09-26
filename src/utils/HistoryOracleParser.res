type t = {
  timestamp: int,
  status: bool,
}

let day = 86400

let parse = (~oracleStatusReports, ~startDate, ()) => {
  let normalizedDateReports = oracleStatusReports->Belt.List.map(({timestamp, status}) =>
    if status {
      {
        timestamp: (timestamp / day + 1) * day,
        status: true,
      }
    } else {
      {
        timestamp: timestamp / day * day,
        status: false,
      }
    }
  )

  let addedHeadNormalizedDateReports =
    normalizedDateReports
    ->Belt.List.add({
      timestamp: startDate,
      status: !(normalizedDateReports->Belt.List.headExn).status,
    })
    ->Belt.List.sort(({timestamp: t1, status: s1}, {timestamp: t2, _}) =>
      switch compare(t1, t2) {
      | 0 => s1 ? 1 : -1
      | v => v
      }
    )

  let addedTailNormalizedReports =
    normalizedDateReports
    ->Belt.List.concat(list{
      {
        timestamp: MomentRe.momentNow()
        ->MomentRe.Moment.defaultUtc
        ->MomentRe.Moment.startOf(#day, _)
        ->MomentRe.Moment.add(~duration=MomentRe.duration(1., #days))
        ->MomentRe.Moment.toUnix,
        // Note: this status can be whatever.
        status: false,
      },
    })
    ->Belt.List.sort(({timestamp: t1, status: s1}, {timestamp: t2, _}) =>
      switch compare(t1, t2) {
      | 0 => s1 ? 1 : -1
      | v => v
      }
    )

  let optimizedDate = addedHeadNormalizedDateReports->Belt.List.zip(addedTailNormalizedReports)

  let parsedDate =
    optimizedDate
    ->Belt.List.map(each => {
      let ({timestamp: st, status}, {timestamp: en, _}) = each
      Belt.List.makeBy((en - st) / day, idx => {timestamp: st + day * idx, status})
    })
    ->Belt.List.flatten
    ->Belt.List.toArray
    ->Belt.Array.sliceToEnd(1)

  parsedDate
}
