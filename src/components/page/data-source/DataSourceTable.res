module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let tablehead = style(. [
    display(#flex),
    alignItems(#center),
    flexWrap(#wrap),
    justifyContent(#spaceBetween),
    width(#percent(100.)),
    selector("> div", [width(#percent(16.)), textAlign(#center)]),
    selector("> div:first-child", [width(#percent(8.))]),
    selector("> div:nth-child(2)", [width(#percent(44.))]),
    Media.mobile([
      selector("> div", [width(#percent(20.))]),
      selector("> div:first-child", [width(#percent(5.))]),
      selector("> div:nth-child(2)", [width(#percent(35.))]),
    ]),
  ])

  let tableItem = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      padding2(~v=#px(16), ~h=#px(32)),
      borderRadius(#px(16)),
      marginBottom(#px(8)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      border(#px(1), #solid, theme.neutral_100),
      Media.mobile([padding2(~v=#px(16), ~h=#px(16))]),
    ])

  let outer = style(. [
    padding2(~v=#zero, ~h=#px(32)),
    Media.mobile([padding2(~v=#px(0), ~h=#px(16)), marginTop(#px(16))]),
  ])
  let link = (theme: Theme.t) =>
    style(. [
      cursor(pointer),
      selector("&:hover span", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=150, "all")]),
    ])
}

module RenderBody = {
  @react.component
  let make = (~datasourceSub: Sub.variant<DataSourceSub.t>, ~reserveIndex, ~searchTerm) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.tableItem(theme, isDarkMode)}>
      <div
        className={Styles.tablehead}
        key={switch datasourceSub {
        | Data({id}) => id->ID.DataSource.toString
        | _ => reserveIndex->Belt.Int.toString
        }}>
        <div>
          {switch datasourceSub {
          | Data({id, name}) =>
            <div className={CssHelper.flexBox()}>
              <TypeID.DataSource id weight={Bold} />
            </div>
          | _ => <LoadingCensorBar width=20 height=15 />
          }}
        </div>
        <div>
          {switch datasourceSub {
          | Data({id, name}) =>
            <Link
              className={Css.merge(list{Styles.link(theme)})}
              route={DataSourceDetailsPage(id->ID.DataSource.toInt, DataSourceRequests)}>
              <Text value=name ellipsis=true color={theme.primary_600} size={Body1} />
            </Link>
          | _ => <LoadingCensorBar width=150 height=22 />
          }}
        </div>
        <div>
          {switch datasourceSub {
          | Data({fee}) =>
            <div
              className={Css.merge(list{CssHelper.flexBox(~align=#center, ~justify=#center, ())})}>
              <AmountRender coins=fee size={Body1} pos={Fee} color={theme.neutral_900} />
            </div>
          | _ => <LoadingCensorBar width=70 height=15 />
          }}
        </div>
        <div>
          {switch datasourceSub {
          | Data({requestCount}) =>
            <Text
              value={requestCount->Format.iPretty}
              weight=Text.Regular
              block=true
              ellipsis=true
              align={Center}
              color={theme.neutral_900}
              size={Body1}
              code=true
            />
          | _ => <LoadingCensorBar width=150 height=15 />
          }}
        </div>
        <div>
          {switch datasourceSub {
          | Data({timestamp: timestampOpt}) =>
            switch timestampOpt {
            | Some(timestamp') =>
              <Timestamp time=timestamp' size=Text.Body1 weight=Text.Regular textAlign=Text.Right />
            | None => <Text size=Text.Body2 value="Genesis" align={Center} />
            }
          | _ => <LoadingCensorBar width=150 height=15 />
          }}
        </div>
      </div>
    </div>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~datasourceSub: Sub.variant<DataSourceSub.t>, ~reserveIndex, ~searchTerm) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)
    let isMobile = Media.isMobile()

    <div className={Styles.tableItem(theme, isDarkMode)}>
      <Row marginBottom={16} alignItems={Row.Center}>
        <Col colSm=Col.Five>
          <Text
            value="ID" ellipsis=false color={theme.neutral_600} size={Body1} weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch datasourceSub {
          | Data({id, name}) =>
            <div className={CssHelper.flexBox()}>
              <TypeID.DataSource id weight={Bold} size={Xl} />
            </div>
          | _ => <LoadingCensorBar width=20 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16} alignItems={Row.Center}>
        <Col colSm=Col.Five>
          <Text
            value="Data Source"
            ellipsis=false
            color={theme.neutral_600}
            size={Body1}
            weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch datasourceSub {
          | Data({id, name}) =>
            <Link
              className={Css.merge(list{Styles.link(theme)})}
              route={DataSourceDetailsPage(id->ID.DataSource.toInt, DataSourceRequests)}>
              <Text value=name ellipsis=false color={theme.primary_600} size={Xl} />
            </Link>
          | _ => <LoadingCensorBar width=150 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16} alignItems={Row.Center}>
        <Col colSm=Col.Five>
          // Fee is string, cannot be sorted
          <Text
            value="Fee (BAND)"
            ellipsis=false
            color={theme.neutral_600}
            size={Body1}
            weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch datasourceSub {
          | Data({fee}) =>
            <div className={CssHelper.flexBox(~justify=#flexStart, ())}>
              <AmountRender coins=fee size={Xl} pos={Fee} color={theme.neutral_900} />
            </div>
          | _ => <LoadingCensorBar width=70 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16} alignItems={Row.Center}>
        <Col colSm=Col.Five>
          <Text
            value="Total Requests"
            ellipsis=false
            color={theme.neutral_600}
            size={Body1}
            weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch datasourceSub {
          | Data({requestCount}) =>
            /* TODO: change to data_source_requests_aggregate_per_day when data is ready */
            <Text
              value={requestCount->Format.iPretty}
              weight=Text.Medium
              block=true
              ellipsis=true
              align={Left}
              size={Xl}
              color={theme.neutral_900}
            />
          | _ => <LoadingCensorBar width=150 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16} alignItems={Row.Center}>
        <Col colSm=Col.Five>
          <Text
            value="Last Updated"
            ellipsis=false
            color={theme.neutral_600}
            size={Body1}
            weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch datasourceSub {
          | Data({timestamp: timestampOpt}) =>
            /* TODO: change to last_request when data is ready */
            switch timestampOpt {
            | Some(timestamp') =>
              <Timestamp time=timestamp' size=Text.Xl weight=Text.Regular textAlign=Text.Right />
            | None => <Text size=Text.Xl value="Genesis" align={Center} />
            }
          | _ => <LoadingCensorBar width=150 height=15 />
          }}
        </Col>
      </Row>
    </div>
  }
}

@react.component
let make = (~searchTerm) => {
  let isMobile = Media.isSmallMobile()
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 10
  let (sortedBy, setSortedBy) = React.useState(_ => DataSourceSub.TotalRequest)
  let (direction, setDirection) = React.useState(_ => Sort.DESC)

  let toggle = (direction, sortValue) => {
    setSortedBy(_ => sortValue)
    setDirection(_ => {
      switch direction {
      | Sort.ASC => DESC
      | DESC => ASC
      }
    })
  }

  let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

  let dataSourcesCountSub = DataSourceSub.count(~searchTerm, ())
  //   let dataSourcesSub = DataSourceSub.getList(~pageSize, ~page, ~searchTerm, ~sortedBy, ())
  let dataSourcesSub = DataSourceSub.getList(
    ~pageSize,
    ~page,
    ~searchTerm,
    ~sortBy=sortedBy,
    ~sortDirection=direction,
    (),
  )

  let allSub = Sub.all2(dataSourcesSub, dataSourcesCountSub)

  React.useEffect1(() => {
    if searchTerm !== "" {
      setPage(_ => 1)
    }
    None
  }, [searchTerm])

  <div>
    {isMobile
      ? <div className={CssHelper.flexBox(~align=#center, ())}>
          <Text value="Sort By" size={Body1} />
          <HSpacing size=Spacing.sm />
          <SortDropdown
            sortedBy
            setSortedBy
            direction
            setDirection
            options={[DataSourceSub.ID, Name, TotalRequest]}
            optionToString={DataSourceSub.parseSortString}
          />
        </div>
      : <div className={Css.merge(list{Styles.tablehead, Styles.outer})}>
          <div>
            <SortableTHead title="ID" direction toggle value=DataSourceSub.ID sortedBy />
          </div>
          <div>
            <SortableTHead
              title="Data Source Name" direction toggle sortedBy value=DataSourceSub.Name
            />
          </div>
          <div>
            <Text
              block=true
              value="Fee (BAND)"
              size=Text.Caption
              weight=Text.Semibold
              transform=Text.Uppercase
              align={Center}
            />
          </div>
          <div>
            <SortableTHead
              title="Total Requests"
              toggle
              sortedBy
              direction
              justify=Center
              value=DataSourceSub.TotalRequest
            />
          </div>
          <div>
            <Text
              block=true
              value="Last Updated"
              size=Text.Caption
              weight=Text.Semibold
              transform=Text.Uppercase
              align={Center}
            />
          </div>
        </div>}
    {switch allSub {
    | Sub.Data(datasources, datasourcesCount) =>
      datasources->Belt.Array.length > 0
        ? {
            <div className={CssHelper.mt(~size=8, ())}>
              {datasources
              ->Belt.Array.mapWithIndex((i, e) =>
                isMobile
                  ? <RenderBodyMobile
                      key={e.id->ID.DataSource.toString}
                      reserveIndex=i
                      datasourceSub={Sub.resolve(e)}
                      searchTerm
                    />
                  : <RenderBody
                      key={e.id->ID.DataSource.toString}
                      datasourceSub={Sub.resolve(e)}
                      reserveIndex=i
                      searchTerm
                    />
              )
              ->React.array}
              <Pagination
                currentPage=page
                totalElement=datasourcesCount
                pageSize
                onPageChange={newPage => setPage(_ => newPage)}
                onChangeCurrentPage={newPage => setPage(_ => newPage)}
              />
            </div>
          }
        : <EmptyContainer>
            <img
              src={isDarkMode ? Images.noOracleDark : Images.noOracleLight}
              className=Styles.noDataImage
              alt="0 Data Sources Found"
            />
            <Heading
              size=Heading.H4
              value="0 Data Sources Found"
              align=Heading.Center
              weight=Heading.Regular
              color={theme.neutral_600}
            />
          </EmptyContainer>
    | _ =>
      <div className={CssHelper.mt(~size=8, ())}>
        {Belt.Array.makeBy(10, i =>
          isMobile
            ? <RenderBodyMobile
                key={i->Belt.Int.toString} reserveIndex=i datasourceSub=Sub.NoData searchTerm
              />
            : <RenderBody
                key={i->Belt.Int.toString} reserveIndex=i datasourceSub=Sub.NoData searchTerm
              />
        )->React.array}
        <div
          className={Css.merge(list{
            CssHelper.flexBox(~justify=#center, ()),
            CssHelper.mt(~size=32, ()),
            CssHelper.mb(~size=32, ()),
          })}>
          <LoadingCensorBar width=200 height=32 />
        </div>
      </div>
    }}
  </div>
}
