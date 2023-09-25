type raw_t = {
  oracleStatus: bool,
  operatorAddress: Address.t,
  consensusAddress: string,
  moniker: string,
  identity: string,
  website: string,
  jailed: bool,
  details: string,
  tokens: Coin.t,
  commissionRate: float,
  commissionMaxChange: float,
  commissionMaxRate: float,
}

type t = {
  rank: int,
  isActive: bool,
  oracleStatus: bool,
  operatorAddress: Address.t,
  consensusAddress: Address.t,
  moniker: string,
  identity: string,
  website: string,
  details: string,
  uptime: option<float>,
  tokens: Coin.t,
  commission: float,
  commissionMaxChange: float,
  commissionMaxRate: float,
  votingPower: float,
}

type validator_voted_status_t =
  | Missed
  | Signed
  | Proposed

type validator_single_uptime_t = {
  blockHeight: ID.Block.t,
  status: validator_voted_status_t,
}

type validator_single_uptime_status_t = {
  validatorVotes: array<validator_single_uptime_t>,
  proposedCount: int,
  missedCount: int,
  signedCount: int,
}

type validator_vote_t = {
  consensusAddress: Address.t,
  count: int,
  voted: bool,
}

type historical_oracle_statuses_count_t = {
  oracleStatusReports: array<HistoryOracleParser.t>,
  uptimeCount: int,
  downtimeCount: int,
}

let toExternal = (
  {
    operatorAddress,
    consensusAddress,
    moniker,
    identity,
    website,
    jailed,
    oracleStatus,
    details,
    tokens,
    commissionRate,
    commissionMaxChange,
    commissionMaxRate,
  }: raw_t,
  rank,
): t => {
  rank,
  isActive: !jailed,
  operatorAddress,
  consensusAddress: consensusAddress->Address.fromHex,
  tokens,
  commission: commissionRate *. 100.,
  commissionMaxChange: commissionMaxChange *. 100.,
  commissionMaxRate: commissionMaxRate *. 100.,
  moniker,
  identity,
  website,
  oracleStatus,
  details,
  uptime: None,
  votingPower: tokens.amount,
}
