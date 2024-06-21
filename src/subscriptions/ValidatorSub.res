module Mini = {
  type t = {
    consensusAddress: string,
    operatorAddress: Address.t,
    moniker: string,
    identity: string,
  }
}

module ValidatorAggCount = {
  type t = int
  type aggregate_t = {count: int}
  type internal_t = {aggregate: option<aggregate_t>}

  let toExternal = ({count}: aggregate_t) => count
}

module TotalBondedAmount = {
  type t = Coin.t
  type sum_t = {tokens: option<Js.Json.t>}
  type aggregate_t = {sum: option<sum_t>}
  type internal_t = {aggregate: option<aggregate_t>}

  let toExternal = (sum: sum_t) => sum.tokens->GraphQLParser.coinWithDefault
}

module SingleConfig = %graphql(`
      subscription Validator($operator_address: String!) {
        validators_by_pk(operator_address: $operator_address) @ppxAs(type: "Validator.raw_t") {
          operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
          consensusAddress: consensus_address
          moniker
          identity
          website
          tokens @ppxCustom(module: "GraphQLParserModule.Coin")
          commissionRate: commission_rate @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
          commissionMaxChange: commission_max_change@ppxCustom(module: "GraphQLParserModule.FloatStringExn")
          commissionMaxRate: commission_max_rate @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
          jailed
          details
          oracleStatus: status
        }
      }
`)

module MultiConfig = %graphql(`
  subscription Validators($jailed: Boolean!) {
    validators(where: {jailed: {_eq: $jailed}}, order_by: [{tokens: desc, moniker: asc}]) @ppxAs(type: "Validator.raw_t") {
      operatorAddress: operator_address @ppxCustom(module: "GraphQLParserModule.Address")
      consensusAddress: consensus_address
      moniker
      identity
      website
      jailed
      oracleStatus: status
      details
      tokens @ppxCustom(module: "GraphQLParserModule.Coin")
      commissionRate: commission_rate @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
      commissionMaxChange: commission_max_change @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
      commissionMaxRate: commission_max_rate @ppxCustom(module: "GraphQLParserModule.FloatStringExn")
    }
  }
`)

module ValidatorCountConfig = %graphql(`
  subscription ValidatorCount {
    validators_aggregate @ppxAs(type: "ValidatorAggCount.internal_t") {
      aggregate @ppxAs(type: "ValidatorAggCount.aggregate_t") {
        count
      }
    }
  }
`)

module ValidatorCountByJailedConfig = %graphql(`
  subscription ValidatorCountByJailed($jailed: Boolean!) {
    validators_aggregate(where: {jailed: {_eq: $jailed}})  @ppxAs(type: "ValidatorAggCount.internal_t") {
      aggregate @ppxAs(type: "ValidatorAggCount.aggregate_t"){
        count
      }
    }
  }
`)

module TotalBondedAmountConfig = %graphql(`
  subscription TotalBondedAmount {
    validators_aggregate @ppxAs(type: "TotalBondedAmount.internal_t") {
      aggregate @ppxAs(type: "TotalBondedAmount.aggregate_t") {
        sum @ppxAs(type: "TotalBondedAmount.sum_t") {
          tokens
        }
      }
    }
  }
`)

module MultiLast100VotedConfig = %graphql(`
  subscription ValidatorsLast25Voted {
    validator_last_100_votes {
      consensus_address
      count
      voted
    }
  }
`)

module SingleLast100VotedConfig = %graphql(`
  subscription ValidatorLast25Voted($consensusAddress: String!) {
    validator_last_100_votes(where: {consensus_address: {_eq: $consensusAddress}}) {
      count
      voted
    }
  }
`)

module SingleLast100ListConfig = %graphql(`
  subscription SingleLast100Voted($consensusAddress: String!) {
    validator_votes(limit: 100, where: {validator: {consensus_address: {_eq: $consensusAddress}}}, order_by: [{block_height: desc}]) {
    block_height
    consensus_address
    voted
      block {
        proposer
      }
    }
  }
`)

module HistoricalOracleStatusesConfig = %graphql(`
  subscription HistoricalOracleStatuses($operatorAddress: String!, $greater: timestamp!) {
    historical_oracle_statuses(where: {operator_address: {_eq: $operatorAddress}, timestamp: {_gte: $greater}}) {
      operator_address
      status
      timestamp
    }
  }
`)

let get = operator_address => {
  let result = SingleConfig.use({operator_address: operator_address->Address.toOperatorBech32})

  result
  ->Sub.fromData
  ->Sub.flatMap(({validators_by_pk}) => {
    switch validators_by_pk {
    | Some(data) => Sub.resolve(data->Validator.toExternal(0))
    | None => Sub.NoData
    }
  })
}

let getList = (~isActive, ()) => {
  let result = MultiConfig.use({jailed: !isActive})

  result
  ->Sub.fromData
  ->Sub.map(({validators}) =>
    validators->Belt.Array.mapWithIndex((idx, each) => Validator.toExternal(each, idx + 1))
  )
}

