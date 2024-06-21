module Styles = {
  open CssJs

  let searchbarWrapper = (theme: Theme.t) =>
    style(. [width(#percent(100.)), boxSizing(#borderBox), zIndex(1), position(#relative)])

  let searchbarInput = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      height(#px(40)),
      border(#px(1), #solid, theme.neutral_200),
      borderRadius(#px(8)),
      padding2(~v=#px(8), ~h=#px(10)),
      boxSizing(#borderBox),
      fontSize(#px(14)),
      color(theme.neutral_900),
      transition("all", ~duration=200, ~timingFunction=#easeInOut, ~delay=0),
      hover([border(#px(1), #solid, theme.neutral_500)]),
      focus([border(#px(1), #solid, theme.primary_600)]),
      outlineStyle(#none),
      background(theme.neutral_000),
      paddingRight(#px(40)),
      fontWeight(#num(300)),
      // boxShadows([Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(16, 18, 20, #num(0.15)))]),
    ])

  let iconContainer = style(. [
    position(#absolute),
    right(#px(16)),
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
      background(theme.neutral_000),
      borderRadius(#px(8)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(16, 18, 20, #num(0.15)))),
      padding3(~top=#px(0), ~bottom=#px(0), ~h=#zero),
      maxHeight(#vh(50.)),
      overflow(#scroll),
      zIndex(1),
    ])

  let resultInner = (theme: Theme.t) =>
    style(. [
      paddingBottom(#px(8)),
      color(theme.neutral_600),
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
  let resultHeading = (theme: Theme.t) =>
    style(. [padding2(~v=#px(16), ~h=#px(16)), borderTop(#px(1), solid, theme.neutral_200)])
  let resultItem = style(. [padding2(~v=#px(0), ~h=#zero)])

  let resultContent = (theme: Theme.t) =>
    style(. [
      selector("> li", [marginTop(#px(0))]),
      selector("> li:first-child", [borderTop(#zero, solid, theme.neutral_200)]),
    ])

  let resultItemFocused = style(. [
    backgroundColor(Css.rgba(16, 18, 20, #num(0.05))),
    border(#px(1), #solid, Css.rgba(16, 18, 20, #num(0.05))),
  ])

  let resultNotFound = style(. [padding2(~v=#px(16), ~h=#px(16))])
}

type search_result_inner = {route: Route.t}

type search_results_t = {items: array<search_result_inner>}

module RenderMonikerLink = {
  module Styles = {
    open CssJs

    let container = (w, theme: Theme.t) =>
      style(. [
        display(#flex),
        cursor(pointer),
        width(w),
        alignItems(#center),
        selector("> span:hover", [color(theme.primary_600)]),
        selector("> span", [transition(~duration=200, "all")]),
      ])
  }

  @react.component
  let make = (~validatorAddress: Address.t, ()) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let validator = SearchBarQuery.getValidatorMoniker(~address=validatorAddress, ())

    <Link
      className={Styles.container(#percent(100.), theme)}
      route={Route.ValidatorDetailsPage(validatorAddress, Reports)}>
      {switch validator {
      | Data(validator') =>
        switch validator' {
        | Some({moniker, identity}) =>
          <div className={CssHelper.flexBox(~align=#center, ())}>
            <Avatar moniker identity width=20 />
            <HSpacing size=Spacing.sm />
            <Text
              value=moniker
              color={theme.neutral_900}
              weight=Text.Regular
              block=true
              size=Text.Body2
              nowrap=true
              ellipsis=true
              underline=false
            />
          </div>
        | _ => React.null
        }
      | _ => React.null
      }}
    </Link>
  }
}

module HighLightText = {
  module Styles = {
    open CssJs

    let highlightText = (theme: Theme.t) =>
      style(. [color(theme.primary_600), fontWeight(#num(600))])
    let normalText = (theme: Theme.t) =>
      style(. [
        fontSize(#px(14)),
        Media.smallMobile([fontSize(#px(12))]),
        fontWeight(#num(300)),
        color(theme.neutral_900),
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

module RenderNotFound = {
  @react.component
  let make = (~searchTerm) => {
    <li className={Styles.resultItem}>
      <div className={Styles.resultNotFound}>
        <Text value={j`No search result for "$searchTerm"`} size=Text.Body2 />
      </div>
    </li>
  }
}

module RenderDataSourceWithNameLink = {
  @react.component
  let make = (~id) => {
    let dataSource = SearchBarQuery.getDataSourceName(~id, ())
    switch dataSource {
    | Data(dataInner) =>
      switch dataInner {
      | Data({id, name}) =>
        <TypeID.DataSourceLink id={id}>
          <div className={Css.merge(list{CssHelper.flexBox()})}>
            <TypeID.DataSource id={id} position=TypeID.Subtitle isNotLink=true />
            <HSpacing size=Spacing.sm />
            <Heading size=Heading.H4 value=name weight=Heading.Thin />
          </div>
        </TypeID.DataSourceLink>
      | _ => React.null
      }
    | NoData => <RenderNotFound searchTerm={id} />
    | _ => <LoadingCensorBar width=100 height=20 />
    }
  }
}

module RenderOracleScriptWithNameLink = {
  @react.component
  let make = (~id) => {
    let osName = SearchBarQuery.getOracleScriptName(~id, ())
    switch osName {
    | Data(data) =>
      switch data {
      | Data({id, name}) =>
        <TypeID.OracleScriptLink id={id}>
          <div className={Css.merge(list{CssHelper.flexBox()})}>
            <TypeID.OracleScript id={id} position=TypeID.Subtitle isNotLink=true />
            <HSpacing size=Spacing.sm />
            <Heading size=Heading.H4 value=name weight=Heading.Thin />
          </div>
        </TypeID.OracleScriptLink>
      | _ => <RenderNotFound searchTerm={id} />
      }

    | _ => <LoadingCensorBar width=100 height=20 />
    }
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
      array<SearchBarQuery.ValidatorSearch.t>,
    )>,
    ~resultLength: int,
  ) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let trimSearchTerm = searchTerm->Js.String.trim
    let len = trimSearchTerm->String.length

    <div className={Styles.resultInner(theme)}>
      <ul className={Styles.resultContent((theme: Theme.t))}>
        {
          let route = Route.search(trimSearchTerm)
          open Route
          switch route {
          | BlockDetailsPage(id) =>
            <>
              <li className={Styles.resultHeading(theme)}>
                <Heading
                  size=Heading.H4
                  value="Block"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
              </li>
              <li className={Styles.resultItem}>
                <div className={Styles.innerResultItem}>
                  <TypeID.Block id={id->ID.Block.fromInt} position=TypeID.Subtitle block=true />
                </div>
              </li>
            </>
          | RequestDetailsPage(id) =>
            <>
              <li className={Styles.resultHeading(theme)}>
                <Heading
                  size=Heading.H4
                  value="Requests"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
              </li>
              <li className={Styles.resultItem}>
                <div className={Styles.innerResultItem}>
                  <TypeID.Request id={id->ID.Request.fromInt} position=TypeID.Subtitle block=true />
                </div>
              </li>
            </>

          | DataSourceDetailsPage(id, _) =>
            <>
              <li className={Styles.resultHeading(theme)}>
                <Heading
                  size=Heading.H4
                  value="Data Sources"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
              </li>
              <li className={Styles.resultItem}>
                <div className={Styles.innerResultItem}>
                  <RenderDataSourceWithNameLink id={id} />
                </div>
              </li>
            </>

          | OracleScriptDetailsPage(id, _) =>
            <>
              <li className={Styles.resultHeading(theme)}>
                <Heading
                  size=Heading.H4
                  value="Oracle Scripts"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
              </li>
              <li className={Styles.resultItem}>
                <div className={Styles.innerResultItem}>
                  <RenderOracleScriptWithNameLink id={id} />
                </div>
              </li>
            </>

          | ValidatorDetailsPage(_, _) =>
            switch trimSearchTerm->Address.fromBech32Opt {
            | Some(address) =>
              <>
                <li className={Styles.resultHeading(theme)}>
                  <Heading
                    size=Heading.H4
                    value="Address"
                    align=Heading.Left
                    weight=Heading.Semibold
                    color={theme.neutral_600}
                  />
                </li>
                <li className={Styles.resultItem}>
                  <div className={Styles.innerResultItem}>
                    <RenderMonikerLink validatorAddress={address} />
                  </div>
                </li>
              </>
            | None => <RenderNotFound searchTerm=trimSearchTerm />
            }
          | AccountIndexPage(_, _) =>
            switch trimSearchTerm->Address.fromBech32Opt {
            | Some(address) =>
              <>
                <li className={Styles.resultHeading(theme)}>
                  <Heading
                    size=Heading.H4
                    value="Address"
                    align=Heading.Left
                    weight=Heading.Semibold
                    color={theme.neutral_600}
                  />
                </li>
                <li className={Styles.resultItem}>
                  <div className={Styles.innerResultItem}>
                    <AddressRender address={address} position=AddressRender.Subtitle />
                  </div>
                </li>
              </>
            | None => <RenderNotFound searchTerm=trimSearchTerm />
            }
          | TxIndexPage(_) =>
            <>
              <li className={Styles.resultHeading(theme)}>
                <Heading
                  size=Heading.H4
                  value="Transaction"
                  align=Heading.Left
                  weight=Heading.Semibold
                  color={theme.neutral_600}
                />
              </li>
              <li className={Styles.resultItem}>
                <div className={Styles.innerResultItem}>
                  <TxLink txHash={trimSearchTerm->Hash.fromHex} width=800 size=Text.Body2 />
                </div>
              </li>
            </>
          | _ =>
            switch (results, resultLength) {
            | (Data(_), 0) => <RenderNotFound searchTerm=trimSearchTerm />

            | (Data(blocks, requests, os, ds, proposals, validators), _) =>
              <>
                {switch blocks->Belt.Array.length {
                | 0 => React.null
                | _ =>
                  <>
                    <li className={Styles.resultHeading(theme)}>
                      <Heading
                        size=Heading.H4
                        value="Blocks"
                        align=Heading.Left
                        weight=Heading.Semibold
                        color={theme.neutral_600}
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
                    <li className={Styles.resultHeading(theme)}>
                      <Heading
                        size=Heading.H4
                        value="Requests"
                        align=Heading.Left
                        weight=Heading.Semibold
                        color={theme.neutral_600}
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
                    <li className={Styles.resultHeading(theme)}>
                      <Heading
                        size=Heading.H4
                        value="Oracle Scripts"
                        align=Heading.Left
                        weight=Heading.Semibold
                        color={theme.neutral_600}
                      />
                    </li>
                    {os
                    ->Belt.Array.mapWithIndex((i, result) => {
                      <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                        <div className={Styles.innerResultItem}>
                          <TypeID.OracleScriptLink id={result.id}>
                            <div className={Css.merge(list{CssHelper.flexBox()})}>
                              <TypeID.OracleScript
                                id={result.id} position=TypeID.Subtitle isNotLink=true
                              />
                              <HSpacing size=Spacing.sm />
                              <HighLightText title={result.name} searchTerm=trimSearchTerm />
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
                    <li className={Styles.resultHeading(theme)}>
                      <Heading
                        size=Heading.H4
                        value="Data Sources"
                        align=Heading.Left
                        weight=Heading.Semibold
                        color={theme.neutral_600}
                      />
                    </li>
                    {ds
                    ->Belt.Array.mapWithIndex((i, result) => {
                      <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                        <div className={Styles.innerResultItem}>
                          <TypeID.DataSourceLink id={result.id}>
                            <div className={Css.merge(list{CssHelper.flexBox()})}>
                              <TypeID.DataSource
                                id={result.id} position=TypeID.Subtitle isNotLink=true
                              />
                              <HSpacing size=Spacing.sm />
                              <HighLightText title={result.name} searchTerm=trimSearchTerm />
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
                    <li className={Styles.resultHeading(theme)}>
                      <Heading
                        size=Heading.H4
                        value="Proposals"
                        align=Heading.Left
                        weight=Heading.Semibold
                        color={theme.neutral_600}
                      />
                    </li>
                    {proposals
                    ->Belt.Array.mapWithIndex((i, result) => {
                      <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                        <div className={Styles.innerResultItem} key={i->Belt.Int.toString}>
                          <TypeID.ProposalLink id={result.id}>
                            <div className={Css.merge(list{CssHelper.flexBox()})}>
                              <TypeID.Proposal
                                id={result.id} position=TypeID.Subtitle isNotLink=true
                              />
                              <HSpacing size=Spacing.sm />
                              <HighLightText title={result.title} searchTerm=trimSearchTerm />
                            </div>
                          </TypeID.ProposalLink>
                        </div>
                      </li>
                    })
                    ->React.array}
                  </>
                }}
                {switch validators->Belt.Array.length {
                | 0 => React.null
                | _ =>
                  <>
                    <li className={Styles.resultHeading(theme)}>
                      <Heading
                        size=Heading.H4
                        value="Validators"
                        align=Heading.Left
                        weight=Heading.Semibold
                        color={theme.neutral_600}
                      />
                    </li>
                    {validators
                    ->Belt.Array.mapWithIndex((i, validator) => {
                      <li className={Styles.resultItem} key={i->Belt.Int.toString}>
                        <div className={Styles.innerResultItem}>
                          <RenderMonikerLink validatorAddress={validator.operatorAddress} />
                        </div>
                      </li>
                    })
                    ->React.array}
                  </>
                }}
              </>

            | (Loading, _) =>
              <div className={Styles.resultNotFound}>
                <LoadingCensorBar width=100 height=20 />
              </div>
            | _ => <RenderNotFound searchTerm=trimSearchTerm />
            }
          }
        }
      </ul>
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
  > = SearchBarQuery.searchOracleScript(~filter=searchTerm->Js.String.trim, ())

  let resultDataSourceQuery: Query.variant<
    array<SearchBarQuery.DataSourceSearch.t>,
  > = SearchBarQuery.searchDataSource(~filter=searchTerm->Js.String.trim, ())

  let resultBlockQuery: Query.variant<
    array<SearchBarQuery.BlockSearch.t>,
  > = SearchBarQuery.searchBlockID(~id=searchTerm->Js.String.trim, ())

  let resultRequestQuery: Query.variant<
    array<SearchBarQuery.RequestSearch.t>,
  > = SearchBarQuery.searchRequestID(~id=searchTerm->Js.String.trim, ())

  let resultProposalQuery: Query.variant<
    array<SearchBarQuery.ProposalSearch.t>,
  > = SearchBarQuery.searchProposal(~filter=searchTerm->Js.String.trim, ())

  let resultValidatorQuery: Query.variant<
    array<SearchBarQuery.ValidatorSearch.t>,
  > = SearchBarQuery.searchValidatorByMoniker(~filter=searchTerm->Js.String.trim, ())

  let allQuery = Query.all6(
    resultBlockQuery,
    resultRequestQuery,
    resultOracleScriptQuery,
    resultDataSourceQuery,
    resultProposalQuery,
    resultValidatorQuery,
  )

  let resultLen = Query.sumResults6(allQuery)

  let mergedResult = {
    switch allQuery {
    | Data(blocks, requests, os, ds, proposals, validators) => {
        let blockResults = blocks->Belt.Array.map(block => {
          let route = Route.BlockDetailsPage(block.height->ID.Block.toInt)
          {route}
        })
        let requestResults = requests->Belt.Array.map(request => {
          let route = Route.RequestDetailsPage(request.id->ID.Request.toInt)
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
        let validatorResults = validators->Belt.Array.map(validator => {
          let route = Route.ValidatorDetailsPage(validator.operatorAddress, Route.Reports)
          {route}
        })

        let allResults = [
          blockResults,
          requestResults,
          osResults,
          dsResults,
          proposalResults,
          validatorResults,
        ]

        let mergeResults = allResults->Belt.Array.reduce([], (acc, x) => {
          acc->Belt.Array.concat(x)
        })
        mergeResults
      }

    | _ => []
    }
  }

  let handleKeyDown = (event, ()) => {
    let nextIndexCount = 0
    switch ReactEvent.Keyboard.key(event) {
    | "Enter" =>
      dispatch(ChangeSearchTerm(""))
      setIsSearching(_ => false)
      ReactEvent.Keyboard.preventDefault(event)

      let route = Route.search(searchTerm->Js.String.trim)
      switch route {
      | Route.NotFound => {
          let item = {
            switch mergedResult->Belt.Array.get(0) {
            | Some(item) => item
            | None => Route.NotFound
            }
          }
          setSelectedRoute(_ => item)
          Route.redirect(item)
        }

      | _ => Route.redirect(route)
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
      value={searchTerm}
      className={Styles.searchbarInput(theme)}
      placeholder="Search Address / TXN Hash / Block / Validator / etc."
    />
    <div className=Styles.iconContainer>
      <button
        className=Styles.buttonStyled
        onClick={_ => {
          setIsSearching(_ => false)
          dispatch(ChangeSearchTerm(""))
          Route.redirect(searchTerm->Js.String.trim->Route.search)
        }}>
        <Icon name="far fa-search" color=theme.neutral_900 size=16 />
      </button>
    </div>
    <div
      className={Styles.resultContainer(theme, ~isShow={isSearching})}
      onClick={_ => {
        setIsSearching(_ => false)
        dispatch(ChangeSearchTerm(""))
      }}>
      <RenderSearchResult
        searchTerm={searchTerm->Js.String.trim}
        results=allQuery
        resultLength={Array.length(mergedResult)}
      />
    </div>
  </div>
}
