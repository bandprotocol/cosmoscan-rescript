module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let sortableTHead = isCenter =>
    style(. [
      display(#flex),
      flexDirection(#row),
      alignItems(#center),
      cursor(#pointer),
      justifyContent(isCenter ? #center : #flexStart),
    ])

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

module SortDropdown = {
  module StylesDropdown = {
    open CssJs
    let dropdownContainer = style(. [
      position(#relative),
      display(#flex),
      alignItems(#center),
      justifyContent(#center),
      cursor(#pointer),
    ])

    let dropdownSelected = style(. [
      display(#flex),
      alignItems(#center),
      padding2(~v=#px(8), ~h=#zero),
    ])

    let dropdownMenu = (theme: Theme.t, isDarkMode, isShow) =>
      style(. [
        position(#absolute),
        top(#px(40)),
        left(#px(0)),
        width(#px(270)),
        backgroundColor(theme.neutral_000),
        borderRadius(#px(8)),
        padding2(~v=#px(8), ~h=#px(0)),
        zIndex(1),
        boxShadow(
          Shadow.box(
            ~x=#zero,
            ~y=#px(2),
            ~blur=#px(4),
            ~spread=#px(1),
            rgba(16, 18, 20, #num(0.15)),
          ),
        ),
        selector(" > ul + ul", [borderTop(#px(1), #solid, theme.neutral_300)]),
        display(isShow ? #block : #none),
      ])

    let menuItem = (theme: Theme.t, isDarkMode) =>
      style(. [
        position(#relative),
        display(#flex),
        alignItems(#center),
        justifyContent(#flexStart),
        padding4(~top=#px(10), ~right=#px(16), ~bottom=#px(10), ~left=#px(38)),
        cursor(#pointer),
        marginTop(#zero),
        selector("&:hover", [backgroundColor(isDarkMode ? theme.neutral_200 : theme.neutral_100)]),
        selector(
          "i",
          [
            position(#absolute),
            left(#px(18)),
            top(#percent(50.)),
            transform(#translateY(#percent(-50.))),
          ],
        ),
      ])
  }
  @react.component
  let make = (~sortedBy, ~setSortedBy, ~direction, ~setDirection) => {
    let (show, setShow) = React.useState(_ => false)
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className=StylesDropdown.dropdownContainer>
      <div
        className={StylesDropdown.dropdownSelected}
        onClick={event => {
          setShow(oldVal => !oldVal)
          ReactEvent.Mouse.stopPropagation(event)
        }}>
        <Text
          value={sortedBy->DataSourceSub.parseSortString ++
          "( " ++
          direction->DataSourceSub.parseDirection ++ " )"}
          size={Body1}
          color=theme.neutral_900
          weight={Semibold}
        />
        <HSpacing size=Spacing.sm />
        {show
          ? <Icon name="far fa-angle-up" color={theme.neutral_900} />
          : <Icon name="far fa-angle-down" color={theme.neutral_900} />}
      </div>
      <div className={StylesDropdown.dropdownMenu(theme, isDarkMode, show)}>
        <ul>
          {[DataSourceSub.ID, DataSourceSub.Name, DataSourceSub.TotalRequest]
          ->Belt.Array.mapWithIndex((i, each) => {
            <li
              key={i->Belt.Int.toString}
              className={StylesDropdown.menuItem(theme, isDarkMode)}
              onClick={_ => {
                setSortedBy(_ => each)
                setShow(_ => false)
              }}>
              {sortedBy == each
                ? <Icon name="fal fa-check" size=12 color=theme.neutral_900 />
                : React.null}
              <Text
                value={each->DataSourceSub.parseSortString}
                size={Body1}
                weight={Semibold}
                color={theme.neutral_900}
              />
            </li>
          })
          ->React.array}
        </ul>
        <ul>
          {[DataSourceSub.ASC, DataSourceSub.DESC]
          ->Belt.Array.mapWithIndex((i, each) => {
            <li
              className={StylesDropdown.menuItem(theme, isDarkMode)}
              key={i->Belt.Int.toString}
              onClick={_ => {
                setDirection(_ => each)
                setShow(_ => false)
              }}>
              {direction == each
                ? <Icon name="fal fa-check" size=12 color=theme.neutral_900 />
                : React.null}
              <Text
                value={switch each {
                | DataSourceSub.ASC => "Ascending (smallest value first)"
                | DESC => "Descending (largest value first)"
                }}
                size={Body1}
                weight={Semibold}
                color={theme.neutral_900}
              />
            </li>
          })
          ->React.array}
        </ul>
      </div>
    </div>
  }
}

module SortableTHead = {
  @react.component
  let make = (
    ~title,
    ~direction,
    ~toggle,
    ~value,
    ~sortedBy,
    ~isCenter=false,
    ~tooltipItem=?,
    ~tooltipPlacement=Text.AlignBottomStart,
  ) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.sortableTHead(isCenter)} onClick={_ => toggle(direction, value)}>
      <Text
        block=true
        value=title
        size=Text.Caption
        weight=Text.Semibold
        transform=Text.Uppercase
        tooltipItem={tooltipItem->Belt.Option.mapWithDefault(React.null, React.string)}
        tooltipPlacement
        color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
      />
      <HSpacing size=Spacing.xs />
      {if direction == DataSourceSub.ASC {
        <Icon
          name="fas fa-caret-down" color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
        />
      } else if direction == DataSourceSub.DESC {
        <Icon
          name="fas fa-caret-up" color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
        />
      } else {
        <Icon
          name="fas fa-sort" color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
        />
      }}
    </div>
  }
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
          | _ => <LoadingCensorBar width=150 height=15 />
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
              weight=Text.Medium
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
            value="Last Requested"
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
  let (direction, setDirection) = React.useState(_ => DataSourceSub.DESC)

  let toggle = (direction, sortValue) => {
    setSortedBy(_ => sortValue)
    setDirection(_ => {
      switch direction {
      | DataSourceSub.ASC => DataSourceSub.DESC
      | DataSourceSub.DESC => DataSourceSub.ASC
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
          <SortDropdown sortedBy setSortedBy direction setDirection />
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
              isCenter=true
              value=DataSourceSub.TotalRequest
            />
          </div>
          <div>
            <Text
              block=true
              value="Last Requested"
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
            let pageCount = Page.getPageCount(datasourcesCount, pageSize)
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
                currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)}
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
      <div>
        {Belt.Array.makeBy(10, i =>
          isMobile
            ? <RenderBodyMobile
                key={i->Belt.Int.toString} reserveIndex=i datasourceSub=Sub.NoData searchTerm
              />
            : <RenderBody
                key={i->Belt.Int.toString} reserveIndex=i datasourceSub=Sub.NoData searchTerm
              />
        )->React.array}
      </div>
    }}
  </div>
}