let avgCommission = (~isActive, ()) => {
  let result = MultiConfig.use({jailed: !isActive})

  result
  ->Sub.fromData
  ->Sub.map(x => {
    let exclude100percent =
      x.validators->Belt_Array.keep(({commissionRate}) => commissionRate != 1.)
    let length = Belt_Array.length(exclude100percent) |> Belt.Int.toFloat

    exclude100percent
    ->Belt_Array.reduce(0., (acc, {commissionRate}) => acc +. commissionRate)
    ->(sum => sum /. length *. 100.)
  })
}

let count = () => {
  let result = ValidatorCountConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(({validators_aggregate}) =>
    validators_aggregate.aggregate->Belt.Option.getExn->(y => y->ValidatorAggCount.toExternal)
  )
}

let countByActive = isActive => {
  let result = ValidatorCountByJailedConfig.use({jailed: !isActive})

  result
  ->Sub.fromData
  ->Sub.map(({validators_aggregate}) =>
    validators_aggregate.aggregate->Belt.Option.getExn->(y => y->ValidatorAggCount.toExternal)
  )
}

let getTotalBondedAmount = () => {
  let result = TotalBondedAmountConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(a =>
    a.validators_aggregate.aggregate
    ->Belt.Option.getExn
    ->((y: TotalBondedAmount.aggregate_t) => y.sum)
    ->Belt.Option.getExn
    ->TotalBondedAmount.toExternal
  )
}

let getListVotesBlock = () => {
  let result = MultiLast100VotedConfig.use()

  result
  ->Sub.fromData
  ->Sub.map(x =>
    x.validator_last_100_votes->Belt.Array.map((each): Validator.validator_vote_t => {
      consensusAddress: each.consensus_address->Belt.Option.getExn->Address.fromHex,
      count: each.count->Belt.Option.getExn->GraphQLParser.int64,
      voted: each.voted->Belt.Option.getExn,
    })
  )
}

