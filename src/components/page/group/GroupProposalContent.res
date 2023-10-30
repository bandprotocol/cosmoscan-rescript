module Styles = {
  open CssJs

  let tabContentWrapper = style(. [marginTop(#px(20)), marginBottom(#px(40))])
  let tableHeadWrapper = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_200),
      paddingBottom(#px(16)),
      Media.mobile([padding2(~v=#zero, ~h=#zero), borderBottom(#px(1), #solid, theme.neutral_000)]),
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
    selector("> div:first-child", [minWidth(#percent(10.)), textAlign(#center)]),
    selector("> div:nth-child(2)", [width(#percent(40.))]),
    selector("> div:nth-child(3)", [width(#percent(10.))]),
    selector("> div:nth-child(4)", [width(#percent(15.))]),
    selector("> div:nth-child(5)", [width(#percent(10.))]),
  ])

  let outer = style(. [padding2(~v=#zero, ~h=#px(32))])

  let tableContentWrapper = style(. [
    Media.mobile([marginTop(#px(16))]),
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
      {if direction == SortGroupProposalTable.ASC {
        <Icon
          name="fas fa-caret-down" color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
        />
      } else if direction == SortGroupProposalTable.DESC {
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

module MyGroupProposalTabContent = {
  @react.component
  let make = (~address: Address.t, ~sortedBy, ~toggle, ~direction) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let pageSize = 10
    let (page, setPage) = React.useState(_ => 1)

    let proposalsSub = GroupSub.getProposalsByAccount(
      ~address=address->Address.toBech32,
      ~page,
      ~pageSize,
      (),
    )

    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="My Proposals" />
      {switch proposalsSub {
      | Data(proposals) =>
        let pageCount = Page.getPageCount(proposals->Belt.Array.length, pageSize)

        <>
          {isMobile
            ? <>
                <div
                  className={Css.merge(list{"table_content--wrapper", Styles.tableContentWrapper})}>
                  {proposals
                  ->SortGroupProposalTable.sorting(~sortedBy, ~direction)
                  ->Belt.Array.mapWithIndex((ind, proposal) => {
                    <GroupProposalTableItem key={ind->Belt.Int.toString} proposal />
                  })
                  ->React.array}
                </div>
                <div className={Css.merge(list{"table_content--footer"})}>
                  <Pagination2
                    currentPage=page
                    pageCount
                    onPageChange={newPage => setPage(_ => newPage)}
                    onChangeCurrentPage={newPage => setPage(_ => newPage)}
                  />
                </div>
              </>
            : <>
                <InfoContainer style=Styles.infoContainer>
                  <Table>
                    <div
                      className={Css.merge(list{"table-wrapper", Styles.tableHeadWrapper(theme)})}>
                      {isMobile
                        ? React.null
                        : <div className={Css.merge(list{Styles.tablehead})}>
                            <div>
                              <SortableTHead
                                title="Proposal ID"
                                direction
                                toggle
                                value=SortGroupProposalTable.ID
                                sortedBy
                              />
                            </div>
                            <div>
                              <SortableTHead
                                title="Proposal Name"
                                direction
                                toggle
                                sortedBy
                                value=SortGroupProposalTable.Name
                              />
                            </div>
                            <div>
                              <Text
                                block=true
                                value="Message"
                                size=Text.Caption
                                weight=Text.Semibold
                                transform=Text.Uppercase
                                color=theme.neutral_900
                              />
                            </div>
                            <div>
                              <SortableTHead
                                title="Group"
                                toggle
                                sortedBy
                                direction
                                value=SortGroupProposalTable.GroupID
                              />
                            </div>
                            <div>
                              <SortableTHead
                                title="Status"
                                toggle
                                sortedBy
                                direction
                                value=SortGroupProposalTable.ProposalStatus
                              />
                            </div>
                          </div>}
                    </div>
                    <div
                      className={Css.merge(list{
                        "table_content--wrapper",
                        Styles.tableContentWrapper,
                      })}>
                      {switch proposals->Belt.Array.length > 0 {
                      | true =>
                        proposals
                        ->SortGroupProposalTable.sorting(~sortedBy, ~direction)
                        ->Belt.Array.mapWithIndex((ind, proposal) => {
                          <GroupProposalTableItem key={ind->Belt.Int.toString} proposal />
                        })
                        ->React.array
                      | false =>
                        <div className=Styles.noDataContainer>
                          <Text
                            value="No proposal created" color={theme.neutral_600} size={Body1}
                          />
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
              </>}
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

module AllGroupProposalTabContent = {
  @react.component
  let make = (~sortedBy, ~toggle, ~direction) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let pageSize = 10
    let (page, setPage) = React.useState(_ => 1)

    let proposalsSub = GroupSub.getProposals(~page, ~pageSize, ())

    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="All Proposals" />
      {switch proposalsSub {
      | Data(proposals) =>
        let pageCount = Page.getPageCount(proposals->Belt.Array.length, pageSize)
        <>
          {isMobile
            ? <>
                <div
                  className={Css.merge(list{"table_content--wrapper", Styles.tableContentWrapper})}>
                  {proposals
                  ->SortGroupProposalTable.sorting(~sortedBy, ~direction)
                  ->Belt.Array.mapWithIndex((ind, proposal) => {
                    <GroupProposalTableItem key={ind->Belt.Int.toString} proposal />
                  })
                  ->React.array}
                </div>
                <div className={Css.merge(list{"table_content--footer"})}>
                  <Pagination2
                    currentPage=page
                    pageCount
                    onPageChange={newPage => setPage(_ => newPage)}
                    onChangeCurrentPage={newPage => setPage(_ => newPage)}
                  />
                </div>
              </>
            : <>
                <InfoContainer style=Styles.infoContainer>
                  <Table>
                    <div
                      className={Css.merge(list{"table-wrapper", Styles.tableHeadWrapper(theme)})}>
                      {isMobile
                        ? React.null
                        : <div className={Css.merge(list{Styles.tablehead})}>
                            <div>
                              <SortableTHead
                                title="Proposal ID"
                                direction
                                toggle
                                value=SortGroupProposalTable.ID
                                sortedBy
                              />
                            </div>
                            <div>
                              <SortableTHead
                                title="Proposal Name"
                                direction
                                toggle
                                sortedBy
                                value=SortGroupProposalTable.Name
                              />
                            </div>
                            <div>
                              <Text
                                block=true
                                value="Message"
                                size=Text.Caption
                                weight=Text.Semibold
                                transform=Text.Uppercase
                                color=theme.neutral_900
                              />
                            </div>
                            <div>
                              <SortableTHead
                                title="Group"
                                toggle
                                sortedBy
                                direction
                                value=SortGroupProposalTable.GroupID
                              />
                            </div>
                            <div>
                              <SortableTHead
                                title="Status"
                                toggle
                                sortedBy
                                direction
                                value=SortGroupProposalTable.ProposalStatus
                              />
                            </div>
                          </div>}
                    </div>
                    <div
                      className={Css.merge(list{
                        "table_content--wrapper",
                        Styles.tableContentWrapper,
                      })}>
                      {proposals
                      ->SortGroupProposalTable.sorting(~sortedBy, ~direction)
                      ->Belt.Array.mapWithIndex((ind, proposal) => {
                        <GroupProposalTableItem key={ind->Belt.Int.toString} proposal />
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
              </>}
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

  let (sortedBy, setSortedBy) = React.useState(_ => SortGroupProposalTable.ID)
  let (direction, setDirection) = React.useState(_ => SortGroupProposalTable.DESC)

  let toggle = (direction, sortValue) => {
    setSortedBy(_ => sortValue)
    setDirection(_ => {
      switch direction {
      | SortGroupProposalTable.ASC => SortGroupProposalTable.DESC
      | SortGroupProposalTable.DESC => SortGroupProposalTable.ASC
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
          <SortGroupProposalTableDropdown sortedBy setSortedBy direction setDirection />
        </div>
      : React.null}
    {switch accountOpt {
    | Some(account) =>
      <MyGroupProposalTabContent address=account.address sortedBy toggle direction />
    | None => <NoAccountContent />
    }}
    <AllGroupProposalTabContent sortedBy toggle direction />
  </>
}
