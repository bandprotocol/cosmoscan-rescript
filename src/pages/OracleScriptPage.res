module Styles = {
  open CssJs
  let mostRequestCard = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.neutral_100),
      borderRadius(#px(12)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.2)))),
      padding3(~top=#px(24), ~h=#px(24), ~bottom=#px(16)),
      height(#calc((#sub, #percent(100.), #px(23)))),
      marginBottom(#px(24)),
    ])
  let requestResponseBox = style(. [flexShrink(0.), flexGrow(0.), flexBasis(#percent(50.))])
  let descriptionBox = style(. [
    minHeight(#px(36)),
    margin3(~top=#px(32), ~h=#zero, ~bottom=#px(16)),
  ])
  let idBox = style(. [marginBottom(#px(4))])
  let tbodyContainer = style(. [minHeight(#px(600))])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])

  let oracleScriptLink = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.primary_600),
      borderRadius(#px(8)),
      width(#px(32)),
      height(#px(32)),
      hover([backgroundColor(theme.primary_500)]),
    ])

  let heading = style(. [marginTop(#px(10))])
}

type sort_by_t =
  | MostRequested
  | LatestUpdate

let getName = x =>
  switch x {
  | MostRequested => "Most Requested"
  | LatestUpdate => "Latest Update"
  }

let defaultCompare = (a: OracleScriptSub.t, b: OracleScriptSub.t) =>
  if a.timestampOpt !== b.timestampOpt {
    compare(b.id->ID.OracleScript.toInt, a.id->ID.OracleScript.toInt)
  } else {
    compare(b.requestCount, a.requestCount)
  }

let sorting = (oracleSctipts: array<OracleScriptSub.t>, sortedBy) => {
  oracleSctipts
  ->Belt.List.fromArray
  ->Belt.List.sort((a, b) => {
    let result = {
      switch sortedBy {
      | MostRequested => compare(b.requestCount, a.requestCount)
      | LatestUpdate => compare(b.timestampOpt, a.timestampOpt)
      }
    }
    if result !== 0 {
      result
    } else {
      defaultCompare(a, b)
    }
  })
  ->Belt.List.toArray
}

module RenderMostRequestedCard = {
  @react.component
  let make = (
    ~reserveIndex,
    ~oracleScriptSub: Sub.variant<OracleScriptSub.t>,
    ~statsSub: Sub.variant<array<OracleScriptSub.response_last_1_day_external>>,
  ) => {
    let allSub = Sub.all2(oracleScriptSub, statsSub)
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <Col
      key={switch oracleScriptSub {
      | Data({id}) => id->ID.OracleScript.toString
      | _ => reserveIndex->Belt.Int.toString
      }}
      col=Col.Four>
      <div
        className={Css.merge(list{
          Styles.mostRequestCard(theme),
          CommonStyles.card(theme, isDarkMode),
          CssHelper.flexBox(~direction=#column, ~justify=#spaceBetween, ~align=#stretch, ()),
        })}>
        <div
          className={CssHelper.flexBox(
            ~justify=#spaceBetween,
            ~align=#flexStart,
            ~wrap=#nowrap,
            (),
          )}>
          <div>
            <div className=Styles.idBox>
              {switch oracleScriptSub {
              | Data({id}) => <TypeID.OracleScript id position=TypeID.Title />
              | _ => <LoadingCensorBar width=40 height=15 />
              }}
            </div>
            {switch oracleScriptSub {
            | Data({name}) =>
              <Heading size=Heading.H4 value=name weight=Heading.Thin marginTop=24 />
            | _ => <LoadingCensorBar width=200 height=15 />
            }}
          </div>
          {switch oracleScriptSub {
          | Data({id}) =>
            <TypeID.OracleScriptLink id>
              <div
                className={Css.merge(list{
                  Styles.oracleScriptLink(theme),
                  CssHelper.flexBox(~justify=#center, ()),
                })}>
                <Icon name="far fa-arrow-right" color={theme.white} />
              </div>
            </TypeID.OracleScriptLink>
          | _ => <LoadingCensorBar width=32 height=32 radius=8 />
          }}
        </div>
        <div className=Styles.descriptionBox>
          {switch oracleScriptSub {
          | Data({description}) =>
            let text = Ellipsis.end(~text=description, ~limit=70, ())
            <Text value=text block=true />
          | _ => <LoadingCensorBar width=250 height=15 />
          }}
        </div>
        <SeperatedLine />
        <div className={CssHelper.flexBox()}>
          <div className=Styles.requestResponseBox>
            <Heading
              size=Heading.H5
              value="Requests"
              marginBottom=8
              weight=Heading.Thin
              color={theme.neutral_600}
            />
            {switch oracleScriptSub {
            | Data({requestCount}) =>
              <Text value={requestCount->Format.iPretty} block=true color={theme.neutral_900} />
            | _ => <LoadingCensorBar width=100 height=15 />
            }}
          </div>
          <div className=Styles.requestResponseBox>
            <Heading
              size=Heading.H5
              value="Response time"
              marginBottom=8
              weight=Heading.Thin
              color={theme.neutral_600}
            />
            {switch allSub {
            | Data(({id}, stats)) =>
              let resultOpt = stats->Belt.Array.getBy(stat => id == stat.id)
              switch resultOpt {
              | Some({responseTime}) =>
                <Text
                  value={responseTime->Format.fPretty(~digits=2) ++ " s"}
                  block=true
                  color={theme.neutral_900}
                />
              | None => <Text value="TBD" />
              }
            | _ => <LoadingCensorBar width=100 height=15 />
            }}
          </div>
        </div>
      </div>
    </Col>
  }
}

module RenderBody = {
  @react.component
  let make = (
    ~reserveIndex,
    ~oracleScriptSub: Sub.variant<OracleScriptSub.t>,
    ~statsSub: Sub.variant<array<OracleScriptSub.response_last_1_day_external>>,
  ) => {
    let allSub = Sub.all2(oracleScriptSub, statsSub)

    let tableWrapper = style(. [
      marginTop(#px(24)),
      marginBottom(#px(8)),
      Media.mobile([marginTop(#px(8)), marginBottom(#px(8))]),
    ])
    let bodyText = (theme: Theme.t, isDarkMode) =>
      style(. [color(isDarkMode ? theme.neutral_000 : theme.neutral_600), fontSize(#px(14))])

    <TBody
      key={switch oracleScriptSub {
      | Data({id}) => id->ID.OracleScript.toString
      | _ => reserveIndex->Belt.Int.toString
      }}>
      <Row alignItems=Row.Center>
        <Col col=Col.Four>
          {switch oracleScriptSub {
          | Data({id, name}) =>
            <div className={CssHelper.flexBox()}>
              <TypeID.OracleScript id />
              <HSpacing size=Spacing.sm />
              <Text value=name ellipsis=true color={theme.neutral_900} />
            </div>
          | _ => <LoadingCensorBar width=300 height=15 />
          }}
        </Col>
        <Col col=Col.Four>
          {switch oracleScriptSub {
          | Data({description}) =>
            let text = Ellipsis.end(~text=description, ~limit=70, ())
            <Text value=text block=true />
          | _ => <LoadingCensorBar width=270 height=15 />
          }}
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#flexStart, ~align=#flexStart, ())}>
            {switch allSub {
            | Data(({id, requestCount}, stats)) =>
              let resultOpt = stats->Belt.Array.getBy(stat => id == stat.id)
              <>
                <div>
                  <Text
                    value={requestCount->Format.iPretty} weight=Text.Medium block=true ellipsis=true
                  />
                </div>
                <HSpacing size={#px(2)} />
                <div>
                  <Text
                    value={switch resultOpt {
                    | Some({responseTime}) =>
                      "(" ++ responseTime->Format.fPretty(~digits=2) ++ " s)"
                    | None => "(TBD)"
                    }}
                    weight=Text.Medium
                    block=true
                  />
                </div>
              </>
            | _ => <LoadingCensorBar width=70 height=15 />
            }}
          </div>
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch oracleScriptSub {
            | Data({timestampOpt}) =>
              switch timestampOpt {
              | Some(timestamp') =>
                <Timestamp
                  time=timestamp' size=Text.Body2 weight=Text.Regular textAlign=Text.Right
                />
              | None => <Text value="Genesis" />
              }
            | _ => <LoadingCensorBar width=80 height=15 />
            }}
          </div>
        </Col>
      </Row>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (
    ~reserveIndex,
    ~oracleScriptSub: Sub.variant<OracleScriptSub.t>,
    ~statsSub: Sub.variant<array<OracleScriptSub.response_last_1_day_external>>,
  ) => {
    switch oracleScriptSub {
    | Data({id, timestampOpt, description, name, requestCount}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Oracle Script", OracleScript(id, name)),
            ("Description", Text(description)),
            (
              "Request&\nResponse time",
              switch statsSub {
              | Data(stats) =>
                RequestResponse({
                  requestCount,
                  responseTime: stats
                  ->Belt.Array.getBy(stat => id == stat.id)
                  ->Belt.Option.map(({responseTime}) => responseTime),
                })
              | _ => Loading(80)
              },
            ),
            (
              "Timestamp",
              switch timestampOpt {
              | Some(timestamp') => Timestamp(timestamp')
              | None => Text("Genesis")
              },
            ),
          ]
        }
        key={id->ID.OracleScript.toString}
        idx={id->ID.OracleScript.toString}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Oracle Script", Loading(200)),
            ("Description", Loading(200)),
            ("Request&\nResponse time", Loading(80)),
            ("Timestamp", Loading(180)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (page, setPage) = React.useState(_ => 1)
  let (searchTerm, setSearchTerm) = React.useState(_ => "")

  React.useEffect1(() => {
    if searchTerm !== "" {
      setPage(_ => 1)
    }
    None
  }, [searchTerm])

  <Section>
    <div className={CssHelper.container}>
      <div className={CssHelper.mb(~size=24, ())}>
        <Heading value="All Oracle Scripts" size=Heading.H2 marginBottom=8 />
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <p className={Styles.bodyText(theme, isDarkMode)}>
            {"Oracle scripts bring real-world data onto the blockchain for smart contracts to use. Developers can create and customize these scripts in "->React.string}
            <AbsoluteLink href="https://builder.bandprotocol.com" className={Styles.linkInline}>
              <Text value="BandBuilder" weight={Medium} color={theme.primary_600} />
            </AbsoluteLink>
          </p>
        </div>
      </div>
    </div>
    <div className={CssHelper.container}>
      <div id="oraclescriptsSection">
        <SearchInput
          placeholder="Search Oracle Script / ID or Data Source Name"
          onChange=setSearchTerm
          maxWidth=460
        />
      </div>
      <div className={Styles.tableWrapper}>
        <OracleScriptsTable searchTerm />
      </div>
    </div>
  </Section>
}