let getUptime = consensusAddress => {
  let result = SingleLast100VotedConfig.use({
    consensusAddress: consensusAddress->Address.toHex,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(({validator_last_100_votes}) => {
    let signedBlock =
      validator_last_100_votes
      ->Belt.Array.keep(each => each.voted == Some(true))
      ->Belt.Array.get(0)
      ->Belt.Option.flatMap(each => each.count)
      ->Belt.Option.mapWithDefault(0, GraphQLParser.int64)
      ->Belt.Float.fromInt

    let missedBlock =
      validator_last_100_votes
      ->Belt.Array.keep(each => each.voted == Some(false))
      ->Belt.Array.get(0)
      ->Belt.Option.flatMap(each => each.count)
      ->Belt.Option.mapWithDefault(0, GraphQLParser.int64)
      ->Belt.Float.fromInt
    if signedBlock == 0. && missedBlock == 0. {
      Sub.resolve(None)
    } else {
      let uptime = signedBlock /. (signedBlock +. missedBlock) *. 100.
      Sub.resolve(Some(uptime))
    }
  })
}

let getBlockUptimeByValidator = consensusAddress => {
  let result = SingleLast100ListConfig.use({
    consensusAddress: consensusAddress->Address.toHex,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(({validator_votes}) => {
    let validatorVotes =
      validator_votes
      ->Belt.Array.map((each): Validator.validator_single_uptime_t => {
        blockHeight: each.block_height->ID.Block.fromInt,
        status: switch (each.voted, each.block.proposer == consensusAddress->Address.toHex) {
        | (false, _) => Missed
        | (true, false) => Signed
        | (true, true) => Proposed
        },
      })
      ->Sub.resolve

    {
      validatorVotes->Sub.map((each): Validator.validator_single_uptime_status_t => {
        validatorVotes: each,
        proposedCount: each->Belt.Array.keep(({status}) => status == Proposed)->Belt.Array.length,
        signedCount: each->Belt.Array.keep(({status}) => status == Signed)->Belt.Array.length,
        missedCount: each->Belt.Array.keep(({status}) => status == Missed)->Belt.Array.length,
      })
    }
  })
}

let getHistoricalOracleStatus = (operatorAddress, greater, oracleStatus) => {
  let result = HistoricalOracleStatusesConfig.use({
    operatorAddress: operatorAddress->Address.toOperatorBech32,
    greater: greater->MomentRe.Moment.format(Config.timestampUseFormat, _)->Js.Json.string,
  })

  let startDate = greater->MomentRe.Moment.startOf(#day, _)->MomentRe.Moment.toUnix

  result
  ->Sub.fromData
  ->Sub.flatMap(({historical_oracle_statuses}) => {
    let oracleStatusReports =
      historical_oracle_statuses->Belt.Array.length > 0
        ? historical_oracle_statuses
          ->Belt.Array.map(each => {
            HistoryOracleParser.status: each.status,
            timestamp: each.timestamp->GraphQLParser.timestamp->MomentRe.Moment.toUnix,
          })
          ->Belt.List.fromArray
        : list{
            {
              timestamp: startDate,
              status: oracleStatus,
            },
          }
    let rawParsedReports = HistoryOracleParser.parse(~oracleStatusReports, ~startDate, ())

    let parsedReports = if !oracleStatus && historical_oracle_statuses->Belt.Array.length == 0 {
      rawParsedReports->Belt.Array.map(({timestamp}) => {
        HistoryOracleParser.timestamp,
        status: false,
      })
    } else {
      rawParsedReports
    }

    Sub.resolve(
      (
        {
          oracleStatusReports: parsedReports,
          uptimeCount: parsedReports->Belt.Array.keep(({status}) => status)->Belt.Array.length,
          downtimeCount: parsedReports->Belt.Array.keep(({status}) => !status)->Belt.Array.length,
        }: Validator.historical_oracle_statuses_count_t
      ),
    )
  })
}

let getBlockUptimeByValidator = consensusAddress => {
  let result = SingleLast100ListConfig.use({
    consensusAddress: consensusAddress->Address.toHex,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(({validator_votes}) => {
    let validatorVotes =
      validator_votes
      ->Belt.Array.map((each): Validator.validator_single_uptime_t => {
        blockHeight: each.block_height->ID.Block.fromInt,
        status: switch (each.voted, each.block.proposer == consensusAddress->Address.toHex) {
        | (false, _) => Missed
        | (true, false) => Signed
        | (true, true) => Proposed
        },
      })
      ->Sub.resolve

    {
      validatorVotes->Sub.map((each): Validator.validator_single_uptime_status_t => {
        validatorVotes: each,
        proposedCount: each->Belt.Array.keep(({status}) => status == Proposed)->Belt.Array.length,
        signedCount: each->Belt.Array.keep(({status}) => status == Signed)->Belt.Array.length,
        missedCount: each->Belt.Array.keep(({status}) => status == Missed)->Belt.Array.length,
      })
    }
  })
}

// let getHistoricalOracleStatus = (operatorAddress, greater, oracleStatus) => {
//   let result = HistoricalOracleStatusesConfig.use({
//     operatorAddress: operatorAddress->Address.toOperatorBech32,
//     greater: greater->MomentRe.Moment.format(Config.timestampUseFormat, _)->Js.Json.string,
//   })

//   let startDate = greater->MomentRe.Moment.startOf(#day, _)->MomentRe.Moment.toUnix

//   let oracleStatusReports =
//     result
//     ->Sub.fromData
//     ->Sub.flatMap(({historical_oracle_statuses}) => {
//       historical_oracle_statuses->Belt.Array.length > 0
//         ? historical_oracle_statuses
//           ->Belt.Array.map(each => {
//             HistoryOracleParser.status: each.status,
//             timestamp: each.timestamp->GraphQLParser.timestamp->MomentRe.Moment.toUnix,
//           })
//           ->Belt.List.fromArray
//           ->Sub.resolve
//         : [{HistoryOracleParser.timestamp: startDate, HistoryOracleParser.status: oracleStatus}]
//           ->Belt.List.fromArray
//           ->Sub.resolve
//     })

// }

let getHistoricalOracleStatus = (operatorAddress, greater, oracleStatus) => {
  let result = HistoricalOracleStatusesConfig.use({
    operatorAddress: operatorAddress->Address.toOperatorBech32,
    greater: greater->MomentRe.Moment.format(Config.timestampUseFormat, _)->Js.Json.string,
  })

  let startDate = greater->MomentRe.Moment.startOf(#day, _)->MomentRe.Moment.toUnix

  result
  ->Sub.fromData
  ->Sub.flatMap(({historical_oracle_statuses}) => {
    let oracleStatusReports =
      historical_oracle_statuses->Belt.Array.length > 0
        ? historical_oracle_statuses
          ->Belt.Array.map(each => {
            HistoryOracleParser.status: each.status,
            timestamp: each.timestamp->GraphQLParser.timestamp->MomentRe.Moment.toUnix,
          })
          ->Belt.List.fromArray
        : list{
            {
              timestamp: startDate,
              status: oracleStatus,
            },
          }
    let rawParsedReports = HistoryOracleParser.parse(~oracleStatusReports, ~startDate, ())

    let parsedReports = if !oracleStatus && historical_oracle_statuses->Belt.Array.length == 0 {
      rawParsedReports->Belt.Array.map(({timestamp}) => {
        HistoryOracleParser.timestamp,
        status: false,
      })
    } else {
      rawParsedReports
    }

    Sub.resolve(
      (
        {
          oracleStatusReports: parsedReports,
          uptimeCount: parsedReports->Belt.Array.keep(({status}) => status)->Belt.Array.length,
          downtimeCount: parsedReports->Belt.Array.keep(({status}) => !status)->Belt.Array.length,
        }: Validator.historical_oracle_statuses_count_t
      ),
    )
  })
}
