module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~reporterSub: Sub.variant<Address.t>) => {
    <TBody>
      <Row alignItems=Row.Center minHeight={#px(30)}>
        <Col>
          {switch reporterSub {
          | Data(address) => <AddressRender address />
          | _ => <LoadingCensorBar width=300 height=15 />
          }}
        </Col>
      </Row>
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
          [("Reporter", Address(address, 200, #account))]
        }
        key={address->Address.toBech32}
        idx={address->Address.toBech32}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [("Reporter", Loading(150))]
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
  <div className=Styles.tableWrapper>
    {isMobile
      ? <Row marginBottom=16>
          <Col>
            {switch allSub {
            | Data((_, reporterCount)) =>
              <div className={CssHelper.flexBox()}>
                <Text
                  block=true
                  value={reporterCount->Belt.Int.toString}
                  weight=Text.Semibold
                  transform=Text.Uppercase
                  size=Text.Caption
                />
                <HSpacing size=Spacing.xs />
                <Text
                  block=true
                  value="Reporters"
                  weight=Text.Semibold
                  transform=Text.Uppercase
                  size=Text.Caption
                />
              </div>
            | _ => <LoadingCensorBar width=100 height=15 />
            }}
          </Col>
        </Row>
      : <THead>
          <Row alignItems=Row.Center>
            <Col>
              {switch allSub {
              | Data((_, reporterCount)) =>
                <div className={CssHelper.flexBox()}>
                  <Text
                    block=true
                    value={reporterCount->Belt.Int.toString}
                    weight=Text.Semibold
                    transform=Text.Uppercase
                    size=Text.Caption
                  />
                  <HSpacing size=Spacing.xs />
                  <Text
                    block=true
                    value="Reporters"
                    weight=Text.Semibold
                    transform=Text.Uppercase
                    size=Text.Caption
                  />
                </div>
              | _ => <LoadingCensorBar width=100 height=15 />
              }}
            </Col>
          </Row>
        </THead>}
    {switch allSub {
    | Data((reporters, reporterCount)) =>
      let pageCount = Page.getPageCount(reporterCount, pageSize)
      <>
        {reporterCount > 0
          ? reporters
            ->Belt.Array.mapWithIndex((i, e) =>
              isMobile
                ? <RenderBodyMobile
                    key={e |> Address.toBech32} reserveIndex=i reporterSub={Sub.resolve(e)}
                  />
                : <RenderBody key={e |> Address.toBech32} reporterSub={Sub.resolve(e)} />
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
              currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)}
            />}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={Belt.Int.toString(i)} reserveIndex=i reporterSub=noData />
          : <RenderBody key={Belt.Int.toString(i)} reporterSub=noData />
      )
      ->React.array
    }}
  </div>
}
