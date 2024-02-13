type t = {
  timestamp: int,
  status: bool,
  failDurationInSecond: float,
  failPercentage: float,
}

let day = 86400
let daySeconds = 86400.

let parse = (~oracleStatusReports, ~startDate, ()) => {
  let normalizedDateReports = oracleStatusReports->Belt.List.map(({timestamp, status}) => {
    if status {
      {
        timestamp: (timestamp / day + 1) * day,
        status: true,
        failDurationInSecond: 0.,
        failPercentage: 0.,
      }
    } else {
      {
        timestamp: timestamp / day * day,
        status: false,
        failDurationInSecond: 0.,
        failPercentage: 0.,
      }
    }
  })

  let addedHeadNormalizedDateReports =
    normalizedDateReports
    ->Belt.List.add({
      timestamp: startDate,
      status: !(normalizedDateReports->Belt.List.headExn).status,
      failDurationInSecond: 0.,
      failPercentage: 0.,
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
        failDurationInSecond: 0.,
        failPercentage: 0.,
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
      Belt.List.makeBy((en - st) / day, idx => {
        timestamp: st + day * idx,
        status,
        failDurationInSecond: 0.,
        failPercentage: 0.,
      })
    })
    ->Belt.List.flatten
    ->Belt.List.toArray
    ->Belt.Array.sliceToEnd(1)

  parsedDate
}

let getTotalDayDurationInSeconds = date => {
  let startOfDay = MomentRe.moment(date)->MomentRe.Moment.startOf(#day, _)->MomentRe.Moment.toUnix

  let endOfDay =
    MomentRe.moment(date)
    ->MomentRe.Moment.startOf(#day, _)
    ->MomentRe.Moment.add(~duration=MomentRe.duration(1., #days))
    ->MomentRe.Moment.toUnix

  endOfDay
  ->GraphQLParser.fromUnixSecond
  ->MomentRe.diff(startOfDay->GraphQLParser.fromUnixSecond, #seconds)
}

let parseToDurationFormat = (~oracleStatusReports, ~startDate, ()) => {
  let endDate =
    MomentRe.momentNow()
    ->MomentRe.Moment.defaultUtc
    ->MomentRe.Moment.startOf(#day, _)
    ->MomentRe.Moment.add(~duration=MomentRe.duration(1., #days))
    ->MomentRe.Moment.toUnix
  let logs = []

  // loop 90 days
  for idx in 0 to 89 {
    let currentDate =
      MomentRe.momentNow()
      ->MomentRe.Moment.defaultUtc
      ->MomentRe.Moment.startOf(#day, _)
      ->MomentRe.Moment.subtract(~duration=MomentRe.duration((89 - idx)->Belt.Int.toFloat, #days))

    // convert currentDate to string and to iso date string
    let dateKey = currentDate->MomentRe.Moment.toISOString

    let totalDayDurationInSeconds = getTotalDayDurationInSeconds(dateKey)
    let downtimeList = []
    let downtimeInSeconds = ref(0.)

    // loop through the oracleStatusReports
    oracleStatusReports->Belt.List.forEachWithIndex((i, {timestamp, status}) => {
      //change timestamp int to Moment.Moment.t type
      let statusDate = timestamp->GraphQLParser.fromUnixSecond

      if (
        statusDate->MomentRe.Moment.toISOString->Js.String2.slice(~from=0, ~to_=10) ===
          dateKey->Js.String2.slice(~from=0, ~to_=10) && !status
      ) {
        let nextStatusIndex = oracleStatusReports->Belt.List.getExn(i + 1) // downtime end
        let downtimeStart = statusDate->MomentRe.Moment.toUnix
        let downtimeEnd = ref(nextStatusIndex.timestamp)

        // if the next status is not the same day, set the downtime end to the end of the day
        if (
          downtimeEnd.contents
          ->GraphQLParser.fromUnixSecond
          ->MomentRe.Moment.toISOString
          ->Js.String2.slice(~from=0, ~to_=10) !== dateKey->Js.String2.slice(~from=0, ~to_=10)
        ) {
          downtimeEnd.contents =
            currentDate
            ->MomentRe.Moment.startOf(#day, _)
            ->MomentRe.Moment.add(~duration=MomentRe.duration(1., #days))
            ->MomentRe.Moment.toUnix
        }

        let downtimeDuration =
          downtimeEnd.contents
          ->GraphQLParser.fromUnixSecond
          ->MomentRe.diff(downtimeStart->GraphQLParser.fromUnixSecond, #seconds)

        downtimeInSeconds.contents = downtimeInSeconds.contents +. downtimeDuration
      }
    })

    logs->Belt.Array.push({
      timestamp: currentDate->MomentRe.Moment.toUnix,
      status: oracleStatusReports->Belt.List.length === 1
        ? (oracleStatusReports->Belt.List.getExn(0)).status
        : downtimeInSeconds.contents === 0.,
      failPercentage: if oracleStatusReports->Belt.List.length === 1 {
        (oracleStatusReports->Belt.List.getExn(0)).status ? 0. : 100.
      } else {
        downtimeInSeconds.contents /. totalDayDurationInSeconds *. 100.
      },
      failDurationInSecond: downtimeInSeconds.contents,
    })
  }

  logs
}
