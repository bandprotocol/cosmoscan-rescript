open Jest
open HistoryOracleParser
open Expect

let getDayAgo = days =>
  MomentRe.momentNow()
  ->MomentRe.Moment.defaultUtc
  ->MomentRe.Moment.startOf(#day, _)
  ->MomentRe.Moment.subtract(~duration=MomentRe.duration(days->Belt.Int.toFloat, #days))
  ->MomentRe.Moment.toUnix

describe("Expect HistoryOracleParser works correctly", () => {
  let dates = Belt.Array.makeBy(5, i => getDayAgo(i))->Belt.Array.reverse

  test("should be parse from event(true) at start date", () =>
    expect(
      parse(
        ~oracleStatusReports=list{{timestamp: dates[0] + 5000, status: true}},
        ~startDate=dates[0],
        (),
      ),
    )->toEqual([
      {timestamp: dates[1], status: true},
      {timestamp: dates[2], status: true},
      {timestamp: dates[3], status: true},
      {timestamp: dates[4], status: true},
    ])
  )

  test("should be parse from 1 events (true)", () =>
    expect(
      parse(
        ~oracleStatusReports=list{{timestamp: dates[1] + 5000, status: true}},
        ~startDate=dates[0],
        (),
      ),
    )->toEqual([
      {timestamp: dates[1], status: false},
      {timestamp: dates[2], status: true},
      {timestamp: dates[3], status: true},
      {timestamp: dates[4], status: true},
    ])
  )

  test("should be parse from 1 events (false)", () =>
    expect(
      parse(
        ~oracleStatusReports=list{{timestamp: dates[2] + 5000, status: false}},
        ~startDate=dates[0],
        (),
      ),
    )->toEqual([
      {timestamp: dates[1], status: true},
      {timestamp: dates[2], status: false},
      {timestamp: dates[3], status: false},
      {timestamp: dates[4], status: false},
    ])
  )

  test("should be parse from multi events in one day", () =>
    expect(
      parse(
        ~oracleStatusReports=list{
          {timestamp: dates[2] + 1000, status: false},
          {timestamp: dates[2] + 4200, status: true},
          {timestamp: dates[2] + 5000, status: false},
          {timestamp: dates[2] + 12000, status: true},
        },
        ~startDate=dates[0],
        (),
      ),
    )->toEqual([
      {timestamp: dates[1], status: true},
      {timestamp: dates[2], status: false},
      {timestamp: dates[3], status: true},
      {timestamp: dates[4], status: true},
    ])
  )

  test("should be parse from multi events in one day and false in last day", () =>
    expect(
      parse(
        ~oracleStatusReports=list{
          {timestamp: dates[2] + 1000, status: false},
          {timestamp: dates[2] + 4200, status: true},
          {timestamp: dates[2] + 5000, status: false},
          {timestamp: dates[2] + 12000, status: true},
          {timestamp: dates[4] + 12000, status: false},
        },
        ~startDate=dates[0],
        (),
      ),
    )->toEqual([
      {timestamp: dates[1], status: true},
      {timestamp: dates[2], status: false},
      {timestamp: dates[3], status: true},
      {timestamp: dates[4], status: false},
    ])
  )
})
