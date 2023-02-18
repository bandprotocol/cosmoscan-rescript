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
  let resultHeading = style(. [
    padding2(~v=#px(16), ~h=#px(16)),
    borderTop(#px(1), solid, hex("E5E7EB")),
  ])
  let resultItem = style(. [padding2(~v=#px(0), ~h=#zero)])

  let resultContent = style(. [
    selector("ul > li", [marginTop(#px(0))]),
    selector("ul > li:first-child", [borderTop(#zero, solid, hex("E5E7EB"))]),
  ])

  let resultItemFocused = style(. [
    backgroundColor(Css.rgba(16, 18, 20, #num(0.05))),
    border(#px(1), #solid, Css.rgba(16, 18, 20, #num(0.05))),
  ])

  let resultNotFound = style(. [padding2(~v=#px(16), ~h=#px(16))])
}

type search_result_inner = {route: Route.t}

type search_results_t = {items: array<search_result_inner>}

module HighLightText = {
  module Styles = {
    open CssJs

    let highlightText = (theme: Theme.t) => style(. [color(theme.baseBlue), fontWeight(#num(600))])
    let normalText = (theme: Theme.t) =>
      style(. [
        fontSize(#px(14)),
        Media.smallMobile([fontSize(#px(12))]),
        fontWeight(#num(300)),
        color(theme.textPrimary),
        textAlign(#left),
      ])
  }

  @react.component
  let make = (~title, ~searchTerm) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let highLightText = {
      let index = title->Js.String.toLocaleLowerCase->Js.String2.indexOf(searchTerm)
      if index !== -1 {
        let before = title->Js.String2.slice(~from=0, ~to_=index)
        let after =
          title->Js.String2.slice(
            ~from=index + searchTerm->String.length,
            ~to_=title->String.length,
          )

        let highlight =
          {title->Js.String2.slice(~from=index, ~to_=index + searchTerm->String.length)}
        <>
          <span> {before->React.string} </span>
          <span className={Styles.highlightText(theme)}> {highlight->React.string} </span>
          <span> {after->React.string} </span>
        </>
      } else {
        <span> {title->React.string} </span>
      }
    }
    <h4 className={Css.merge(list{Styles.normalText(theme), Heading.Styles.fontSize(Heading.H4)})}>
      {highLightText}
    </h4>
  }
}

module RenderSearchResult = {
  @react.component
  let make = (
    ~searchTerm,
    ~results: Query.variant<(
      array<SearchBarQuery.BlockSearch.t>,
      array<SearchBarQuery.RequestSearch.t>,
      array<SearchBarQuery.OracleScriptSearch.t>,
      array<SearchBarQuery.DataSourceSearch.t>,
      array<SearchBarQuery.ProposalSearch.t>,
    )>,
    ~resultLength: int,
  ) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let len = searchTerm->String.length
    let capStr = searchTerm->String.capitalize_ascii

    <div className={Styles.resultInner(theme)}>
      {switch (results, resultLength) {
      | (Data(blocks, requests, os, ds, proposals), 0) =>
        <div className={Styles.resultNotFound}>
          <Text value={j`No search result for "$searchTerm"`} size=Text.Lg />
        </div>

      | (Data(blocks, requests, os, ds, proposals), _) =>
        <div className={Styles.resultContent}>
          <ul>
            {switch blocks->Belt.Array.length {
            | 0 => React.null
            | _ =>
              <>
                <li className={Styles.resultHeading}>
                  <Heading
                    size=Heading.H4
                    value="Blocks"
                    align=Heading.Left
                    weight=Heading.Semibold
                    color={theme.textPrimary}
                  />
                </li>
                {blocks
                ->Belt.Array.mapWithIndex((i, result) => {
                  <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                    <div className={Styles.innerResultItem}>
                      <TypeID.Block id=result.height position=TypeID.Subtitle block=true />
                    </div>
                  </li>
                })
                ->React.array}
              </>
            }}
            {switch requests->Belt.Array.length {
            | 0 => React.null
            | _ =>
              <>
                <li className={Styles.resultHeading}>
                  <Heading
                    size=Heading.H4
                    value="Requests"
                    align=Heading.Left
                    weight=Heading.Semibold
                    color={theme.textPrimary}
                  />
                </li>
                {requests
                ->Belt.Array.mapWithIndex((i, result) => {
                  <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                    <div className={Styles.innerResultItem}>
                      <TypeID.Request id=result.id position=TypeID.Subtitle block=true />
                    </div>
                  </li>
                })
                ->React.array}
              </>
            }}
            {switch os->Belt.Array.length {
            | 0 => React.null
            | _ =>
              <>
                <li className={Styles.resultHeading}>
                  <Heading
                    size=Heading.H4
                    value="Oracle Scripts"
                    align=Heading.Left
                    weight=Heading.Semibold
                    color={theme.textPrimary}
                  />
                </li>
                {os
                ->Belt.Array.mapWithIndex((i, result) => {
                  <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                    <div className={Styles.innerResultItem}>
                      <TypeID.OracleScriptLink id={result.id}>
                        <div className={Css.merge(list{CssHelper.flexBox()})}>
                          <TypeID.OracleScript id={result.id} position=TypeID.Body />
                          <HSpacing size=Spacing.sm />
                          <HighLightText title={result.name} searchTerm />
                        </div>
                      </TypeID.OracleScriptLink>
                    </div>
                  </li>
                })
                ->React.array}
              </>
            }}
            {switch ds->Belt.Array.length {
            | 0 => React.null
            | _ =>
              <>
                <li className={Styles.resultHeading}>
                  <Heading
                    size=Heading.H4
                    value="Data Sources"
                    align=Heading.Left
                    weight=Heading.Semibold
                    color={theme.textPrimary}
                  />
                </li>
                {ds
                ->Belt.Array.mapWithIndex((i, result) => {
                  <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                    <div className={Styles.innerResultItem}>
                      <TypeID.DataSourceLink id={result.id}>
                        <div className={Css.merge(list{CssHelper.flexBox()})}>
                          <TypeID.DataSource id={result.id} position=TypeID.Body />
                          <HSpacing size=Spacing.sm />
                          <HighLightText title={result.name} searchTerm />
                        </div>
                      </TypeID.DataSourceLink>
                    </div>
                  </li>
                })
                ->React.array}
              </>
            }}
            {switch proposals->Belt.Array.length {
            | 0 => React.null
            | _ =>
              <>
                <li className={Styles.resultHeading}>
                  <Heading
                    size=Heading.H4
                    value="Proposals"
                    align=Heading.Left
                    weight=Heading.Semibold
                    color={theme.textPrimary}
                  />
                </li>
                {proposals
                ->Belt.Array.mapWithIndex((i, result) => {
                  <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                    <div className={Styles.innerResultItem} key={i->Belt.Int.toString}>
                      <TypeID.ProposalLink id={result.id}>
                        <div className={Css.merge(list{CssHelper.flexBox()})}>
                          <TypeID.Proposal id={result.id} position=TypeID.Body />
                          <HSpacing size=Spacing.sm />
                          <HighLightText title={result.title} searchTerm />
                        </div>
                      </TypeID.ProposalLink>
                    </div>
                  </li>
                })
                ->React.array}
              </>
            }}
          </ul>
        </div>

      | (Loading, _) =>
        <div className={Styles.resultNotFound}>
          <LoadingCensorBar width=100 height=20 />
        </div>
      | _ => React.null
      }}
    </div>
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
  let (selectedRoute, setSelectedRoute) = React.useState(_ => Route.NotFound)

  let clickOutside = ClickOutside.useClickOutside(_ => setIsSearching(_ => false))

  let (focusIndex, setFocusIndex) = React.useState(_ => 0)

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

  let resultLen = Query.sumResults5(allQuery)

  let mergedResult = {
    switch allQuery {
    | Data(blocks, requests, os, ds, proposals) => {
        let blockResults = blocks->Belt.Array.map(block => {
          let route = Route.BlockDetailsPage(block.height->ID.Block.toInt)
          {route}
        })
        let requestResults = requests->Belt.Array.map(request => {
          let route = Route.RequestIndexPage(request.id->ID.Request.toInt)
          {route}
        })
        let osResults = os->Belt.Array.map(os => {
          let route = Route.OracleScriptDetailsPage(
            os.id->ID.OracleScript.toInt,
            Route.OracleScriptCode,
          )
          {route}
        })
        let dsResults = ds->Belt.Array.map(ds => {
          let route = Route.DataSourceDetailsPage(ds.id->ID.DataSource.toInt, Route.DataSourceCode)
          {route}
        })
        let proposalResults = proposals->Belt.Array.map(proposal => {
          let route = Route.ProposalDetailsPage(proposal.id->ID.Proposal.toInt)
          {route}
        })
        let allResults = [blockResults, requestResults, osResults, dsResults, proposalResults]

        let mergeResults = allResults->Belt.Array.reduce([], (acc, x) => {
          x->Belt.Array.concat(acc)
        })
        mergeResults
      }

    | _ => []
    }
  }

  let handleKeyDown = (event, ()) => {
    let nextIndexCount = 0
    switch ReactEvent.Keyboard.key(event) {
    // | "ArrowUp" =>
    //   dispatch(ArrowPressed(Up))
    //   ReactEvent.Keyboard.preventDefault(event)
    // | "ArrowDown" =>
    //   dispatch(ArrowPressed(Down))
    //   ReactEvent.Keyboard.preventDefault(event)
    | "Enter" =>
      dispatch(ChangeSearchTerm(""))
      setIsSearching(_ => false)
      ReactEvent.Keyboard.preventDefault(event)
      switch resultLen > 0 {
      | true =>
        let item = {
          switch mergedResult->Belt.Array.get(0) {
          | Some(item) => item
          | None => Route.NotFound
          }
        }
        setSelectedRoute(_ => item)
        Route.redirect(item)

      | _ => Route.redirect(Route.search(searchTerm))
      }
    | _ => ()
    }
  }

  <div className={Styles.searchbarWrapper(theme)} ref={ReactDOM.Ref.domRef(clickOutside)}>
    <input
      tabIndex=1
      onFocus={_evt => dispatch(StartTyping)}
      onBlur={_evt => dispatch(StopTyping)}
      onChange={evt => {
        let inputVal = ReactEvent.Form.target(evt)["value"]
        setIsSearching(_ => inputVal !== "")
        dispatch(ChangeSearchTerm(inputVal))
      }}
      onKeyDown={event => handleKeyDown(event, ())}
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
      <RenderSearchResult searchTerm results=allQuery resultLength={Array.length(mergedResult)} />
    </div>
  </div>
}
