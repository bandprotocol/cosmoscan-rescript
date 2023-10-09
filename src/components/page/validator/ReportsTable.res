module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}
module RenderBody = {
  @react.component
  let make = (~reportsSub: Sub.variant<ReportSub.ValidatorReport.t>, ~templateColumns) => {
    let (show, setShow) = React.useState(_ => false)
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <TBody>
      <TableGrid templateColumns>
        {switch reportsSub {
        | Data({txHash}) =>
          switch txHash {
          | Some(txHash') => <TxLink txHash=txHash' width=140 />
          | None => <Text value="Syncing" />
          }
        | _ => <LoadingCensorBar width=170 height=15 />
        }}
        {switch reportsSub {
        | Data({request: {id}}) => <TypeID.Request id />
        | _ => <LoadingCensorBar width=135 height=15 />
        }}
        {switch reportsSub {
        | Data({request: {oracleScript: {oracleScriptID, name}}}) =>
          <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
            <TypeID.OracleScript id=oracleScriptID />
            <HSpacing size=Spacing.sm />
            <Text value=name ellipsis=true />
          </div>
        | _ => <LoadingCensorBar width=270 height=15 />
        }}
        // TODO: wire up
        <div className={CssHelper.flexBox(~justify=#center, ())}>
          <img alt="Status Icon" src={Images.success} />
        </div>
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          // TODO: wire up
          <Timestamp time={MomentRe.momentNow()} size=Text.Body1 textAlign=Text.Right />
        </div>
      </TableGrid>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~reportsSub: Sub.variant<ReportSub.ValidatorReport.t>) => {
    let isSmallMobile = Media.isSmallMobile()
    switch reportsSub {
    | Data({txHash, request: {id, oracleScript: {oracleScriptID, name}}, reportDetails}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            (
              "TX Hash",
              switch txHash {
              | Some(txHash') => TxHash(txHash', isSmallMobile ? 170 : 200)
              | None => Text("Syncing")
              },
            ),
            ("Request ID", RequestID(id)),
            ("Oracle Script", OracleScript(oracleScriptID, name)),
            // TODO: wire up
            ("Status", Status({status: true})),
            ("Time", Timestamp(MomentRe.momentNow())),
          ]
        }
        key={id->ID.Request.toString}
        idx={id->ID.Request.toString}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("TX Hash", Loading(isSmallMobile ? 170 : 200)),
            ("Request ID", Loading(70)),
            ("Oracle Script", Loading(136)),
            ("Status", Loading(60)),
            ("Time", Loading(100)),
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
  let pageSize = 5

  let reportsSub = ReportSub.ValidatorReport.getListByValidator(
    ~page,
    ~pageSize,
    ~validator={
      address->Address.toOperatorBech32
    },
  )
  let reportsCountSub = ReportSub.ValidatorReport.count(address)
  let allSub = Sub.all2(reportsSub, reportsCountSub)

  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme, isDarkMode}, _) = ThemeContext.use()

  let templateColumns = [#fr(1.), #fr(1.), #minmax((#px(200), #fr(1.5))), #fr(0.5), #fr(1.)]

  <div className=Styles.tableWrapper>
    {isMobile
      ? React.null
      : <THead height=36>
          <TableGrid templateColumns={templateColumns}>
            <Text block=true value="TX Hash" weight=Semibold />
            <Text block=true value="Request ID" weight=Semibold />
            <Text block=true value="Oracle Script" weight=Semibold />
            <Text block=true value="Status" weight=Semibold align=Center />
            <Text block=true value="Time" weight=Semibold align=Right />
          </TableGrid>
        </THead>}
    {switch allSub {
    | Data((reports, reportsCount)) =>
      <>
        {reportsCount > 0
          ? reports
            ->Belt.Array.mapWithIndex((i, e) =>
              isMobile
                ? <RenderBodyMobile
                    key={i->Belt.Int.toString ++ e.request.id->ID.Request.toString}
                    reserveIndex=i
                    reportsSub={Sub.resolve(e)}
                  />
                : <RenderBody
                    key={i->Belt.Int.toString ++ e.request.id->ID.Request.toString}
                    reportsSub={Sub.resolve(e)}
                    templateColumns
                  />
            )
            ->React.array
          : <EmptyContainer>
              <img
                alt="No Report"
                src={isDarkMode ? Images.noDataDark : Images.noDataLight}
                className=Styles.noDataImage
              />
              <Heading
                size=Heading.H4
                value="No Report"
                align=Heading.Center
                weight=Heading.Regular
                color={theme.neutral_600}
              />
            </EmptyContainer>}
        {isMobile
          ? React.null
          : <Pagination
              currentPage=page
              totalElement=reportsCount
              pageSize
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i reportsSub=noData />
          : <RenderBody key={i->Belt.Int.toString} reportsSub=noData templateColumns />
      )
      ->React.array
    }}
  </div>
}
