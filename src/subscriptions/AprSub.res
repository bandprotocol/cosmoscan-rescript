let use = () => {
  let infoSub = React.useContext(GlobalContext.context)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()
  let latestBlockSub = BlockSub.getLatest()
  let aprSub = Sub.all3(infoSub, bondedTokenCountSub, latestBlockSub)

  aprSub->Sub.flatMap(_, ((info: GlobalContext.t, bondedTokenCount, latestBlock: BlockSub.t)) => {
    let bondedRatio = bondedTokenCount->Coin.getBandAmountFromCoin /. info.financial.totalSupply
    let apr = latestBlock.inflation /. bondedRatio *. 100.

    Sub.resolve(apr)
  })
}
