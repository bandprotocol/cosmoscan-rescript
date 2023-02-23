module Styles = {
  open CssJs

  let container = style(. [
    padding2(~v=#px(40), ~h=#px(45)),
    Media.mobile([padding2(~v=#px(20), ~h=#zero)]),
  ])

  let upperTextCotainer = style(. [marginBottom(#px(24))])

  let listContainer = style(. [width(#percent(100.)), marginBottom(#px(25))])

  let input = (theme: Theme.t, isDarkMode) =>
    style(. [
      width(#percent(100.)),
      height(#px(37)),
      paddingLeft(#px(9)),
      paddingRight(#px(9)),
      borderRadius(#px(4)),
      fontSize(#px(14)),
      fontWeight(#light),
      border(#px(1), #solid, isDarkMode ? theme.neutral_200 : theme.neutral_100),
      backgroundColor(isDarkMode ? theme.neutral_300 : theme.neutral_100),
      outlineStyle(#none),
      color(theme.neutral_900),
      fontFamilies([#custom("Montserrat"), #custom("sans-serif")]),
    ])

  let button = (theme: Theme.t, isLoading) =>
    style(. [
      backgroundColor(isLoading ? theme.primary_200 : theme.primary_600),
      fontWeight(#num(600)),
      opacity(isLoading ? 0.8 : 1.),
      cursor(isLoading ? #auto : #pointer),
      marginTop(#px(16)),
    ])

  let withWH = (w, h) =>
    style(. [width(w), height(h), display(#flex), justifyContent(#center), alignItems(#center)])

  let resultWrapper = (w, h, paddingV, overflowChioce) =>
    style(. [
      width(w),
      height(h),
      display(#flex),
      flexDirection(#column),
      padding2(~v=paddingV, ~h=#zero),
      justifyContent(#center),
      borderRadius(#px(4)),
      overflow(overflowChioce),
    ])

  let titleSpacing = style(. [marginBottom(#px(8))])
  let mobileBlockContainer = style(. [padding2(~v=#px(24), ~h=#zero)])
  let mobileBlock = style(. [
    borderRadius(#px(4)),
    minHeight(#px(164)),
    selector("> i", [marginBottom(#px(16))]),
  ])
}

module ConnectPanel = {
  module Styles = {
    open CssJs
    let connectContainer = (theme: Theme.t) =>
      style(. [
        backgroundColor(theme.neutral_100),
        borderRadius(#px(8)),
        padding(#px(24)),
        border(#px(1), #solid, theme.neutral_100),
      ])
    let connectInnerContainer = style(. [width(#percent(100.)), maxWidth(#px(370))])
  }
  @react.component
  let make = (~connect) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div
      className={Css.merge(list{
        Styles.connectContainer(theme),
        CssHelper.flexBox(~justify=#center, ()),
      })}>
      <div
        className={Css.merge(list{
          Styles.connectInnerContainer,
          CssHelper.flexBox(~justify=#spaceBetween, ()),
        })}>
        <Icon name="fal fa-link" size=32 color={theme.neutral_900} />
        <Text value="Please connect to make request" size=Text.Body1 nowrap=true block=true />
        <Button px=20 py=5 onClick={_ => {connect()}}> {"Connect"->React.string} </Button>
      </div>
    </div>
  }
}

module ParameterInput = {
  @react.component
  let make = (~params: Obi.field_key_type_t, ~index, ~setCallDataArr) => {
    let fieldType = params.fieldType
    let fieldName = params.fieldName->Js.String2.replaceByRe(%re(`/[_]/g`), " ")
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    <div className=Styles.listContainer key=fieldName>
      <div className={CssHelper.flexBox()}>
        <Text value=fieldName weight=Text.Semibold transform=Text.Capitalize />
        <HSpacing size=Spacing.xs />
        <Text value={j`($fieldType)`} weight=Text.Semibold />
      </div>
      <VSpacing size=Spacing.sm />
      <input
        className={Styles.input(theme, isDarkMode)}
        type_="text"
        onChange={event => {
          let newVal: string = ReactEvent.Form.target(event)["value"]
          setCallDataArr(prev => {
            prev->Belt.Array.mapWithIndex((i, value: string) => {index == i ? newVal : value})
          })
        }}
      />
    </div>
  }
}

module CountInputs = {
  @react.component
  let make = (~askCount, ~setAskCount, ~setMinCount, ~validatorCount) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <Row marginBottom=24>
      <Col col=Col.Two colSm=Col.Six>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.titleSpacing})}>
          <Text value="Ask Count" weight=Text.Semibold transform=Text.Capitalize />
          <HSpacing size=Spacing.xs />
          <CTooltip
            tooltipPlacementSm=CTooltip.BottomLeft
            tooltipText="The number of validators that are requested to respond to this request">
            <Icon name="fal fa-info-circle" size=10 />
          </CTooltip>
        </div>
        <div className={CssHelper.selectWrapper(~fontColor=theme.neutral_900, ())}>
          <select
            className={Styles.input(theme, isDarkMode)}
            onChange={event => {
              let newVal = ReactEvent.Form.target(event)["value"]
              setAskCount(_ => newVal)
            }}>
            {Belt.Array.makeBy(validatorCount, i => i + 1)
            ->Belt.Array.map(index =>
              <option key={index->Belt.Int.toString ++ "askCount"} value={index->Belt.Int.toString}>
                {index->Belt.Int.toString->React.string}
              </option>
            )
            ->React.array}
          </select>
        </div>
      </Col>
      <Col col=Col.Two colSm=Col.Six>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.titleSpacing})}>
          <Text value="Min Count" weight=Text.Semibold transform=Text.Capitalize />
          <HSpacing size=Spacing.xs />
          <CTooltip
            tooltipPlacementSm=CTooltip.BottomLeft
            tooltipText="The minimum number of validators necessary for the request to proceed to the execution phase">
            <Icon name="fal fa-info-circle" size=10 />
          </CTooltip>
        </div>
        <div className={CssHelper.selectWrapper(~fontColor=theme.neutral_900, ())}>
          <select
            className={Styles.input(theme, isDarkMode)}
            onChange={event => {
              let newVal = ReactEvent.Form.target(event)["value"]
              setMinCount(_ => newVal)
            }}>
            {Belt.Array.makeBy(askCount->Parse.mustParseInt, i => i + 1)
            ->Belt.Array.map(index =>
              <option key={index->Belt.Int.toString ++ "minCount"} value={index->Belt.Int.toString}>
                {index->Belt.Int.toString->React.string}
              </option>
            )
            ->React.array}
          </select>
        </div>
      </Col>
    </Row>
  }
}

module ClientIDInput = {
  @react.component
  let make = (~clientID, ~setClientID) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className=Styles.listContainer>
      <div className={CssHelper.flexBox()}>
        <Text value="Client ID" weight=Text.Semibold transform=Text.Capitalize />
        <HSpacing size=Spacing.xs />
        <Text value="(default value is from_scan)" weight=Text.Semibold />
      </div>
      <VSpacing size=Spacing.sm />
      <input
        className={Styles.input(theme, isDarkMode)}
        type_="text"
        onChange={event => {
          let newVal = ReactEvent.Form.target(event)["value"]
          setClientID(_ => newVal)
        }}
        value=clientID
      />
    </div>
  }
}

module ValueInput = {
  @react.component
  let make = (~value, ~setValue, ~title, ~info=?) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    
    <div className=Styles.listContainer>
      <div className={CssHelper.flexBox()}>
        <Text value=title weight=Text.Semibold transform=Text.Capitalize />
        <HSpacing size=Spacing.xs />
        <Text value={info->Belt.Option.getWithDefault("")} weight=Text.Semibold />
      </div>
      <VSpacing size=Spacing.sm />
      <input
        className={Styles.input(theme, isDarkMode)}
        type_="text"
        onChange={event => {
          let newVal = ReactEvent.Form.target(event)["value"]
          setValue(_ => newVal)
        }}
        value
      />
    </div>
  }
}

type result_t =
  | Nothing
  | Loading
  | Error(string)
  | Success(TxCreator.tx_response_t)

let loadingRender = (wDiv, wImg, h) => {
  <div className={Styles.withWH(wDiv, h)}>
    <LoadingCensorBar.CircleSpin size=wImg />
  </div>
}

let resultRender = (result, schema) => {
  switch result {
  | Nothing => React.null
  | Loading =>
    <>
      <VSpacing size=Spacing.xl />
      {loadingRender(#percent(100.), 30, #px(30))}
      <VSpacing size=Spacing.lg />
    </>
  | Error(err) =>
    <>
      <VSpacing size=Spacing.lg />
      <div className={Styles.resultWrapper(#percent(100.), #px(90), #zero, #scroll)}>
        <Text value=err />
      </div>
    </>
  | Success(txResponse) => <OracleScriptExecuteResponse txResponse schema />
  }
}

module MobileBlock = {
  @react.component
  let make = (~children) => {
    <div className=Styles.mobileBlockContainer>
      <div
        className={Css.merge(list{
          Styles.mobileBlock,
          CssHelper.flexBox(~justify=#center, ~direction=#column, ()),
        })}>
        children
      </div>
    </div>
  }
}

module ExecutionPart = {
  @react.component
  let make = (
    ~id: ID.OracleScript.t,
    ~schema: string,
    ~paramsInput: array<Obi.field_key_type_t>,
  ) => {
    let isMobile = Media.isMobile()

    // let client = React.useContext(ClientContext.context)
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let (accountOpt, dispatch) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let trackingSub = TrackingSub.use()
    let connect = chainID => dispatchModal(OpenModal(Connect(chainID)))
    let numParams = paramsInput->Belt.Array.length

    let validatorCount = ValidatorSub.countByActive(true)

    let (callDataArr, setCallDataArr) = React.useState(_ => Belt.Array.make(numParams, ""))
    let (clientID, setClientID) = React.useState(_ => "from_scan")
    let (feeLimit, setFeeLimit) = React.useState(_ => "100")
    let (prepareGas, setPrepareGas) = React.useState(_ => "")
    let (executeGas, setExecuteGas) = React.useState(_ => "")
    let (gaslimit, setGaslimit) = React.useState(_ => "")
    let (askCount, setAskCount) = React.useState(_ => "1")
    let (minCount, setMinCount) = React.useState(_ => "1")
    let (result, setResult) = React.useState(_ => Nothing)

    // TODO: Change when input can be empty
    let isUnused = {
      let field = paramsInput->Belt.Array.getExn(0)
      field.fieldName->Js.String2.startsWith("_")
    }
    React.useEffect0(() => {
      if isUnused {
        setCallDataArr(_ => ["0"])
      }
      None
    })

    let requestCallback = React.useCallback0(requestPromise => {
      ignore(
        requestPromise
        ->Promise.then(res =>
          switch res {
          | TxCreator.Tx(txResponse) =>
            setResult(_ => Success(txResponse))
            Promise.resolve()
          | _ =>
            setResult(
              _ => Error("Fail to sign message, please connect with mnemonic or ledger first"),
            )
            Promise.resolve()
          }
        )
        ->Promise.catch(err => {
          switch Js.Json.stringifyAny(err) {
          | Some(errorValue) => setResult(_ => Error(errorValue))
          | None => setResult(_ => Error("Can not stringify error"))
          }
          Promise.resolve()
        }),
      )
      ()
    })

    isMobile
      ? <MobileBlock>
          <Icon name="fal fa-exclamation-circle" size=32 color={theme.neutral_900} />
          <Text value="Oracle request" size=Text.Body1 align=Text.Center block=true />
          <Text value="not available on mobile" size=Text.Body1 align=Text.Center block=true />
        </MobileBlock>
      : <Row>
          <Col>
            <div className=Styles.container>
              {isUnused
                ? React.null
                : <div>
                    <div className={Css.merge(list{CssHelper.flexBox(), Styles.upperTextCotainer})}>
                      <Text value="This oracle script requires the following" size=Text.Body1 />
                      <HSpacing size=Spacing.sm />
                      {numParams == 0
                        ? React.null
                        : <Text
                            value={numParams > 1 ? "parameters" : "parameter"}
                            weight=Text.Bold
                            size=Text.Body1
                          />}
                    </div>
                    <VSpacing size=Spacing.lg />
                    <div className={CssHelper.flexBox(~direction=#column, ())}>
                      {paramsInput
                      ->Belt.Array.mapWithIndex((i, params) =>
                        <ParameterInput
                          params index=i setCallDataArr key={params.fieldName ++ params.fieldType}
                        />
                      )
                      ->React.array}
                    </div>
                  </div>}
              <ClientIDInput clientID setClientID />
              <ValueInput value=feeLimit setValue=setFeeLimit title="Fee Limit" info="(uband)" />
              <ValueInput
                value=prepareGas setValue=setPrepareGas title="Prepare Gas" info="(optional)"
              />
              <ValueInput
                value=executeGas setValue=setExecuteGas title="Execute Gas" info="(optional)"
              />
              <ValueInput value=gaslimit setValue=setGaslimit title="Gas Limit" info="(optional)" />
              <SeperatedLine />
              {switch validatorCount {
              | Data(count) =>
                let limitCount = count > 16 ? 16 : count
                <CountInputs askCount setAskCount setMinCount validatorCount=limitCount />
              | _ => React.null
              }}
              {switch accountOpt {
              | Some(_) =>
                <>
                  <Button
                    fsize=14
                    px=25
                    py=13
                    style={Styles.button(theme, result == Loading)}
                    onClick={_ =>
                      if result !== Loading {
                        // TODO: For testing OBI type-safe version, will be removed later
                        // Js.log(
                        //   Obi2.encode(
                        //     schema,
                        //     Obi2.Input,
                        //     Belt.List.map(paramsInput, input => input.fieldName)
                        //     ->Belt.List.zip(callDataArr->Belt.List.fromArray)
                        //     ->Belt.List.map(([fieldName, fieldValue]) => {fieldName, fieldValue}),
                        //   ),
                        // )

                        // Js.log(
                        //   Obi.encode(
                        //     schema,
                        //     "input",
                        //     Belt.List.map(paramsInput, input => input.fieldName)
                        //     ->Belt.List.zip(callDataArr)
                        //     ->Belt.List.map(([fieldName, fieldValue]) => {fieldName, fieldValue}),
                        //   ),
                        // )

                        switch Obi.encode(
                          schema,
                          "input",
                          paramsInput
                          ->Belt.Array.map(({fieldName}) => fieldName)
                          ->Belt.Array.zip(callDataArr)
                          ->Belt.Array.map(((fieldName, fieldValue)) => {
                            open Obi
                            {fieldName, fieldValue}
                          }),
                        ) {
                        | Some(encoded) =>
                          setResult(_ => Loading)
                          dispatch(
                            AccountContext.SendRequest({
                              oracleScriptID: id,
                              calldata: encoded,
                              callback: requestCallback,
                              askCount,
                              minCount,
                              clientID: {
                                switch clientID->String.trim == "" {
                                | false => clientID->String.trim
                                | true => "from_scan"
                                }
                              },
                              feeLimit: feeLimit->Parse.mustParseInt,
                              prepareGas: feeLimit->Parse.mustParseInt,
                              executeGas: feeLimit->Parse.mustParseInt,
                            }),
                          )
                          ()
                        | None =>
                          setResult(_ => Error("Encoding fail, please check each parameter's type"))
                        }
                        ()
                      }}>
                    {(result == Loading ? "Sending Request ... " : "Request")->React.string}
                  </Button>
                  {resultRender(result, schema)}
                </>
              | None =>
                switch trackingSub {
                | Data({chainID}) => <ConnectPanel connect={_ => connect(chainID)} />
                | Error(err) =>
                  // log for err details
                  Js.Console.log(err)
                  <Text value="chain id not found" />
                | _ => <LoadingCensorBar fullWidth=true height=120 />
                }
              }}
            </div>
          </Col>
        </Row>
  }
}

@react.component
let make = (~id: ID.OracleScript.t, ~schema: string) =>
  {
    let paramsInput = schema->Obi.extractFields("input")->Belt.Option.getExn
    Some(<ExecutionPart id schema paramsInput />)
  }->Belt.Option.getWithDefault(
    <MobileBlock>
      <Icon name="fal fa-exclamation-circle" size=32 />
      <Text value="Schema not found" />
    </MobileBlock>,
  )
