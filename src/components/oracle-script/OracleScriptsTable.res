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

module SortableTHead = {
  @react.component
  let make = (
    ~title,
    ~asc,
    ~desc,
    ~toggle,
    ~sortedBy,
    ~isCenter=false,
    ~tooltipItem=?,
    ~tooltipPlacement=Text.AlignBottomStart,
  ) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.sortableTHead(isCenter)} onClick={_ => toggle(asc, desc)}>
      <Text
        block=true
        value=title
        size=Text.Caption
        weight=Text.Semibold
        transform=Text.Uppercase
        tooltipItem={tooltipItem->Belt.Option.mapWithDefault(React.null, React.string)}
        tooltipPlacement
      />
      <HSpacing size=Spacing.xs />
      {if sortedBy == asc {
        <Icon name="fas fa-caret-down" color={theme.neutral_600} />
      } else if sortedBy == desc {
        <Icon name="fas fa-caret-up" color={theme.neutral_600} />
      } else {
        <Icon name="fas fa-sort" color={theme.neutral_600} />
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
              | _ => <LoadingCensorBar width=100 height=15 />
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
  let (sortedBy, setSortedBy) = React.useState(_ => SortOSTable.IDDesc)

  let toggle = (sortedByAsc, sortedByDesc) =>
    if sortedBy == sortedByDesc {
      setSortedBy(_ => sortedByAsc)
      setPage(_ => 1)
    } else {
      setSortedBy(_ => sortedByDesc)
      setPage(_ => 1)
    }

  let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)

  let oracleScriptsCountSub = OracleScriptSub.count(~searchTerm, ())
  let oracleScriptsSub = OracleScriptSub.getList(~pageSize, ~page, ~searchTerm, ~sortedBy, ())

  let allSub = Sub.all2(oracleScriptsSub, oracleScriptsCountSub)

  <div>
    {isMobile
      ? React.null
      : <div className={Css.merge(list{Styles.tablehead, Styles.outer})}>
          <div>
            <SortableTHead title="ID" asc=SortOSTable.IDAsc desc=IDDesc toggle sortedBy />
          </div>
          <div>
            <SortableTHead
              title="Oracle Script Name" asc=SortOSTable.NameAsc desc=NameDesc toggle sortedBy
            />
          </div>
          <div>
            <SortableTHead
              title="Version"
              asc=SortOSTable.VersionAsc
              desc=SortOSTable.VersionDesc
              toggle
              sortedBy
              isCenter=true
            />
          </div>
          <div>
            <SortableTHead
              title="24hr Requests"
              asc=SortOSTable.RequestAsc
              desc=SortOSTable.RequestDesc
              toggle
              sortedBy
              isCenter=true
            />
          </div>
          <div>
            <SortableTHead
              title="Response Time"
              asc=SortOSTable.ResponseAsc
              desc=SortOSTable.ResponseDesc
              toggle
              sortedBy
              isCenter=true
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
              ->SortOSTable.sorting(sortedBy)
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
          //   isMobile
          //     ? <RenderBodyMobile
          //         key={i->Belt.Int.toString} reserveIndex=i oracleScriptSub=NoData statsSub=NoData
          //       />
          //     : <RenderBody
          //         key={i->Belt.Int.toString} reserveIndex=i oracleScriptSub=NoData statsSub=NoData
          //       />
          <> </>
        )->React.array}
      </div>
    }}
  </div>
}
