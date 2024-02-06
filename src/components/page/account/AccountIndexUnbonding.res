module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~unbondingListSub: Sub.variant<UnbondingSub.unbonding_list_t>, ~templateColumns) =>
    <TBody>
      <TableGrid templateColumns>
        {switch unbondingListSub {
        | Data({validator: {operatorAddress, moniker, identity}}) =>
          <div className={CssHelper.flexBox()}>
            <ValidatorMonikerLink
              validatorAddress=operatorAddress
              moniker
              identity
              width=#px(300)
              avatarWidth=30
              size=Text.Body1
            />
          </div>
        | _ => <LoadingCensorBar width=150 height=20 />
        }}
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          {switch unbondingListSub {
          | Data({amount}) =>
            <Text
              value={amount->Coin.getBandAmountFromCoin->Format.fPretty} size=Body1 weight=Bold
            />
          | _ => <LoadingCensorBar width=150 height=20 />
          }}
        </div>
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          {switch unbondingListSub {
          | Data({completionTime}) =>
            <Timestamp
              time=completionTime size=Text.Body1 weight=Text.Regular textAlign=Text.Right
            />
          | _ => <LoadingCensorBar width=150 height=20 />
          }}
        </div>
      </TableGrid>
    </TBody>
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~unbondingListSub: Sub.variant<UnbondingSub.unbonding_list_t>) =>
    switch unbondingListSub {
    | Data({validator: {operatorAddress, moniker, identity}, amount, completionTime}) =>
      let key_ =
        operatorAddress->Address.toBech32 ++
          (completionTime->MomentRe.Moment.toISOString ++
          reserveIndex->Belt.Int.toString)
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Validator Name", Validator({address: operatorAddress, moniker, identity})),
            ("Amount", Coin({value: list{amount}, hasDenom: false})),
            ("Unbonded At", Timestamp(completionTime)),
          ]
        }
        key=key_
        idx=key_
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Validator Name", Loading(200)),
            ("Amount", Loading(200)),
            ("Unbonded At", Loading(200)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
}

@react.component
let make = (~address) => {
  let isMobile = Media.isMobile()
  let currentTime =
    React.useContext(TimeContext.context)->MomentRe.Moment.format(Config.timestampUseFormat, _)

  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5

  let unbondingListSub = UnbondingSub.getUnbondingByDelegator(
    address,
    currentTime,
    ~pageSize,
    ~page,
    (),
  )
  let unbondingCountSub = UnbondingSub.getUnbondingCountByDelegator(address, currentTime)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = ThemeContext.use()

  let templateColumns = [#fr(1.4), #repeat(#num(2), #fr(0.8))]

  <div className=Styles.tableWrapper>
    {isMobile
      ? React.null
      : <THead>
          <TableGrid templateColumns>
            <Text block=true value="Unbonding Entries" weight=Semibold />
            <Text block=true value="Amount(BAND)" weight=Semibold align=Right />
            <Text block=true value="Unbonded At" weight=Semibold align=Right />
          </TableGrid>
        </THead>}
    {switch unbondingListSub {
    | Data(unbondingList) =>
      unbondingList->Belt.Array.length > 0
        ? unbondingList
          ->Belt.Array.mapWithIndex((i, e) =>
            isMobile
              ? <RenderBodyMobile
                  key={e.validator.operatorAddress->Address.toBech32 ++
                    (e.completionTime->MomentRe.Moment.toISOString ++
                    i->Belt.Int.toString)}
                  reserveIndex=i
                  unbondingListSub={Sub.resolve(e)}
                />
              : <RenderBody
                  key={e.validator.operatorAddress->Address.toBech32 ++
                    (e.completionTime->MomentRe.Moment.toISOString ++
                    i->Belt.Int.toString)}
                  unbondingListSub={Sub.resolve(e)}
                  templateColumns
                />
          )
          ->React.array
        : <EmptyContainer>
            <img
              src={isDarkMode ? Images.noDataDark : Images.noDataLight}
              alt="No Data"
              className=Styles.noDataImage
            />
            <Heading
              size=Heading.H4
              value="No Unbonding"
              align=Heading.Center
              weight=Heading.Regular
              color=theme.neutral_600
            />
            <Text value="The unbonding process is a 21 day waiting period." />
          </EmptyContainer>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i unbondingListSub=noData />
          : <RenderBody key={i->Belt.Int.toString} unbondingListSub=noData templateColumns />
      )
      ->React.array
    }}
    {switch unbondingCountSub {
    | Data(unbondingCount) =>
      <Pagination
        currentPage=page
        totalElement=unbondingCount
        pageSize
        onPageChange={newPage => setPage(_ => newPage)}
        onChangeCurrentPage={newPage => setPage(_ => newPage)}
      />
    | _ => React.null
    }}
  </div>
}
