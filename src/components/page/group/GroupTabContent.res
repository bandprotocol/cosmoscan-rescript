module Styles = {
  open CssJs

  let tabContentWrapper = style(. [marginTop(#px(20)), marginBottom(#px(40))])
  let tableHeadWrapper = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_200),
      paddingBottom(#px(16)),
      Media.mobile([padding2(~v=#zero, ~h=#zero)]),
    ])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let infoContainer = style(. [padding2(~v=#px(24), ~h=#px(32)), marginTop(#px(16))])

  let toggle = style(. [cursor(#pointer)])

  let tablehead = style(. [
    display(#flex),
    alignItems(#center),
    flexWrap(#wrap),
    justifyContent(#spaceBetween),
    width(#percent(100.)),
    selector("> div", [minWidth(#percent(12.)), textAlign(#center)]),
    selector("> div:nth-child(2)", [minWidth(#percent(50.))]),
    Media.mobile([
      selector("> div", [minWidth(#percent(20.))]),
      selector("> div:nth-child(2)", [minWidth(#percent(20.))]),
      selector("> div:first-child", [minWidth(#percent(60.))]),
    ]),
  ])

  let outer = style(. [padding2(~v=#zero, ~h=#px(32))])

  let tableContentWrapper = style(. [
    selector("> div:last-child", [borderBottom(#px(0), #solid, #transparent)]),
  ])

  let noDataContainer = style(. [
    display(#flex),
    justifyContent(#center),
    padding2(~v=#px(8), ~h=#px(0)),
  ])
}

module SortableTHead = {
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
  }
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
    let isMobile = Media.isMobile()

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
      {isMobile
        ? React.null
        : {
            if direction == SortGroupTable.ASC {
              <Icon
                name="fas fa-caret-down"
                color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
              />
            } else if direction == SortGroupTable.DESC {
              <Icon
                name="fas fa-caret-up"
                color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
              />
            } else {
              <Icon
                name="fas fa-sort" color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
              />
            }
          }}
    </div>
  }
}

module NoAccountContent = {
  @react.component
  let make = () => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="My Group" />
      <InfoContainer style=Styles.infoContainer>
        <div className=Styles.noDataContainer>
          <Text value="Connect Wallet to see your group" color={theme.neutral_600} size={Body1} />
        </div>
      </InfoContainer>
    </div>
  }
}

module MyGroupTabContent = {
  @react.component
  let make = (~sortedBy, ~toggle, ~direction, ~account: AccountContext.t) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let pageSize = 10
    let (page, setPage) = React.useState(_ => 1)

    let myGroupSub = GroupSub.getListByAccount(
      ~address=account.address->Address.toBech32,
      ~page,
      ~pageSize,
      (),
    )

    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="My Group" />
      {switch myGroupSub {
      | Data(groups) =>
        let pageCount = Page.getPageCount(groups->Belt.Array.length, pageSize)

        <>
          <InfoContainer style=Styles.infoContainer>
            <Table>
              <div className={Css.merge(list{"table-wrapper", Styles.tableHeadWrapper(theme)})}>
                <div className={Css.merge(list{Styles.tablehead})}>
                  <div>
                    <SortableTHead
                      title="Group ID" direction toggle value=SortGroupTable.ID sortedBy
                    />
                  </div>
                  {isMobile
                    ? React.null
                    : <div>
                        <SortableTHead
                          title="Group Name" direction toggle sortedBy value=SortGroupTable.Name
                        />
                      </div>}
                  <div>
                    <SortableTHead
                      title="Members" toggle sortedBy direction value=SortGroupTable.MembersCount
                    />
                  </div>
                  <div>
                    <SortableTHead
                      title="Proposals"
                      toggle
                      sortedBy
                      direction
                      value=SortGroupTable.ProposalsCount
                    />
                  </div>
                  {isMobile
                    ? React.null
                    : <div>
                        <SortableTHead
                          title="Proposals On Voting"
                          toggle
                          sortedBy
                          direction
                          value=SortGroupTable.ProposalsOnVotingCount
                        />
                      </div>}
                </div>
              </div>
              <div
                className={Css.merge(list{"table_content--wrapper", Styles.tableContentWrapper})}>
                {switch groups->Belt.Array.length > 0 {
                | true =>
                  groups
                  ->SortGroupTable.sorting(~sortedBy, ~direction)
                  ->Belt.Array.mapWithIndex((index, group) => {
                    <GroupTableItem group key={index->Belt.Int.toString} />
                  })
                  ->React.array
                | false =>
                  <div className=Styles.noDataContainer>
                    <Text value="No group created" color={theme.neutral_600} size={Body1} />
                  </div>
                }}
              </div>
            </Table>
          </InfoContainer>
          <div className={Css.merge(list{"table_content--footer"})}>
            <Pagination2
              currentPage=page
              pageCount
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />
          </div>
        </>
      | Loading =>
        <InfoContainer style=Styles.infoContainer>
          <div className=Styles.noDataContainer>
            <LoadingCensorBar.CircleSpin height=80 />
          </div>
        </InfoContainer>
      | NoData =>
        <InfoContainer style=Styles.infoContainer>
          <div className=Styles.noDataContainer>
            <Text value="No group created" color={theme.neutral_600} size={Body1} />
          </div>
        </InfoContainer>

      | Error(_) =>
        <InfoContainer style=Styles.infoContainer>
          <div className=Styles.noDataContainer>
            <Text value="an Error Occured" color={theme.neutral_600} size={Body1} />
          </div>
        </InfoContainer>
      }}
    </div>
  }
}

module AllGroupTabContent = {
  @react.component
  let make = (~sortedBy, ~toggle, ~direction) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let (page, setPage) = React.useState(_ => 1)
    let pageSize = 10

    let groupSub = GroupSub.getList(~page, ~pageSize, ())

    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="All Groups" />
      {switch groupSub {
      | Data(groups) =>
        let pageCount = Page.getPageCount(groups->Belt.Array.length, pageSize)
        <>
          <InfoContainer style=Styles.infoContainer>
            <Table>
              <div className={Css.merge(list{"table-wrapper", Styles.tableHeadWrapper(theme)})}>
                <div className={Css.merge(list{Styles.tablehead})}>
                  <div>
                    <SortableTHead
                      title="Group ID" direction toggle value=SortGroupTable.ID sortedBy
                    />
                  </div>
                  {isMobile
                    ? React.null
                    : <div>
                        <SortableTHead
                          title="Group Name" direction toggle sortedBy value=SortGroupTable.Name
                        />
                      </div>}
                  <div>
                    <SortableTHead
                      title="Members" toggle sortedBy direction value=SortGroupTable.MembersCount
                    />
                  </div>
                  <div>
                    <SortableTHead
                      title="Proposals"
                      toggle
                      sortedBy
                      direction
                      value=SortGroupTable.ProposalsCount
                    />
                  </div>
                  {isMobile
                    ? React.null
                    : <div>
                        <SortableTHead
                          title="Proposals On Voting"
                          toggle
                          sortedBy
                          direction
                          value=SortGroupTable.ProposalsOnVotingCount
                        />
                      </div>}
                </div>
              </div>
              <div
                className={Css.merge(list{"table_content--wrapper", Styles.tableContentWrapper})}>
                {groups
                ->SortGroupTable.sorting(~sortedBy, ~direction)
                ->Belt.Array.mapWithIndex((index, group) => {
                  <GroupTableItem group key={index->Belt.Int.toString} />
                })
                ->React.array}
              </div>
            </Table>
          </InfoContainer>
          <div className={Css.merge(list{"table_content--footer"})}>
            <Pagination2
              currentPage=page
              pageCount
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />
          </div>
        </>
      | Loading =>
        <InfoContainer style=Styles.infoContainer>
          <div className=Styles.noDataContainer>
            <LoadingCensorBar.CircleSpin height=80 />
          </div>
        </InfoContainer>
      | NoData =>
        <InfoContainer style=Styles.infoContainer>
          <div className=Styles.noDataContainer>
            <Text value="No group created" color={theme.neutral_600} size={Body1} />
          </div>
        </InfoContainer>

      | Error(_) =>
        <InfoContainer style=Styles.infoContainer>
          <div className=Styles.noDataContainer>
            <Text value="an Error Occured" color={theme.neutral_600} size={Body1} />
          </div>
        </InfoContainer>
      }}
    </div>
  }
}

@react.component
let make = () => {
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (accountOpt, _) = React.useContext(AccountContext.context)

  let (sortedBy, setSortedBy) = React.useState(_ => SortGroupTable.ID)
  let (direction, setDirection) = React.useState(_ => SortGroupTable.DESC)

  let toggle = (direction, sortValue) => {
    setSortedBy(_ => sortValue)
    setDirection(_ => {
      switch direction {
      | SortGroupTable.ASC => SortGroupTable.DESC
      | SortGroupTable.DESC => SortGroupTable.ASC
      }
    })
  }

  <>
    {isMobile
      ? <div
          className={Css.merge(list{
            CssHelper.flexBox(~align=#center, ~justify=#flexStart, ()),
            CssHelper.mt(~size=24, ()),
          })}>
          <Text value="Sort By" size={Xl} />
          <HSpacing size={Spacing.sm} />
          <SortGroupTableDropdown sortedBy setSortedBy direction setDirection />
        </div>
      : React.null}
    {switch accountOpt {
    | Some(account) => <MyGroupTabContent sortedBy toggle direction account />
    | None => <NoAccountContent />
    }}
    <AllGroupTabContent sortedBy toggle direction />
  </>
}
