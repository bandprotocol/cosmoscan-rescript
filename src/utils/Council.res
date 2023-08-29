type account_t = {address: Address.t}

type council_member_t = {
  account: account_t,
  weight: int,
  metadata: string,
  since: MomentRe.Moment.t,
}

type council_name_t = BandDaoCouncil | GrantCouncil | TechCouncil | Unspecified

type council_t = {
  id: int,
  name: council_name_t,
  account: account_t,
  councilMembers: array<council_member_t>,
}

module CouncilNameParser = {
  let parse = str =>
    switch str {
    | "COUNCIL_TYPE_BAND_DAO" => BandDaoCouncil
    | "COUNCIL_TYPE_GRANT" => GrantCouncil
    | "COUNCIL_TYPE_TECH" => TechCouncil
    | _ => Unspecified
    }

  let serialize = (councilName: council_name_t) => {
    switch councilName {
    | BandDaoCouncil => "COUNCIL_TYPE_BAND_DAO"
    | GrantCouncil => "COUNCIL_TYPE_GRANT"
    | TechCouncil => "COUNCIL_TYPE_TECH"
    | Unspecified => "Unknown"
    }
  }
}

let getCouncilNameString = (councilName: council_name_t) =>
  switch councilName {
  | BandDaoCouncil => "Band DAO Council"
  | GrantCouncil => "Grant Council"
  | TechCouncil => "Tech Council"
  | Unspecified => "Unknown"
  }

let getMemberWeightDict = (councilMember: array<council_member_t>) => {
  let tempDict = Js.Dict.fromList(list{("null", 1)})
  councilMember->Belt.Array.forEach(member => {
    tempDict->Js.Dict.set(member.account.address->Address.toBech32, member.weight)
  })

  tempDict
}

type calculated_vote = {
  yesCount: int,
  noCount: int,
  yesVotePercent: float,
  noVotePercent: float,
  yesVoteByWeight: int,
  noVoteByWeight: int,
  totalWeight: int,
}

let calculateVote = (votes: array<CouncilVoteSub.t>, councilMember: array<council_member_t>) => {
  let memberWeightDict = councilMember->getMemberWeightDict
  let yesVotes = votes->Belt.Array.keep(vote => vote.option == Vote.YesNo.Yes)
  let noVotes = votes->Belt.Array.keep(vote => vote.option == Vote.YesNo.No)
  let totalWeight = councilMember->Belt.Array.reduce(0, (acc, member) => acc + member.weight)
  let yesVoteByWeight =
    yesVotes->Belt.Array.reduce(0, (acc, vote) =>
      acc +
      Js.Dict.get(
        memberWeightDict,
        vote.account.address->Address.toBech32,
      )->Belt.Option.getWithDefault(0)
    )
  let noVoteByWeight =
    noVotes->Belt.Array.reduce(0, (acc, vote) =>
      acc +
      Js.Dict.get(
        memberWeightDict,
        vote.account.address->Address.toBech32,
      )->Belt.Option.getWithDefault(0)
    )

  {
    yesCount: yesVotes->Belt.Array.length,
    noCount: noVotes->Belt.Array.length,
    yesVotePercent: yesVoteByWeight->Belt.Int.toFloat /. totalWeight->Belt.Int.toFloat *. 100.,
    noVotePercent: noVoteByWeight->Belt.Int.toFloat /. totalWeight->Belt.Int.toFloat *. 100.,
    yesVoteByWeight,
    noVoteByWeight,
    totalWeight,
  }
}
