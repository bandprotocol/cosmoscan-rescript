module Styles = {
  open CssJs

  let root = style(. [position(#relative)])
  let content = style(. [position(#relative), zIndex(1)])
  let baseBg = style(. [position(#absolute), top(#px(40))])
  let left = style(. [left(#zero)])
  let right = style(. [right(#zero), transform(rotateZ(#deg(180.)))])
}

@react.component
let make = () => {
  // Subscribe for latest 5 blocks here so both "LatestBlocks" and "ChainInfoHighLights"
  // share the same infomation.
  let pageSize = 10
  let latestBlocksSub = BlockSub.getList(~pageSize, ~page=1)
  let latestBlockSub = latestBlocksSub->Sub.map(blocks => blocks->Belt.Array.getExn(0))
  let latestRequestsSub = RequestSub.getList(~pageSize, ~page=1)
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  let validatorsSub = ValidatorSub.getList(~filter=Active, ())
  let (validatorOpt, setValidatorOpt) = React.useState(_ => None)

  let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  React.useEffect0(() => {
    let wallet = Wallet.createFromMnemonic("aa")

    wallet
    ->Wallet.getAddressAndPubKey
    ->Promise.then(((address, pubKey)) => {
      dispatchAccount(Connect(wallet, address, pubKey, "band-laozi-testnet6"))
      Promise.resolve()
    })
    ->Promise.catch(err => {
      Js.Console.log(err)
      Promise.resolve()
    })
    ->ignore

    SubmitMsg.Send(None, IBCConnectionQuery.BAND)->SubmitTx->OpenModal->dispatchModal
    None
  })

  <Section pt=80 pb=80 pbSm=24 bg={theme.neutral_000} style=Styles.root>
    React.null
    // {!isMobile
    //   ? <>
    //       <img
    //         alt="Homepage Background"
    //         src={isDarkMode ? Images.bgLeftDark : Images.bgLeftLight}
    //         className={Css.merge(list{Styles.baseBg, Styles.left})}
    //       />
    //       <img
    //         alt="Homepage Background"
    //         src={isDarkMode ? Images.bgLeftDark : Images.bgLeftLight}
    //         className={Css.merge(list{Styles.baseBg, Styles.right})}
    //       />
    //     </>
    //   : React.null}
    // <div className={Css.merge(list{CssHelper.container, Styles.content})} id="homePageContainer">
    //   <ChainInfoHighlights latestBlockSub />
    //   <Row marginTop=40>
    //     <Col col=Col.Six>
    //       <LatestTxTable />
    //     </Col>
    //     <Col col=Col.Six>
    //       <LatestRequests latestRequestsSub />
    //     </Col>
    //   </Row>
    // </div>
  </Section>
}
