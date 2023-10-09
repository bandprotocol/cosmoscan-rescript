module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~delegatorSub: Sub.variant<DelegationSub.Stake.t>, ~templateColumns) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <TBody>
      <TableGrid templateColumns>
        // TODO: wire up
        <Text value="1" code=true />
        {switch delegatorSub {
        | Data({delegatorAddress}) => <AddressRender address=delegatorAddress />
        | _ => <LoadingCensorBar width=300 height=15 />
        }}
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          {switch delegatorSub {
          | Data({amount, sharePercentage}) =>
            <div className={CssHelper.flexBox()}>
              <Text
                block=true
                value={amount->Coin.getBandAmountFromCoin->Format.fPretty}
                color={theme.neutral_900}
                size=Text.Body1
              />
              <HSpacing size=Spacing.sm />
              <Text
                block=true
                size=Text.Body1
                value={"(" ++ sharePercentage->Format.fPercent(~digits=2) ++ ")"}
                color={theme.neutral_600}
              />
            </div>
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </div>
      </TableGrid>
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
            // TODO: wire up
            ("Rank", Count(1)),
            ("Address", Address(delegatorAddress, 149, #account)),
            // ("Shares (%)", Float(sharePercentage, Some(4))),
            ("Amount", Coin({value: list{amount}, hasDenom: false})),
          ]
        }
        key={delegatorAddress->Address.toBech32}
        idx={delegatorAddress->Address.toBech32}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [("Rank", Loading(40)), ("Address", Loading(150)), ("Amount", Loading(80))]
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
  let ({ThemeContext.theme: theme, isDarkMode}, _) = ThemeContext.use()
  let templateColumns = [#fr(0.15), #fr(1.85), #fr(1.)]

  <div className=Styles.tableWrapper>
    {isMobile
      ? React.null
      : <THead height=36>
          <TableGrid templateColumns>
            <Text value="Rank" block=true weight=Semibold />
            <Text block=true value="Delegator Address" weight=Text.Semibold />
            <Text
              block=true value="Delegated Amount (BAND)" weight=Text.Semibold align=Text.Right
            />
          </TableGrid>
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
                    key={e.delegatorAddress |> Address.toBech32}
                    delegatorSub={Sub.resolve(e)}
                    templateColumns
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
          : <RenderBody key={i->Belt.Int.toString} delegatorSub=noData templateColumns />
      )
      ->React.array
    }}
  </div>
}
