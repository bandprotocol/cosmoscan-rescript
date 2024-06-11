module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~delegatorSub: Sub.variant<DelegationSub.Stake.t>) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <TBody>
      <Row alignItems=Row.Center minHeight={#px(30)}>
        <Col col=Col.Six>
          {switch delegatorSub {
          | Data({delegatorAddress}) => <AddressRender address=delegatorAddress />
          | _ => <LoadingCensorBar width=300 height=15 />
          }}
        </Col>
        <Col col=Col.Four>
          {switch delegatorSub {
          | Data({sharePercentage}) =>
            <Text block=true value={sharePercentage->Format.fPretty} color={theme.neutral_900} />
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch delegatorSub {
            | Data({amount}) =>
              <Text
                block=true
                value={amount->Coin.getBandAmountFromCoin->Format.fPretty}
                color={theme.neutral_900}
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
  let make = (~reserveIndex, ~delegatorSub: Sub.variant<DelegationSub.Stake.t>) => {
    switch delegatorSub {
    | Data({amount, sharePercentage, delegatorAddress}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Delegator", Address(delegatorAddress, 149, #account)),
            ("Shares (%)", Float(sharePercentage, Some(4))),
            ("Amount\n(BAND)", Coin({value: list{amount}, hasDenom: false})),
          ]
        }
        key={delegatorAddress->Address.toBech32}
        idx={delegatorAddress->Address.toBech32}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Delegator", Loading(150)),
            ("Shares (%)", Loading(60)),
            ("Amount\n(BAND)", Loading(80)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~address) => {
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 10

  let delegatorsSub = DelegationSub.getDelegatorsByValidator(address, ~pageSize, ~page, ())

  let delegatorCountSub = DelegationSub.getDelegatorCountByValidator(address)

  let allSub = Sub.all2(delegatorsSub, delegatorCountSub)

  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.tableWrapper>
    {isMobile
      ? <Row marginBottom=16>
          <Col>
            {switch allSub {
            | Data((_, delegatorCount)) =>
              <div className={CssHelper.flexBox()}>
                <Text
                  block=true
                  value={delegatorCount->Format.iPretty}
                  weight=Text.Semibold
                  size=Text.Caption
                />
                <HSpacing size=Spacing.xs />
                <Text
                  block=true
                  value="Delegators"
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
            <Col col=Col.Six>
              {switch allSub {
              | Data((_, delegatorCount)) =>
                <div className={CssHelper.flexBox()}>
                  <Text
                    block=true
                    value={delegatorCount |> Format.iPretty}
                    weight=Text.Semibold
                    transform=Text.Uppercase
                    size=Text.Caption
                  />
                  <HSpacing size=Spacing.xs />
                  <Text
                    block=true
                    value="Delegators"
                    weight=Text.Semibold
                    transform=Text.Uppercase
                    size=Text.Caption
                  />
                </div>
              | _ => <LoadingCensorBar width=100 height=15 />
              }}
            </Col>
            <Col col=Col.Four>
              <Text
                block=true
                value="Share(%)"
                weight=Text.Semibold
                transform=Text.Uppercase
                size=Text.Caption
              />
            </Col>
            <Col col=Col.Two>
              <Text
                block=true
                value="Amount"
                weight=Text.Semibold
                transform=Text.Uppercase
                size=Text.Caption
                align=Text.Right
              />
            </Col>
          </Row>
        </THead>}
    {switch allSub {
    | Data((delegators, delegatorCount)) =>
      <>
        {delegatorCount > 0
          ? delegators
            ->Belt.Array.mapWithIndex((i, e) =>
              isMobile
                ? <RenderBodyMobile
                    key={e.delegatorAddress |> Address.toBech32}
                    reserveIndex=i
                    delegatorSub={Sub.resolve(e)}
                  />
                : <RenderBody
                    key={e.delegatorAddress |> Address.toBech32} delegatorSub={Sub.resolve(e)}
                  />
            )
            ->React.array
          : <EmptyContainer>
              <img
                alt="No Delegators"
                src={isDarkMode ? Images.noDataDark : Images.noDataLight}
                className=Styles.noDataImage
              />
              <Heading
                size=Heading.H4
                value="No Delegators"
                align=Heading.Center
                weight=Heading.Regular
                color={theme.neutral_600}
              />
            </EmptyContainer>}
        {isMobile
          ? React.null
          : <Pagination
              currentPage=page
              totalElement=delegatorCount
              pageSize
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i delegatorSub=noData />
          : <RenderBody key={i->Belt.Int.toString} delegatorSub=noData />
      )
      ->React.array
    }}
  </div>
}
