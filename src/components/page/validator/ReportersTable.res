module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~reporterSub: Sub.variant<Address.t>, ~templateColumns) => {
    <TBody>
      <TableGrid templateColumns>
        // TODO: wire up
        <Text value="1" code=true size=Body1 />
        {switch reporterSub {
        | Data(address) => <AddressRender address />
        | _ => <LoadingCensorBar width=300 height=15 />
        }}
      </TableGrid>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~reporterSub: Sub.variant<Address.t>) => {
    switch reporterSub {
    | Data(address) =>
      <MobileCard
        values={
          open InfoMobileCard
          [("#", Count(1)), ("Reporter", Address(address, 200, #account))]
        }
        key={address->Address.toBech32}
        idx={address->Address.toBech32}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [("#", Loading(40)), ("Reporter", Loading(150))]
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
  let pageSize = 5
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let reportersSub = ReporterSub.getList(~operatorAddress=address, ~pageSize, ~page, ())
  let reporterCountSub = ReporterSub.count(address)
  let allSub = Sub.all2(reportersSub, reporterCountSub)
  let templateColumns = [#fr(0.1), #fr(1.9)]

  <div className=Styles.tableWrapper>
    {isMobile
      ? React.null
      : <THead height=36>
          <TableGrid templateColumns>
            <Text block=true value="#" weight=Text.Semibold />
            <div className={CssHelper.flexBox()}>
              <Text block=true value="Reporter Address" weight=Text.Semibold />
              <HSpacing size=Spacing.xs />
              <CTooltip
                tooltipText="an address used to submit the oracle script report. It is recommended to have five reporters for optimal functionality.">
                <Icon name="fal fa-info-circle" size=10 color={theme.neutral_600} />
              </CTooltip>
            </div>
          </TableGrid>
        </THead>}
    {switch allSub {
    | Data((reporters, reporterCount)) =>
      <>
        {reporterCount > 0
          ? reporters
            ->Belt.Array.mapWithIndex((i, e) =>
              isMobile
                ? <RenderBodyMobile
                    key={e |> Address.toBech32} reserveIndex=i reporterSub={Sub.resolve(e)}
                  />
                : <RenderBody
                    key={e |> Address.toBech32} reporterSub={Sub.resolve(e)} templateColumns
                  />
            )
            ->React.array
          : <EmptyContainer>
              <img
                alt="No Reporter"
                src={isDarkMode ? Images.noDataDark : Images.noDataLight}
                className=Styles.noDataImage
              />
              <Heading
                size=Heading.H4
                value="No Reporter"
                align=Heading.Center
                weight=Heading.Regular
                color={theme.neutral_600}
              />
            </EmptyContainer>}
        {isMobile
          ? React.null
          : <Pagination
              currentPage=page
              totalElement=reporterCount
              pageSize
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={Belt.Int.toString(i)} reserveIndex=i reporterSub=noData />
          : <RenderBody key={Belt.Int.toString(i)} reporterSub=noData templateColumns />
      )
      ->React.array
    }}
  </div>
}
