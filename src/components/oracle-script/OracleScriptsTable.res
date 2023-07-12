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
    selector("> div", [width(#percent(12.)), textAlign(#center)]),
    selector("> div:first-child", [width(#percent(5.))]),
    selector("> div:nth-child(2)", [width(#percent(37.))]),
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

  let outer = style(. [padding2(~v=#zero, ~h=#px(32))])
  let link = (theme: Theme.t) =>
    style(. [
      cursor(pointer),
      selector("&:hover span", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=200, "all")]),
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
          value={sortedBy->SortOSTable.parseSortString ++
          "( " ++
          direction->SortOSTable.parseDirection ++ " )"}
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
          {[
            SortOSTable.ID,
            SortOSTable.Name,
            SortOSTable.Version,
            SortOSTable.Request,
            SortOSTable.Response,
          ]
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
                value={each->SortOSTable.parseSortString}
                size={Body1}
                weight={Semibold}
                color={theme.neutral_900}
              />
            </li>
          })
          ->React.array}
        </ul>
        <ul>
          {[SortOSTable.ASC, SortOSTable.DESC]
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
                | SortOSTable.ASC => "Ascending (smallest value first)"
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
      {if direction == SortOSTable.ASC {
        <Icon
          name="fas fa-caret-down" color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
        />
      } else if direction == SortOSTable.DESC {
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

module RenderBodyMobile = {
  @react.component
  let make = (
    ~oracleScriptSub: Sub.variant<OracleScriptSub.t_with_stats>,
    ~reserveIndex,
    ~searchTerm,
  ) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)
    let isMobile = Media.isMobile()

    <div className={Styles.tableItem(theme, isDarkMode)}>
      <Row marginBottom={8}>
        <Col col=Col.Twelve>
          {switch oracleScriptSub {
          | Data({id, name}) =>
            <div className={CssHelper.flexBox()}>
              <TypeID.OracleScript id weight={Bold} size={Xl} />
            </div>
          | _ => <LoadingCensorBar width=20 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16}>
        <Col col=Col.Twelve>
          {switch oracleScriptSub {
          | Data({id, name}) =>
            <Link
              className={Css.merge(list{Styles.link(theme)})}
              route={OracleScriptDetailsPage(id->ID.OracleScript.toInt, OracleScriptRequests)}>
              <Text value=name ellipsis=false color={theme.primary_600} size={Xl} />
            </Link>
          | _ => <LoadingCensorBar width=150 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16}>
        <Col colSm=Col.Five>
          <Text
            value="Version" ellipsis=false color={theme.neutral_600} size={Body1} weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch oracleScriptSub {
          | Data({version}) =>
            <div>
              {switch version {
              | Ok => <VersionChip value="Upgraded" color=VersionChip.Success />
              | Redeploy => <VersionChip value="Redeployment Needed" color=VersionChip.Warning />
              | Nothing => React.null
              }}
            </div>
          | _ => <LoadingCensorBar width=70 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16}>
        <Col colSm=Col.Five>
          <Text
            value="24 hr Requests"
            ellipsis=false
            color={theme.neutral_600}
            size={Body1}
            weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch oracleScriptSub {
          | Data({id, stat}) =>
            <Text
              value={stat.count->Format.iPretty}
              block=true
              color={theme.neutral_900}
              size={Body1}
              code=true
            />
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16}>
        <Col colSm=Col.Five>
          <Text
            value="Response Time"
            ellipsis=false
            color={theme.neutral_600}
            size={Body1}
            weight={Semibold}
          />
        </Col>
        <Col colSm=Col.Seven>
          {switch oracleScriptSub {
          | Data({id, stat}) =>
            stat.responseTime == 0.0
              ? <Text value="TBD" size={Body1} />
              : <Text
                  value={stat.responseTime->Format.fPretty(~digits=2) ++ " s"}
                  block=true
                  color={theme.neutral_900}
                  size={Body1}
                  code=true
                />
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </Col>
      </Row>
      <Row marginBottom={16}>
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
          {switch oracleScriptSub {
          | Data({id}) => {
              let latestTxTimestamp = OracleScriptSub.getLatestRequestTimestampByID(id)
              switch latestTxTimestamp {
              | Data(Some({transaction})) =>
                <TimeAgos time={transaction.block.timestamp} size={Body1} />

              | Data(None) => <Text value="N/A" size={Body1} />
              | _ => <LoadingCensorBar width=100 height=15 />
              }
            }

          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </Col>
      </Row>
    </div>
  }
}

module RenderBody = {
  @react.component
  let make = (
    ~oracleScriptSub: Sub.variant<OracleScriptSub.t_with_stats>,
    ~reserveIndex,
    ~searchTerm,
  ) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.tableItem(theme, isDarkMode)}>
      <div
        className={Styles.tablehead}
        key={switch oracleScriptSub {
        | Data({id}) => id->ID.OracleScript.toString
        | _ => reserveIndex->Belt.Int.toString
        }}>
        <div>
          {switch oracleScriptSub {
          | Data({id, name}) =>
            <div className={CssHelper.flexBox()}>
              <TypeID.OracleScript id weight={Bold} />
            </div>
          | _ => <LoadingCensorBar width=20 height=15 />
          }}
        </div>
        <div>
          {switch oracleScriptSub {
          | Data({id, name}) =>
            <Link
              className={Css.merge(list{Styles.link(theme)})}
              route={OracleScriptDetailsPage(id->ID.OracleScript.toInt, OracleScriptRequests)}>
              <Text value=name ellipsis=true color={theme.primary_600} size={Body1} />
            </Link>
          | _ => <LoadingCensorBar width=150 height=15 />
          }}
        </div>
        <div>
          {switch oracleScriptSub {
          | Data({version}) =>
            <div>
              {switch version {
              | Ok => <VersionChip value="Upgraded" color=VersionChip.Success />
              | Redeploy => <VersionChip value="Redeployment Needed" color=VersionChip.Warning />
              | Nothing => React.null
              }}
            </div>
          | _ => <LoadingCensorBar width=70 height=15 />
          }}
        </div>
        <div>
          {switch oracleScriptSub {
          | Data({id, stat}) =>
            <Text
              value={stat.count->Format.iPretty}
              block=true
              color={theme.neutral_900}
              size={Body1}
              code=true
              align={Center}
            />
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </div>
        <div>
          {switch oracleScriptSub {
          | Data({id, stat}) =>
            stat.responseTime == 0.0
              ? <Text value="TBD" align={Center} size={Body1} />
              : <Text
                  value={stat.responseTime->Format.fPretty(~digits=2) ++ " s"}
                  block=true
                  color={theme.neutral_900}
                  size={Body1}
                  code=true
                  align={Center}
                />
          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </div>
        <div>
          {switch oracleScriptSub {
          | Data({id}) => {
              let latestTxTimestamp = OracleScriptSub.getLatestRequestTimestampByID(id)
              switch latestTxTimestamp {
              | Data(Some({transaction})) =>
                <TimeAgos time={transaction.block.timestamp} size={Body1} />

              | Data(None) => <Text value="N/A" size={Body1} align={Center} />
              | _ => <LoadingCensorBar width=100 height=15 />
              }
            }

          | _ => <LoadingCensorBar width=100 height=15 />
          }}
        </div>
      </div>
      <div>
        {searchTerm == ""
          ? React.null
          : {
              switch oracleScriptSub {
              | Data({relatedDataSources}) =>
                let datasourceFound =
                  relatedDataSources->Belt.List.keep(each =>
                    each.dataSourceName
                    ->Js.String2.toLowerCase
                    ->Js.String2.includes(searchTerm->Js.String2.toLowerCase)
                  )

                datasourceFound->Belt.List.size > 0
                  ? <div
                      className={Css.merge(list{CssHelper.flexBox(), CssHelper.mt(~size=8, ())})}>
                      <Text value={"Data Source Used:"} size={Body1} />
                      <HSpacing size=Spacing.sm />
                      {datasourceFound
                      ->Belt.List.toArray
                      ->Belt.Array.slice(~offset=0, ~len=3)
                      ->Belt.Array.mapWithIndex((ind, each) => {
                        <>
                          <div
                            className={CssHelper.flexBox()}
                            key={each.dataSourceID->ID.DataSource.toInt->Belt.Int.toString}>
                            <TypeID.DataSource id=each.dataSourceID size={Body1} />
                            <HSpacing size=Spacing.sm />
                            <Text
                              value=each.dataSourceName
                              ellipsis=true
                              color={theme.neutral_900}
                              size={Body1}
                            />
                          </div>
                          {if ind < datasourceFound->Belt.List.size - 1 {
                            <>
                              <Text value="," size={Body1} />
                              <HSpacing size=Spacing.sm />
                            </>
                          } else {
                            React.null
                          }}
                        </>
                      })
                      ->React.array}
                      {datasourceFound->Belt.List.size > 2
                        ? <>
                            <Text value="..." size={Body1} />
                          </>
                        : React.null}
                    </div>
                  : React.null
              | _ => React.null
              }
            }}
      </div>
    </div>
  }
}

@react.component
let make = (~searchTerm) => {
  let isMobile = Media.isMobile()
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 10
  let (sortedBy, setSortedBy) = React.useState(_ => SortOSTable.Request)
  let (direction, setDirection) = React.useState(_ => SortOSTable.DESC)

  let toggle = (direction, sortValue) => {
    setSortedBy(_ => sortValue)
    setDirection(_ => {
      switch direction {
      | SortOSTable.ASC => SortOSTable.DESC
      | SortOSTable.DESC => SortOSTable.ASC
      }
    })
  }

  let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

  let oracleScriptsCountSub = OracleScriptSub.count(~searchTerm, ())
  let oracleScriptsSub = OracleScriptSub.getList(~pageSize, ~page, ~searchTerm, ~sortedBy, ())

  let allSub = Sub.all2(oracleScriptsSub, oracleScriptsCountSub)

  <div>
    {isMobile
      ? <div className={CssHelper.flexBox(~align=#center, ())}>
          <Text value="Sort By" size={Body1} />
          <HSpacing size=Spacing.sm />
          <SortDropdown sortedBy setSortedBy direction setDirection />
        </div>
      : <div className={Css.merge(list{Styles.tablehead, Styles.outer})}>
          <div>
            <SortableTHead title="ID" direction toggle value=SortOSTable.ID sortedBy />
          </div>
          <div>
            <SortableTHead
              title="Oracle Script Name" direction toggle sortedBy value=SortOSTable.Name
            />
          </div>
          <div>
            <SortableTHead
              title="Version" toggle sortedBy direction isCenter=true value=SortOSTable.Version
            />
          </div>
          <div>
            <SortableTHead
              title="24hr Requests"
              toggle
              sortedBy
              direction
              isCenter=true
              value=SortOSTable.Request
            />
          </div>
          <div>
            <SortableTHead
              title="Response Time"
              toggle
              sortedBy
              direction
              isCenter=true
              value=SortOSTable.Response
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
    | Sub.Data(oracleScripts, oracleScriptsCount) =>
      oracleScripts->Belt.Array.length > 0
        ? {
            let pageCount = Page.getPageCount(oracleScriptsCount, pageSize)
            <div className={CssHelper.mt(~size=8, ())}>
              {oracleScripts
              ->SortOSTable.sorting(~sortedBy, ~direction)
              ->Belt.Array.slice(
                ~offset={
                  (page - 1) * pageSize
                },
                ~len=pageSize,
              )
              ->Belt.Array.mapWithIndex((i, e) =>
                isMobile
                  ? <RenderBodyMobile
                      key={e.id->ID.OracleScript.toString}
                      reserveIndex=i
                      oracleScriptSub={Sub.resolve(e)}
                      searchTerm
                    />
                  : <RenderBody
                      key={e.id->ID.OracleScript.toString}
                      oracleScriptSub={Sub.resolve(e)}
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
              alt="No OracleScript"
            />
            <Heading
              size=Heading.H4
              value="No OracleScript"
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
                key={i->Belt.Int.toString} reserveIndex=i oracleScriptSub=Sub.NoData searchTerm
              />
            : <RenderBody
                key={i->Belt.Int.toString} reserveIndex=i oracleScriptSub=Sub.NoData searchTerm
              />
        )->React.array}
      </div>
    }}
  </div>
}
