module Styles = {
  open CssJs

  let statusImg = style(. [width(#px(20)), marginTop(#px(-3))])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~txSub: Sub.variant<Transaction.t>, ~msgTransform: Msg.result_t => Msg.result_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <TBody>
      <Row alignItems=Row.Start>
        <Col col=Col.Three>
          {switch txSub {
          | Data({txHash}) => <TxLink txHash width=200 />
          | _ => <LoadingCensorBar width=200 height=15 />
          }}
        </Col>
        <Col col=Col.One>
          {switch txSub {
          | Data({blockHeight}) => <TypeID.Block id=blockHeight />
          | _ => <LoadingCensorBar width=65 height=15 />
          }}
        </Col>
        <Col col=Col.One>
          <div className={CssHelper.flexBox(~justify=#center, ())}>
            {switch txSub {
            | Data({success}) =>
              <img
                src={success ? Images.success : Images.fail}
                alt={success ? "Success" : "Failed"}
                className=Styles.statusImg
              />
            | _ => <LoadingCensorBar width=20 height=20 radius=20 />
            }}
          </div>
        </Col>
        <Col col=Col.Two>
          {switch txSub {
          | Data({gasFee}) =>
            <Text
              block=true
              value={gasFee->Coin.getBandAmountFromCoins->Format.fPretty}
              weight=Text.Semibold
              color=theme.neutral_900
            />
          | _ => <LoadingCensorBar width=65 height=15 />
          }}
        </Col>
        <Col col=Col.Five>
          {switch txSub {
          | Data({messages, txHash, success, errMsg}) =>
            <div>
              <TxMessages txHash messages={messages->Belt.List.map(msgTransform)} success errMsg />
            </div>
          | _ =>
            <>
              <LoadingCensorBar width=400 height=15 />
            </>
          }}
        </Col>
      </Row>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (
    ~reserveIndex,
    ~txSub: Sub.variant<Transaction.t>,
    ~msgTransform: Msg.result_t => Msg.result_t,
  ) => {
    let isSmallMobile = Media.isSmallMobile()

    switch txSub {
    | Data({txHash, blockHeight, gasFee, success, messages, errMsg}) =>
      let msgTransform = messages->Belt.List.map(msgTransform)
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("TX Hash", TxHash(txHash, isSmallMobile ? 170 : 200)),
            ("Block", Height(blockHeight)),
            ("Gas Fee\n(BAND)", Coin({value: gasFee, hasDenom: false})),
            ("Actions", Messages(txHash, msgTransform, success, errMsg)),
          ]
        }
        key={txHash->Hash.toHex}
        idx={txHash->Hash.toHex}
        status=success
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("TX Hash", Loading(isSmallMobile ? 170 : 200)),
            ("Block", Loading(70)),
            ("Gas Fee\n(BAND)", Loading(70)),
            ("Actions", Loading(isSmallMobile ? 160 : 230)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (
  ~txsSub: Sub.variant<array<Transaction.t>>,
  ~msgTransform: Msg.result_t => Msg.result_t=x => x,
) => {
  let isMobile = Media.isMobile()

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <>
    {switch txsSub {
    | Data(txs) =>
      txs->Belt.Array.length > 0
        ? txs
          ->Belt.Array.mapWithIndex((i, e) =>
            isMobile
              ? <RenderBodyMobile
                  key={e.txHash->Hash.toHex} reserveIndex=i txSub={Sub.resolve(e)} msgTransform
                />
              : <RenderBody key={e.txHash->Hash.toHex} txSub={Sub.resolve(e)} msgTransform />
          )
          ->React.array
        : <EmptyContainer>
            <img
              src={isDarkMode ? Images.noTxDark : Images.noTxLight}
              alt="No Transaction"
              className=Styles.noDataImage
            />
            <Heading
              size=Heading.H4
              value="No Transaction"
              align=Heading.Center
              weight=Heading.Regular
              color=theme.neutral_600
            />
          </EmptyContainer>
    | _ =>
      Belt.Array.make(10, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={Belt.Int.toString(i)} reserveIndex=i txSub=noData msgTransform />
          : <RenderBody key={Belt.Int.toString(i)} txSub=noData msgTransform />
      )
      ->React.array
    }}
  </>
}
