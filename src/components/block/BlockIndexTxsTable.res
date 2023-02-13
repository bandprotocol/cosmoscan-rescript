module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~txSub: Sub.variant<TxSub.t>) => {
    <TBody>
      <Row>
        <Col col=Col.Two>
          {switch txSub {
           | Data({txHash}) => <TxLink txHash width=140 />
           | Error(_) | Loading | NoData => <LoadingCensorBar width=170 height=15 />
           }}
        </Col>
        <Col col=Col.Two>
          {switch txSub {
           | Data({gasFee}) =>
             <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
               <Text
                 block=true
                 code=true
                 spacing={Text.Em(0.02)}
                 value={gasFee->Coin.getBandAmountFromCoins->Format.fPretty}
                 weight=Text.Medium
               />
             </div>
           | Error(_) | Loading | NoData => <LoadingCensorBar width=30 height=15 isRight=true />
           }}
        </Col>
        <Col col=Col.Eight>
          {switch txSub {
           | Data({messages, txHash, success, errMsg}) =>
             <TxMessages txHash messages success errMsg />
           | Error(_) | Loading | NoData => <LoadingCensorBar width=530 height=15 />
           }}
        </Col>
      </Row>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~txSub: Sub.variant<TxSub.t>) => {
    switch txSub {
    | Data({txHash, gasFee, success, messages, errMsg}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("TX Hash", TxHash(txHash, 200)),
            ("Gas Fee\n(BAND)", Coin({value: gasFee, hasDenom: false})),
            ("Actions", Messages(txHash, messages, success, errMsg)),
          ]
        }
        idx={txHash -> Hash.toHex}
        status=success
      />
    | Error(_) | Loading | NoData =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("TX Hash", Loading(200)),
            ("Gas Fee\n(BAND)", Loading(60)),
            ("Actions", Loading(230)),
          ]
        }
        idx={reserveIndex -> Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~txsSub: Sub.variant<array<TxSub.t>>) => {
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <>
    {isMobile
       ? React.null
       : <THead>
           <Row alignItems=Row.Center>
             <Col col=Col.Two>
               <Text
                 block=true
                 value="TX Hash"
                 size=Text.Sm
                 weight=Text.Semibold
                 transform=Text.Uppercase
               />
             </Col>
             <Col col=Col.Two>
               <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
                 <Text
                   block=true
                   value="Gas Fee (BAND)"
                   size=Text.Sm
                   weight=Text.Semibold
                   transform=Text.Uppercase
                 />
               </div>
             </Col>
             <Col col=Col.Eight>
               <Text
                 block=true
                 value="Actions"
                 size=Text.Sm
                 weight=Text.Semibold
                 transform=Text.Uppercase
               />
             </Col>
           </Row>
         </THead>}
    {switch txsSub {
     | Data(txs) =>
       txs->Belt.Array.size > 0
         ? txs
           ->Belt.Array.mapWithIndex((i, e) =>
               isMobile
                 ? <RenderBodyMobile
                     reserveIndex=i
                     txSub={Sub.resolve(e)}
                     key={e.txHash -> Hash.toHex}
                   />
                 : <RenderBody txSub={Sub.resolve(e)} key={e.txHash -> Hash.toHex} />
             )
           ->React.array
         : <EmptyContainer>
             <img
               alt="No Transaction"
               src={isDarkMode ? Images.noTxDark : Images.noTxLight}
               className=Styles.noDataImage
             />
             <Heading
               size=Heading.H4
               value="No Transaction"
               align=Heading.Center
               weight=Heading.Regular
               color={theme.neutral_600}
             />
           </EmptyContainer>
     | Error(_) | Loading | NoData =>
       Belt.Array.make(isMobile ? 1 : 10, Sub.NoData)
       ->Belt.Array.mapWithIndex((i, noData) =>
           isMobile
             ? <RenderBodyMobile reserveIndex=i txSub=noData key={i -> Belt.Int.toString} />
             : <RenderBody txSub=noData key={i -> Belt.Int.toString} />
         )
       ->React.array
     }}
  </>
}
