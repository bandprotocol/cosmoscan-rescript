type t =
  | Send(option<Address.t>, IBCConnectionQuery.target_chain_t)
  | Delegate(Address.t)
  | Undelegate(Address.t)
  | Redelegate(Address.t)
  | WithdrawReward(Address.t)
  | Reinvest(Address.t, float)
  | Vote(ID.Proposal.t, string)
  | VetoVote(ID.LegacyProposal.t, string)
  | OpenVeto(ID.Proposal.t, string, list<Coin.t>)

let toString = x =>
  switch x {
  | Send(_) => "Send Token"
  | Delegate(_) => "Delegate"
  | Undelegate(_) => "Undelegate"
  | Redelegate(_) => "Redelegate"
  | WithdrawReward(_) => "Withdraw Reward"
  | Reinvest(_) => "Reinvest"
  | Vote(_) => "Vote"
  | VetoVote(_) => "Veto Vote"
  | OpenVeto(_) => "Open Veto Proposal"
  }

let defaultGasLimit = x =>
  switch x {
  | Send(_)
  | Delegate(_)
  | Undelegate(_)
  | Vote(_)
  | VetoVote(_)
  | OpenVeto(_)
  | WithdrawReward(_)
  | Reinvest(_)
  | Redelegate(_) => 300000
  }
