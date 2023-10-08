module Styles = {
  open CssJs

  let container = style(. [
    padding2(~v=#px(40), ~h=#px(45)),
    Media.mobile([padding2(~v=#px(20), ~h=#zero)]),
  ])

  let upperTextCotainer = style(. [marginBottom(#px(24))])

  let listContainer = style(. [marginBottom(#px(25))])

  let input = (theme: Theme.t, isDarkMode) =>
    style(. [
      width(#percent(100.)),
      height(#px(37)),
      paddingLeft(#px(9)),
      paddingRight(#px(9)),
      borderRadius(#px(8)),
      fontSize(#px(14)),
      fontWeight(#light),
      border(#px(1), #solid, theme.neutral_300),
      backgroundColor(theme.neutral_000),
      outlineStyle(#none),
      color(theme.neutral_900),
      fontFamilies([#custom("Montserrat"), #custom("sans-serif")]),
    ])

  let button = (theme: Theme.t, isLoading) =>
    style(. [
      backgroundColor(isLoading ? theme.primary_200 : theme.primary_default),
      border(#px(1), #solid, theme.primary_default),
      fontWeight(#num(600)),
      opacity(isLoading ? 0.8 : 1.),
      cursor(isLoading ? #auto : #pointer),
      marginTop(#px(16)),
    ])

  let withWH = (w, h) =>
    style(. [width(w), height(h), display(#flex), justifyContent(#center), alignItems(#center)])

  let resultContainer = (theme: Theme.t) =>
    style(. [
      margin3(~top=#px(40), ~h=#auto, ~bottom=#zero),
      borderTop(#px(1), #solid, theme.neutral_300),
      paddingTop(#px(20)),
      selector("> div", [padding2(~v=#px(12), ~h=#zero)]),
    ])
  let resultBox = style(. [padding(#px(20))])
  let labelWrapper = style(. [
    flexShrink(0.),
    flexGrow(0.),
    flexBasis(#px(220)),
    Media.mobile([flexBasis(#px(100))]),
  ])
  let resultWrapper = style(. [
    flexShrink(0.),
    flexGrow(0.),
    flexBasis(#calc((#sub, #percent(100.), #px(220)))),
    Media.mobile([flexBasis(#calc((#sub, #percent(100.), #px(100))))]),
  ])
}

module ParameterInput = {
  @react.component
  let make = (~name, ~index, ~setCalldataList) => {
    let name = name->Js.String2.replaceByRe(%re(`/[_]/g`), " ")
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className=Styles.listContainer>
      <Text value=name size=Text.Body2 weight=Text.Semibold transform=Text.Capitalize />
      <VSpacing size=Spacing.sm />
      <input
        className={Styles.input(theme, isDarkMode)}
        type_="text"
        // TODO: Think about placeholder later
        // placeholder="Value"
        onChange={event => {
          let newVal = ReactEvent.Form.target(event)["value"]
          setCalldataList(prev => {
            prev->Belt.List.mapWithIndex((i, value) => {index == i ? newVal : value})
          })
        }}
      />
    </div>
  }
}

type result_data_t = {
  returncode: int,
  stdout: string,
  stderr: string,
}

type result_t =
  | Nothing
  | Loading
  | Error(string)
  | Success(result_data_t)

let loadingRender = (wDiv, wImg, h) => {
  <div className={Styles.withWH(wDiv, h)}>
    <LoadingCensorBar.CircleSpin size=wImg />
  </div>
}

module ResultRender = {
  @react.component
  let make = (~result) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    switch result {
    | Nothing => React.null
    | Loading =>
      <>
        <VSpacing size=Spacing.xxl />
        {loadingRender(#percent(100.), 30, #px(30))}
        <VSpacing size=Spacing.lg />
      </>
    | Error(err) =>
      <>
        <VSpacing size=Spacing.lg />
        <div className=Styles.resultWrapper>
          <Text value=err breakAll=true />
        </div>
      </>
    | Success({returncode, stdout, stderr}) =>
      <div className={Styles.resultContainer(theme)}>
        <Row>
          <Col col=Col.Two>
            <Text value="Exit Status" />
          </Col>
          <Col col=Col.Ten>
            <Text value={returncode->Belt.Int.toString} color={theme.neutral_900} />
          </Col>
        </Row>
        {stdout == ""
          ? React.null
          : <Row>
              <Col col=Col.Two>
                <Text value="Output" />
              </Col>
              <Col col=Col.Ten>
                <Text breakAll={true} value={stdout} color={theme.neutral_900} />
              </Col>
            </Row>}
        {stderr == ""
          ? React.null
          : <Row>
              <Col col=Col.Two>
                <Text value="Error" />
              </Col>
              <Col col=Col.Ten>
                <Text value={stderr} color={theme.error_600} code=true />
              </Col>
            </Row>}
      </div>
    }
  }
}

@react.component
let make = (~executable: JsBuffer.t) => {
  let params = ExecutableParser.parseExecutableScript(executable)->Belt.Option.getWithDefault([])
  let numParams = params->Belt.Array.length
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let (callDataList, setCalldataList) = React.useState(_ => Belt.List.make(numParams, ""))

  let (result, setResult) = React.useState(_ => Nothing)

  <Row>
    <Col>
      <div className=Styles.container>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.upperTextCotainer})}>
          <Text
            value={"Test data source execution" ++ (
              numParams == 0 ? "" : " with" ++ (numParams == 1 ? " a " : " ") ++ "following"
            )}
            size=Text.Body1
          />
          <HSpacing size=Spacing.sm />
          {numParams == 0
            ? React.null
            : <Text
                value={numParams > 1 ? "parameters" : "parameter"} weight=Text.Bold size=Text.Body1
              />}
        </div>
        {numParams > 0
          ? <>
              {params
              ->Belt.Array.mapWithIndex((i, param) =>
                <ParameterInput key=param name=param index=i setCalldataList />
              )
              ->React.array}
            </>
          : React.null}
        <div className="buttonContainer">
          <Button
            fsize=14
            style={Styles.button(theme, result == Loading)}
            px=25
            py=13
            onClick={_ =>
              if result !== Loading {
                setResult(_ => Loading)
                let _ =
                  AxiosRequest.execute(
                    AxiosRequest.t(
                      ~executable=executable->JsBuffer.toBase64,
                      ~calldata={
                        callDataList
                        ->Belt.List.reduce("", (acc, calldata) => acc ++ " " ++ calldata)
                        ->String.trim
                      },
                      ~timeout=5000,
                    ),
                  )
                  ->Promise.then(res => {
                    setResult(_ => Success({
                      returncode: res["data"]["returncode"],
                      stdout: res["data"]["stdout"],
                      stderr: res["data"]["stderr"],
                    }))
                    Promise.resolve()
                  })
                  ->Promise.catch(err => {
                    let errorValue =
                      Js.Json.stringifyAny(err)->Belt.Option.getWithDefault("Unknown")
                    setResult(_ => Error(errorValue))
                    Promise.resolve()
                  })
              }}>
            {(result == Loading ? "Executing ... " : "Test Execution")->React.string}
          </Button>
        </div>
        <ResultRender result />
      </div>
    </Col>
  </Row>
}
