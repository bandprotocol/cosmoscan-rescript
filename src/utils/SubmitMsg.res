type t =
  | Send(option<Address.t>, IBCConnectionQuery.target_chain_t)
  | Delegate(option<Address.t>)
  | Undelegate(Address.t)
  | UndelegateAll(Address.t)
  | Redelegate(Address.t)
  | WithdrawReward(Address.t)
  | WithdrawAllReward(Address.t)
  | Reinvest(Address.t, float)
  | Vote(ID.Proposal.t, string)

let toString = x =>
  switch x {
  | Send(_) => "Send Token"
  | Delegate(_) => "Delegate"
  | Undelegate(_) => "Undelegate"
  | UndelegateAll(_) => "Undelegate All"
  | Redelegate(_) => "Redelegate"
  | WithdrawReward(_) => "Claim Reward"
  | WithdrawAllReward(_) => "Claim All Rewards"
  | Reinvest(_) => "Reinvest"
  | Vote(_) => "Vote"
  }
let baseGasLimit = x =>
  switch x {
  | Send(_)
  | Delegate(_)
  | Undelegate(_)
  | Vote(_)
  | WithdrawReward(_)
  | Reinvest(_)
  | Redelegate(_) => 0
  | WithdrawAllReward(_)
  | UndelegateAll(_) => 55000
  }

let defaultGasLimit = x =>
  switch x {
  | Send(_)
  | Delegate(_)
  | Undelegate(_)
  | Vote(_)
  | WithdrawReward(_)
  | Reinvest(_)
  | Redelegate(_) => 300000
  | WithdrawAllReward(_)
  | UndelegateAll(_) => 152000
  }

let defaultFee = x =>
  switch x {
  | Send(_)
  | Delegate(_)
  | Undelegate(_)
  | Vote(_)
  | WithdrawReward(_)
  | Reinvest(_)
  | Redelegate(_) => 5000
  | WithdrawAllReward(_) => 7500
  | UndelegateAll(_) => 50000
  }
