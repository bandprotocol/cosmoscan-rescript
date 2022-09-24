type t = {
  chainID: string,
  replayOffset: int,
}

module Config = %graphql(`
  subscription Tracking {
    tracking {
      chainID: chain_id
      replayOffset: replay_offset
    }
  }
`)

let use = () => {
  let result = Config.use()

  result->Sub.fromData->Sub.map(({tracking}) => tracking->Belt.Array.getExn(_, 0))
}
