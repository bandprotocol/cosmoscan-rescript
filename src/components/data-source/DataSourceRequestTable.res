module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let icon = style(. [width(#px(80)), height(#px(80))])
  let iconWrapper = style(. [
    width(#percent(100.)),
    display(#flex),
    flexDirection(#column),
    alignItems(#center),
  ])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~requestsSub: Sub.variant<RequestSub.Mini.t>, ~theme: Theme.t) => {
    <TBody>
      <Row alignItems=Row.Center>
        <Col col=Col.Two>
          {switch requestsSub {
          | Data({id}) => <TypeID.Request id />
          | _ => <LoadingCensorBar width=135 height=15 />
          }}
        </Col>
        <Col col=Col.Two>
          {switch requestsSub {
          | Data({feeEarned}) => <AmountRender coins=list{feeEarned} />
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </Col>
        <Col col=Col.Three>
          {switch requestsSub {
          | Data({oracleScriptID, oracleScriptName}) =>
            <div className={CssHelper.flexBox()}>
              <TypeID.OracleScript id=oracleScriptID />
              <HSpacing size=Spacing.sm />
              <Text value=oracleScriptName ellipsis=true color={theme.neutral_900} />
            </div>
          | _ => <LoadingCensorBar width=212 height=15 />
          }}
        </Col>
        <Col col=Col.Two>
          {switch requestsSub {
          | Data({minCount, askCount, reportsCount}) =>
            <ProgressBar
              reportedValidators=reportsCount minimumValidators=minCount requestValidators=askCount
            />
          | _ => <LoadingCensorBar width=168 height=15 />
          }}
        </Col>
        <Col col=Col.One>
          {switch requestsSub {
          | Data({resolveStatus}) =>
            <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
              <RequestStatus resolveStatus />
            </div>
          | _ => <LoadingCensorBar width=60 height=15 />
          }}
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch requestsSub {
            | Data({txTimestamp}) =>
              <Timestamp
                timeOpt=txTimestamp
                size=Text.Body2
                weight=Text.Regular
                textAlign=Text.Right
                defaultText="Syncing"
              />
            | _ => <LoadingCensorBar width=120 height=15 />
            }}
          </div>
        </Col>
      </Row>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~requestsSub: Sub.variant<RequestSub.Mini.t>) => {
    switch requestsSub {
    | Data({
        id,
        txTimestamp,
        oracleScriptID,
        oracleScriptName,
        minCount,
        askCount,
        reportsCount,
        resolveStatus,
        feeEarned,
      }) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Request ID", RequestID(id)),
            ("Fee Earned\n(BAND)", Coin({value: list{feeEarned}, hasDenom: false})),
            ("Oracle Script", OracleScript(oracleScriptID, oracleScriptName)),
            (
              "Report Status",
              ProgressBar({
                reportedValidators: reportsCount,
                minimumValidators: minCount,
                requestValidators: askCount,
              }),
            ),
            (
              "Timestamp",
              switch txTimestamp {
              | Some(txTimestamp') => Timestamp(txTimestamp')
              | None => Text("Syncing")
              },
            ),
          ]
        }
        key={id->ID.Request.toString}
        idx={id->ID.Request.toString}
        requestStatus=resolveStatus
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Request ID", Loading(70)),
            ("Fee Earned\n(BAND)", Loading(80)),
            ("Oracle Script", Loading(136)),
            ("Report Status", Loading(20)),
            ("Timestamp", Loading(166)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~dataSourceID: ID.DataSource.t) => {
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5

  let requestsSub = RequestSub.Mini.getListByDataSource(dataSourceID, ~pageSize, ~page)
  let totalRequestCountSub = RequestSub.countByDataSource(dataSourceID)

  let isMobile = Media.isMobile()

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.tableWrapper>
    {switch totalRequestCountSub {
    | Data(totalRequestCount) if totalRequestCount > 0 =>
      let pageCount = Page.getPageCount(totalRequestCount, pageSize)
      <>
        {isMobile
          ? <Row marginBottom=16>
              <Col>
                <div className={CssHelper.flexBox()}>
                  <Text
                    block=true
                    value={totalRequestCount->Format.iPretty}
                    weight=Text.Semibold
                    size=Text.Caption
                  />
                  <HSpacing size=Spacing.xs />
                  <Text
                    block=true
                    value="Requests"
                    weight=Text.Semibold
                    size=Text.Caption
                    transform=Text.Uppercase
                  />
                </div>
              </Col>
            </Row>
          : <>
              <THead>
                <Row alignItems=Row.Center>
                  <Col col=Col.Two>
                    <div className={CssHelper.flexBox()}>
                      <Text
                        block=true
                        value={totalRequestCount->Format.iPretty}
                        weight=Text.Semibold
                        transform=Text.Uppercase
                        size=Text.Caption
                      />
                      <HSpacing size=Spacing.xs />
                      <Text
                        block=true
                        value="Requests"
                        weight=Text.Semibold
                        transform=Text.Uppercase
                        size=Text.Caption
                      />
                    </div>
                  </Col>
                  <Col col=Col.Two>
                    <Text
                      block=true
                      value="Fee Earned"
                      weight=Text.Semibold
                      transform=Text.Uppercase
                      size=Text.Caption
                    />
                  </Col>
                  <Col col=Col.Three>
                    <Text
                      block=true
                      value="Oracle Script"
                      weight=Text.Semibold
                      transform=Text.Uppercase
                      size=Text.Caption
                    />
                  </Col>
                  <Col col=Col.Three>
                    <Text
                      block=true
                      value="Report Status"
                      size=Text.Caption
                      weight=Text.Semibold
                      transform=Text.Uppercase
                    />
                  </Col>
                  <Col col=Col.Two>
                    <Text
                      block=true
                      value="Timestamp"
                      weight=Text.Semibold
                      size=Text.Caption
                      align=Text.Right
                      transform=Text.Uppercase
                    />
                  </Col>
                </Row>
              </THead>
            </>}
        {switch requestsSub {
        | Data(requests) =>
          <>
            {requests
            ->Belt.Array.mapWithIndex((i, e) =>
              isMobile
                ? <RenderBodyMobile
                    key={e.id->ID.Request.toString} reserveIndex=i requestsSub={Sub.resolve(e)}
                  />
                : <RenderBody key={e.id->ID.Request.toString} theme requestsSub={Sub.resolve(e)} />
            )
            ->React.array}
            {isMobile
              ? React.null
              : <Pagination
                  currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)}
                />}
          </>
        | _ =>
          Belt.Array.make(pageSize, Sub.NoData)
          ->Belt.Array.mapWithIndex((i, noData) =>
            isMobile
              ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i requestsSub=noData />
              : <RenderBody key={i->Belt.Int.toString} theme requestsSub=noData />
          )
          ->React.array
        }}
      </>
    | Data(totalRequestCount) if totalRequestCount === 0 =>
      <EmptyContainer>
        <img
          alt="No Request Found"
          src={isDarkMode ? Images.noDataDark : Images.noDataLight}
          className=Styles.noDataImage
        />
        <Heading
          size=Heading.H4
          value="No Request Found"
          align=Heading.Center
          weight=Heading.Regular
          color={theme.neutral_600}
        />
      </EmptyContainer>
    | _ => React.null
    }}
  </div>
}
