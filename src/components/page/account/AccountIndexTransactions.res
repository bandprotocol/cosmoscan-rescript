module Styles = {
  open CssJs

  let statusImg = style(. [width(#px(20)), marginTop(#px(-3))])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (
    ~txSub: Sub.variant<Transaction.t>,
    ~msgTransform: Msg.result_t => Msg.result_t,
    ~templateColumns,
  ) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
    <TBody>
      <TableGrid templateColumns>
        {switch txSub {
        | Data({txHash}) => <TxLink txHash width=140 size=Body1 />
        | _ => <LoadingCensorBar width=100 height=15 />
        }}
        {switch txSub {
        | Data({blockHeight}) => <TypeID.Block id=blockHeight size=Body1 />
        | _ => <LoadingCensorBar width=65 height=15 />
        }}
        {switch txSub {
        | Data({success}) =>
          <img
            src={success ? Images.success : Images.fail}
            alt={success ? "Success" : "Failed"}
            className=Styles.statusImg
          />
        | _ => <LoadingCensorBar width=20 height=20 radius=20 />
        }}
        {switch txSub {
        | Data({messages, txHash, success, errMsg}) =>
          <TxMessages
            txHash messages={messages->Belt.List.map(msgTransform)} success errMsg showSender=false
          />
        | _ =>
          <>
            <LoadingCensorBar width=300 height=15 />
          </>
        }}
        {switch txSub {
        | Data({gasFee}) =>
          <Text
            block=true
            value={gasFee->Coin.getBandAmountFromCoins->Format.fPretty}
            align=Right
            code=true
            size=Body1
          />
        | _ => <LoadingCensorBar width=65 height=15 isRight=true />
        }}
        {switch txSub {
        | Data({timestamp}) =>
          <div className={CssHelper.fullWidth}>
            <div
              className={CssHelper.flexBox(~justify=#flexEnd, ~align=#center, ~direction=#row, ())}>
              <Timestamp time=timestamp size=Text.Body1 weight=Text.Regular textAlign=Text.Right />
            </div>
          </div>
        | _ => <LoadingCensorBar width=65 height=15 isRight=true />
        }}
      </TableGrid>
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
            ("Status", Status({status: success})),
            ("Actions", Messages(txHash, msgTransform, success, errMsg)),
            ("Fee", Coin({value: gasFee, hasDenom: false})),
            // TODO: wire up
            ("Time", Timestamp(MomentRe.momentNow())),
          ]
        }
        key={txHash->Hash.toHex}
        idx={txHash->Hash.toHex}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("TX Hash", Loading(isSmallMobile ? 170 : 200)),
            ("Block", Loading(70)),
            ("Status", Loading(70)),
            ("Actions", Loading(isSmallMobile ? 160 : 230)),
            ("Fee", Loading(50)),
            ("Time", Loading(160)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~accountAddress: Address.t) => {
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 10

  let txsSub = TxSub.getListBySender(~sender=accountAddress, ~pageSize, ~page)
  let txsCountSub = TxSub.countBySender(accountAddress)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  let templateColumns = [
    #fr(1.),
    #fr(0.8),
    #fr(0.4),
    #minmax(#px(150), #fr(2.)),
    #fr(0.5),
    #fr(1.3),
  ]

  let msgTransform = React.useCallback1((msg: Msg.result_t) => {
    let transformDecoded = switch msg.decoded {
    | SendMsg({toAddress, fromAddress, amount}) if Address.isEqual(toAddress, accountAddress) =>
      Msg.ReceiveMsg({toAddress, fromAddress, amount})
    | _ => msg.decoded
    }

    open Msg
    {raw: msg.raw, decoded: transformDecoded, sender: msg.sender, isIBC: msg.isIBC}
  }, [accountAddress])

  <Row marginTop=40>
    <Col>
      <InfoContainer>
        <Table>
          {isMobile
            ? React.null
            : <THead>
                <TableGrid templateColumns>
                  <Text block=true value="TX Hash" weight=Semibold />
                  <Text block=true value="Block" weight=Semibold />
                  <Text block=true value="Status" weight=Semibold />
                  <Text block=true value="Actions" weight=Semibold />
                  <Text block=true value="Fee (BAND)" weight=Semibold align=Right />
                  <Text block=true value="Time" weight=Semibold align=Right />
                </TableGrid>
              </THead>}
          {switch txsSub {
          | Data(txs) =>
            txs->Belt.Array.length > 0
              ? txs
                ->Belt.Array.mapWithIndex((i, e) =>
                  isMobile
                    ? <RenderBodyMobile
                        key={e.txHash->Hash.toHex}
                        reserveIndex=i
                        txSub={Sub.resolve(e)}
                        msgTransform
                      />
                    : <RenderBody
                        key={e.txHash->Hash.toHex}
                        txSub={Sub.resolve(e)}
                        msgTransform
                        templateColumns
                      />
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
                ? <RenderBodyMobile
                    key={Belt.Int.toString(i)} reserveIndex=i txSub=noData msgTransform
                  />
                : <RenderBody
                    key={Belt.Int.toString(i)} txSub=noData msgTransform templateColumns
                  />
            )
            ->React.array
          }}
          {switch txsCountSub {
          | Data(txsCount) =>
            <Pagination
              currentPage=page
              pageSize
              totalElement=txsCount
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />
          | _ => React.null
          }}
        </Table>
      </InfoContainer>
    </Col>
  </Row>
}
