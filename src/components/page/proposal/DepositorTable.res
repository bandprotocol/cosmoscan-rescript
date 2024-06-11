module Styles = {
  open CssJs

  let tableWrapper = style(. [
    Media.mobile([padding2(~v=#px(16), ~h=#px(12)), margin2(~v=#zero, ~h=#px(-12))]),
  ])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~depositSub: Sub.variant<DepositSub.t>) => {
    <TBody>
      <Row alignItems=Row.Center>
        <Col col=Col.Five>
          {switch depositSub {
          | Data({depositor}) => <AddressRender address=depositor />
          | _ => <LoadingCensorBar width=300 height=15 />
          }}
        </Col>
        <Col col=Col.Five>
          {switch depositSub {
          | Data({txHashOpt}) =>
            switch txHashOpt {
            | Some(txHash) => <TxLink txHash width=240 />
            | None => <Text value="Deposited on Wenchang" />
            }
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch depositSub {
            | Data({amount}) =>
              <Text
                block=true value={amount->Coin.getBandAmountFromCoins->Format.fPretty(~digits=6)}
              />
            | _ => <LoadingCensorBar width=100 height=15 />
            }}
          </div>
        </Col>
      </Row>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~depositSub: Sub.variant<DepositSub.t>) => {
    switch depositSub {
    | Data({depositor, txHashOpt, amount}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Depositor", Address(depositor, 200, #account)),
            (
              "TX Hash",
              switch txHashOpt {
              | Some(txHash) => TxHash(txHash, 200)
              | None => Text("Deposited on Wenchang")
              },
            ),
            ("Amount", Coin({value: amount, hasDenom: false})),
          ]
        }
        key={depositor->Address.toBech32}
        idx={depositor->Address.toBech32}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [("Depositor", Loading(200)), ("TX Hash", Loading(200)), ("Amount", Loading(80))]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~proposalID) => {
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5
  let isMobile = Media.isMobile()

  let depositsSub = DepositSub.getList(proposalID, ~pageSize, ~page, ())
  let depositCountSub = DepositSub.count(proposalID)
  let allSub = Sub.all2(depositsSub, depositCountSub)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.tableWrapper>
    {isMobile
      ? <Row marginBottom=16>
          <Col>
            {switch allSub {
            | Data((_, depositCount)) =>
              <div className={CssHelper.flexBox()}>
                <Text
                  block=true
                  value={depositCount->Belt.Int.toString}
                  weight=Text.Semibold
                  size=Text.Caption
                  transform=Text.Uppercase
                />
                <HSpacing size=Spacing.xs />
                <Text
                  block=true
                  value={depositCount > 1 ? "Depositors" : "Depositor"}
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
            <Col col=Col.Five>
              {switch allSub {
              | Data((_, depositCount)) =>
                <div className={CssHelper.flexBox()}>
                  <Text
                    block=true
                    value={depositCount->Belt.Int.toString}
                    weight=Text.Semibold
                    size=Text.Caption
                    transform=Text.Uppercase
                  />
                  <HSpacing size=Spacing.xs />
                  <Text
                    block=true
                    value="Depositors"
                    weight=Text.Semibold
                    size=Text.Caption
                    transform=Text.Uppercase
                  />
                </div>
              | _ => <LoadingCensorBar width=100 height=15 />
              }}
            </Col>
            <Col col=Col.Five>
              <Text
                block=true
                value="TX Hash"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
              />
            </Col>
            <Col col=Col.Two>
              <Text
                block=true
                value="Amount"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
                align=Text.Right
              />
            </Col>
          </Row>
        </THead>}
    {switch allSub {
    | Data((delegators, depositCount)) =>
      <>
        {depositCount > 0
          ? delegators
            ->Belt.Array.mapWithIndex((i, e) =>
              isMobile
                ? <RenderBodyMobile
                    reserveIndex=i key={e.depositor->Address.toBech32} depositSub={Sub.resolve(e)}
                  />
                : <RenderBody key={e.depositor->Address.toBech32} depositSub={Sub.resolve(e)} />
            )
            ->React.array
          : <EmptyContainer>
              <img
                alt="No Depositors"
                src={isDarkMode ? Images.noDelegatorDark : Images.noDelegatorLight}
                className=Styles.noDataImage
              />
              <Heading
                size=Heading.H4
                value="No Depositors"
                align=Heading.Center
                weight=Heading.Regular
                color={theme.neutral_600}
              />
            </EmptyContainer>}
        {isMobile
          ? React.null
          : <Pagination
              currentPage=page
              totalElement=depositCount
              pageSize
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile reserveIndex=i key={i->Belt.Int.toString} depositSub=noData />
          : <RenderBody key={i->Belt.Int.toString} depositSub=noData />
      )
      ->React.array
    }}
  </div>
}
