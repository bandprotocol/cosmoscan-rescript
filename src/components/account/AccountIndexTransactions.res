module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
}

let transform = (account, msg: Msg.result_t) => {
  let transformDecoded = switch msg.decoded {
  | SendMsg({toAddress, fromAddress, amount}) if Address.isEqual(toAddress, account) =>
    Msg.ReceiveMsg({toAddress, fromAddress, amount})
  | _ => msg.decoded
  }

  open Msg
  {raw: msg.raw, decoded: transformDecoded, sender: msg.sender, isIBC: msg.isIBC}
}

@react.component
let make = (~accountAddress: Address.t) => {
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 10

  let txsSub = TxSub.getListBySender(~sender=accountAddress, ~pageSize, ~page)
  let txsCountSub = TxSub.countBySender(accountAddress)

  let isMobile = Media.isMobile()

  <div className=Styles.tableWrapper>
    {isMobile
      ? <Row marginBottom=16>
          <Col>
            {switch txsCountSub {
            | Data(txsCount) =>
              <div className={CssHelper.flexBox()}>
                <Text
                  block=true
                  value={txsCount->Belt.Int.toString}
                  weight=Text.Semibold
                  size=Text.Caption
                />
                <HSpacing size=Spacing.xs />
                <Text
                  block=true
                  value="Transactions"
                  weight=Text.Semibold
                  size=Text.Caption
                  transform=Text.Uppercase
                />
              </div>
            | _ => <LoadingCensorBar width=100 height=15 />
            }}
          </Col>
        </Row>
      : <THead>
          <Row alignItems=Row.Center>
            <Col col=Col.Three>
              {switch txsCountSub {
              | Data(txsCount) =>
                <div className={CssHelper.flexBox()}>
                  <Text block=true value={txsCount->Belt.Int.toString} weight=Text.Semibold />
                  <HSpacing size=Spacing.xs />
                  <Text
                    block=true
                    value="Transactions"
                    weight=Text.Semibold
                    size=Text.Caption
                    transform=Text.Uppercase
                  />
                </div>
              | _ => <LoadingCensorBar width=100 height=15 />
              }}
            </Col>
            <Col col=Col.One>
              <Text
                block=true
                value="Block"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
              />
            </Col>
            <Col col=Col.One>
              <Text
                block=true
                value="Status"
                size=Text.Caption
                transform=Text.Uppercase
                weight=Text.Semibold
                align=Text.Center
              />
            </Col>
            <Col col=Col.Two>
              <Text
                block=true
                value="Gas Fee (BAND)"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
              />
            </Col>
            <Col col=Col.Five>
              <Text
                block=true
                value="Actions"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
              />
            </Col>
          </Row>
        </THead>}
    <TxsTable txsSub msgTransform={transform(accountAddress)} />
    {switch txsCountSub {
    | Data(txsCount) =>
      <Pagination2
        currentPage=page
        pageSize
        totalElement=txsCount
        onPageChange={newPage => setPage(_ => newPage)}
        onChangeCurrentPage={newPage => setPage(_ => newPage)}
      />
    | _ => React.null
    }}
  </div>
}
