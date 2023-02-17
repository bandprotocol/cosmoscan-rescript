module Styles = {
  open CssJs

  let searchbarWrapper = (theme: Theme.t) =>
    style(. [width(#percent(100.)), boxSizing(#borderBox), zIndex(1), position(#relative)])

  let searchbarInput = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      height(#px(40)),
      border(#px(1), #solid, theme.tableRowBorderColor),
      borderRadius(#px(8)),
      padding2(~v=#px(8), ~h=#px(10)),
      boxSizing(#borderBox),
      fontSize(#px(14)),
      color(theme.textPrimary),
      transition("all", ~duration=200, ~timingFunction=#easeInOut, ~delay=0),
      hover([border(#px(1), #solid, hex("9096A2"))]), //TODO: neutral_500
      focus([border(#px(1), #solid, theme.baseBlue)]),
      outlineStyle(#none),
      background(theme.secondaryBg),
      paddingRight(#px(40)),
      fontFamilies([#custom("Roboto Mono"), #monospace]),
      fontWeight(#num(300)),
      boxShadows([Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(16, 18, 20, #num(0.15)))]),
    ])

  let iconContainer = style(. [
    position(#absolute),
    right(#px(10)),
    top(#percent(50.)),
    transform(#translateY(#percent(-50.))),
  ])

  let resultContainer = (theme: Theme.t, ~isShow) =>
    style(. [
      display(isShow ? #block : #none),
      position(#absolute),
      top(#px(50)),
      left(#zero),
      width(#percent(100.)),
      background(theme.secondaryBg),
      borderRadius(#px(8)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(16, 18, 20, #num(0.15)))),
      padding3(~top=#px(0), ~bottom=#px(0), ~h=#zero),
      maxHeight(#vh(50.)),
      overflow(#scroll),
      zIndex(1),
    ])

  let resultInner = (theme: Theme.t) =>
    style(. [
      //   padding2(~v=#px(8), ~h=#px(20)),
      color(theme.textSecondary),
      fontFamilies([#custom("Roboto Mono"), #monospace]),
      fontWeight(#num(300)),
    ])

  let buttonStyled = style(. [
    backgroundColor(#transparent),
    border(#zero, #solid, #transparent),
    outlineStyle(#none),
    cursor(#pointer),
    padding2(~v=#zero, ~h=#zero),
    margin2(~v=#zero, ~h=#zero),
  ])

  let innerResultItem = style(. [
    selector(
      "> a",
      [
        display(#block),
        padding2(~v=#px(8), ~h=#px(16)),
        hover([backgroundColor(Css.rgba(16, 18, 20, #num(0.05)))]),
      ],
    ),
  ])
  let resultHeading = style(. [padding2(~v=#px(8), ~h=#px(16))])
  let resultItem = style(. [padding2(~v=#px(16), ~h=#zero)])

  let resultContent = style(. [
    selector(
      "ul > li",
      [
        borderBottom(#px(1), solid, hex("E5E7EB")),
        marginTop(#px(0)),
        selector(":last-child", [borderBottom(#zero, solid, hex("E5E7EB"))]),
      ],
    ),
  ])

  let resultNotFound = style(. [padding2(~v=#px(16), ~h=#px(16))])
}

type search_result_inner = {
  title: string,
  link: string,
}

type search_results_t = {items: array<search_result_inner>}

module RenderSearchResult = {
  @react.component
  let make = (~searchTerm) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let len = searchTerm->String.length
    let capStr = searchTerm->String.capitalize_ascii

    let searchResults = Belt.Array.make(0, {title: "", link: ""})

    let resultOracleScriptQuery: Query.variant<
      array<SearchBarQuery.OracleScriptSearch.t>,
    > = SearchBarQuery.searchOracleScript(~filter=searchTerm, ())

    let resultDataSourceQuery: Query.variant<
      array<SearchBarQuery.DataSourceSearch.t>,
    > = SearchBarQuery.searchDataSource(~filter=searchTerm, ())

    let resultBlockQuery: Query.variant<
      array<SearchBarQuery.BlockSearch.t>,
    > = SearchBarQuery.searchBlockID(~id=searchTerm, ())

    let resultRequestQuery: Query.variant<
      array<SearchBarQuery.RequestSearch.t>,
    > = SearchBarQuery.searchRequestID(~id=searchTerm, ())

    let resultProposalQuery: Query.variant<
      array<SearchBarQuery.ProposalSearch.t>,
    > = SearchBarQuery.searchProposal(~filter=searchTerm, ())

    let allQuery = Query.all5(
      resultBlockQuery,
      resultRequestQuery,
      resultOracleScriptQuery,
      resultDataSourceQuery,
      resultProposalQuery,
    )

    <>
      <nav role="navigation" className={Styles.resultContent}>
        {if searchTerm->Js.String2.startsWith("bandvaloper") && len == 50 {
          <ul role="tablist" className={Styles.resultItem}>
            <li role="presentation">
              <div className={Styles.resultHeading}>
                <Heading
                  size=Heading.H4
                  value="Address"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.textPrimary}
                />
              </div>
              <div className={Styles.resultInner(theme)}>
                <div className={Styles.innerResultItem}>
                  <AddressRender
                    address={searchTerm->Address.fromBech32}
                    position=AddressRender.Text
                    accountType=#validator
                  />
                </div>
              </div>
            </li>
          </ul>
        } else if searchTerm->Js.String2.startsWith("band") && len == 43 {
          <ul role="tablist" className={Styles.resultItem}>
            <li role="presentation">
              <div className={Styles.resultHeading}>
                <Heading
                  size=Heading.H4
                  value="Address"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.textPrimary}
                />
              </div>
              <div className={Styles.resultInner(theme)}>
                <div className={Styles.innerResultItem}>
                  <AddressRender
                    address={searchTerm->Address.fromBech32} position=AddressRender.Subtitle
                  />
                </div>
              </div>
            </li>
          </ul>
        } else if len == 64 || (searchTerm->Js.String2.startsWith("0x") && len == 66) {
          <ul role="tablist" className={Styles.resultItem}>
            <li>
              <div className={Styles.resultHeading}>
                <Heading
                  size=Heading.H4
                  value="Transactions"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.textPrimary}
                />
              </div>
              <div className={Styles.resultInner(theme)}>
                <div className={Styles.innerResultItem}>
                  <TxLink txHash={searchTerm->Hash.fromHex} width=500 size=Text.Lg />
                </div>
              </div>
            </li>
          </ul>
        } else {
          <div>
            // TODO: refactor with NoData
            {switch allQuery {
            | Data(blockResults, requestResults, osResults, dsResults, proposalResults) =>
              switch blockResults->Belt.Array.length +
              requestResults->Belt.Array.length +
              osResults->Belt.Array.length +
              dsResults->Belt.Array.length +
              proposalResults->Belt.Array.length > 0 {
              | true =>
                <ul role="tablist">
                  <li role="presentation">
                    {switch blockResults->Belt.Array.length > 0 {
                    | true =>
                      <div className={Styles.resultItem}>
                        <div className={Styles.resultHeading}>
                          <Heading
                            size=Heading.H4
                            value="Blocks"
                            align=Heading.Left
                            weight=Heading.Semibold
                            color={theme.textPrimary}
                          />
                        </div>
                        <div className={Styles.resultInner(theme)}>
                          {blockResults
                          ->Belt.Array.mapWithIndex((i, result) => {
                            <div className={Styles.innerResultItem} key={i->Belt.Int.toString}>
                              <TypeID.Block id=result.height position=TypeID.Subtitle block=true />
                            </div>
                          })
                          ->React.array}
                        </div>
                      </div>

                    | false => React.null
                    }}
                  </li>
                  <li role="presentation">
                    {switch requestResults->Belt.Array.length > 0 {
                    | true =>
                      <div className={Styles.resultItem}>
                        <div className={Styles.resultHeading}>
                          <Heading
                            size=Heading.H4
                            value="Requests"
                            align=Heading.Left
                            weight=Heading.Semibold
                            color={theme.textPrimary}
                          />
                        </div>
                        <div className={Styles.resultInner(theme)}>
                          {requestResults
                          ->Belt.Array.mapWithIndex((i, result) => {
                            <div className={Styles.innerResultItem} key={i->Belt.Int.toString}>
                              <TypeID.Request id=result.id position=TypeID.Subtitle block=true />
                            </div>
                          })
                          ->React.array}
                        </div>
                      </div>

                    | false => React.null
                    }}
                  </li>
                  <li role="presentation">
                    {switch osResults->Belt.Array.length > 0 {
                    | true =>
                      <div className={Styles.resultItem}>
                        <div className={Styles.resultHeading}>
                          <Heading
                            size=Heading.H4
                            value="Oracle Scripts"
                            align=Heading.Left
                            weight=Heading.Semibold
                            color={theme.textPrimary}
                          />
                        </div>
                        <div className={Styles.resultInner(theme)}>
                          {osResults
                          ->Belt.Array.mapWithIndex((i, result) => {
                            <div className={Styles.innerResultItem} key={i->Belt.Int.toString}>
                              <TypeID.OracleScriptLink id={result.id}>
                                <div className={Css.merge(list{CssHelper.flexBox()})}>
                                  <TypeID.OracleScript id={result.id} position=TypeID.Body />
                                  <HSpacing size=Spacing.sm />
                                  <Heading
                                    size=Heading.H4 value={result.name} weight=Heading.Thin
                                  />
                                </div>
                              </TypeID.OracleScriptLink>
                            </div>
                          })
                          ->React.array}
                        </div>
                      </div>

                    | false => React.null
                    }}
                  </li>
                  <li role="presentation">
                    {switch dsResults->Belt.Array.length > 0 {
                    | true =>
                      <div className={Styles.resultItem}>
                        <div className={Styles.resultHeading}>
                          <Heading
                            size=Heading.H4
                            value="Data Sources"
                            align=Heading.Left
                            weight=Heading.Semibold
                            color={theme.textPrimary}
                          />
                        </div>
                        <div className={Styles.resultInner(theme)}>
                          {dsResults
                          ->Belt.Array.mapWithIndex((i, result) => {
                            <div className={Styles.innerResultItem} key={i->Belt.Int.toString}>
                              <TypeID.DataSourceLink id={result.id}>
                                <div className={Css.merge(list{CssHelper.flexBox()})}>
                                  <TypeID.DataSource id={result.id} position=TypeID.Body />
                                  <HSpacing size=Spacing.sm />
                                  <Heading
                                    size=Heading.H4 value={result.name} weight=Heading.Thin
                                  />
                                </div>
                              </TypeID.DataSourceLink>
                            </div>
                          })
                          ->React.array}
                        </div>
                      </div>

                    | false => React.null
                    }}
                  </li>
                  <li role="presentation">
                    {switch proposalResults->Belt.Array.length > 0 {
                    | true =>
                      <div className={Styles.resultItem}>
                        <div className={Styles.resultHeading}>
                          <Heading
                            size=Heading.H4
                            value="Proposal"
                            align=Heading.Left
                            weight=Heading.Semibold
                            color={theme.textPrimary}
                          />
                        </div>
                        <div className={Styles.resultInner(theme)}>
                          {proposalResults
                          ->Belt.Array.mapWithIndex((i, result) => {
                            <div className={Styles.innerResultItem} key={i->Belt.Int.toString}>
                              <TypeID.ProposalLink id={result.id}>
                                <div className={Css.merge(list{CssHelper.flexBox()})}>
                                  <TypeID.Proposal id={result.id} position=TypeID.Body />
                                  <HSpacing size=Spacing.sm />
                                  <Heading
                                    size=Heading.H4 value={result.title} weight=Heading.Thin
                                  />
                                </div>
                              </TypeID.ProposalLink>
                            </div>
                          })
                          ->React.array}
                        </div>
                      </div>

                    | false => React.null
                    }}
                  </li>
                </ul>
              | false =>
                <div className={Styles.resultNotFound}>
                  <Text value={j`No search result for "$searchTerm"`} size=Text.Lg />
                </div>
              }

            | Loading =>
              <div className={Styles.resultNotFound}>
                <LoadingCensorBar width=100 height=20 />
              </div>
            | _ =>
              <div className={Styles.resultNotFound}>
                <Text value={j`No search result for "$searchTerm"`} size=Text.Lg />
              </div>
            }}
          </div>
        }}
      </nav>
    </>
  }
}

type resultState =
  | Hidden
  | ShowAndFocus(int)

type validArrowDirection =
  | Up
  | Down

type state = {
  searchTerm: string,
  resultState: resultState,
}

type action =
  | ChangeSearchTerm(string)
  | ArrowPressed(validArrowDirection)
  | StartTyping
  | StopTyping
  | HoverResultAt(int)

let reducer = (state, x) =>
  switch x {
  | ChangeSearchTerm(newTerm) => {...state, searchTerm: newTerm}
  | ArrowPressed(direction) =>
    switch state.resultState {
    | Hidden => state
    | ShowAndFocus(focusIndex) => {
        ...state,
        resultState: ShowAndFocus(
          switch direction {
          | Up => focusIndex - 1
          | Down => focusIndex + 1
          },
        ),
      }
    }
  | StartTyping => {...state, resultState: ShowAndFocus(0)}
  | StopTyping => {...state, resultState: Hidden}
  | HoverResultAt(resultIndex) => {...state, resultState: ShowAndFocus(resultIndex)}
  }

@react.component
let make = () => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let (isSearching, setIsSearching) = React.useState(_ => false)

  let ({searchTerm, resultState}, dispatch) = React.useReducer(
    reducer,
    {searchTerm: "", resultState: Hidden},
  )

  let clickOutside = ClickOutside.useClickOutside(_ => setIsSearching(_ => false))

  <div className={Styles.searchbarWrapper(theme)} ref={ReactDOM.Ref.domRef(clickOutside)}>
    <input
      onFocus={_evt => dispatch(StartTyping)}
      onBlur={_evt => dispatch(StopTyping)}
      onChange={evt => {
        let inputVal = ReactEvent.Form.target(evt)["value"]
        setIsSearching(_ => inputVal !== "")
        dispatch(ChangeSearchTerm(inputVal))
      }}
      onKeyDown={event =>
        switch ReactEvent.Keyboard.key(event) {
        | "ArrowUp" =>
          dispatch(ArrowPressed(Up))
          ReactEvent.Keyboard.preventDefault(event)
        | "ArrowDown" =>
          dispatch(ArrowPressed(Down))
          ReactEvent.Keyboard.preventDefault(event)
        | "Enter" =>
          dispatch(ChangeSearchTerm(""))
          setIsSearching(_ => false)
          ReactEvent.Keyboard.preventDefault(event)
          Route.redirect(searchTerm->Route.search)
        | _ => ()
        }}
      value=searchTerm
      className={Styles.searchbarInput(theme)}
      placeholder="Search Address / TXN Hash / Block / Validator / etc."
    />
    <div className=Styles.iconContainer>
      <button
        className=Styles.buttonStyled
        onClick={_ => {
          setIsSearching(_ => false)
          dispatch(ChangeSearchTerm(""))
          Route.redirect(searchTerm->Route.search)
        }}>
        <Icon name="far fa-search" color=theme.textPrimary size=16 />
      </button>
    </div>
    <div
      className={Styles.resultContainer(theme, ~isShow={isSearching})}
      onClick={_ => {
        setIsSearching(_ => false)
        dispatch(ChangeSearchTerm(""))
      }}>
      <RenderSearchResult searchTerm />
    </div>
  </div>
}
