module Styles = {
  open CssJs

  let container = style(. [
    padding2(~v=#px(40), ~h=#px(45)),
    Media.mobile([padding2(~v=#px(20), ~h=#zero)]),
  ])

  let upperTextCotainer = style(. [marginBottom(#px(24))])

  let listContainer = style(. [width(#percent(100.)), marginBottom(#px(25))])

  let input = (theme: Theme.t) =>
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
      backgroundColor(isLoading ? theme.primary_200 : theme.primary_600),
      fontWeight(#num(600)),
      opacity(isLoading ? 0.8 : 1.),
      cursor(isLoading ? #auto : #pointer),
      padding2(~v=#px(8), ~h=#px(56)),
    ])

  let withWH = (w, h) =>
    style(. [width(w), height(h), display(#flex), justifyContent(#center), alignItems(#center)])

  let gasContainer = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.neutral_100),
      padding2(~v=px(16), ~h=px(24)),
      borderRadius(#px(8)),
    ])

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
  let make = (~params: Obi2.field_key_type_t, ~index, ~setCallDataArr) => {
    let fieldType = params.fieldType
    let fieldName = params.fieldName->Js.String2.replaceByRe(%re(`/[_]/g`), " ")
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className=Styles.listContainer key=fieldName>
      <div className={CssHelper.flexBox()}>
        <Text value=fieldName size=Text.Body1 weight=Text.Semibold transform=Text.Capitalize />
        <HSpacing size=Spacing.xs />
        <Text value={j`($fieldType)`} weight=Text.Semibold />
        <Text value="*" size=Text.Body1 weight=Text.Semibold color=theme.error_600 />
      </div>
      <VSpacing size=Spacing.sm />
      <input
        className={Styles.input(theme)}
        type_="text"
        onChange={event => {
          let inputVal: string = ReactEvent.Form.target(event)["value"]
          let newVal = switch (fieldType, Js.String.charAt(0, inputVal) !== "[") {
          | ("[u8]", true) =>
            switch inputVal->JsBuffer.hexToStringArray {
            | value => value
            | exception _ => inputVal
            }
          | (_, _) => inputVal
          }

          setCallDataArr(prev => {
            prev->Belt_Array.mapWithIndex((i, value: string) => {index == i ? newVal : value})
          })
        }}
      />
    </div>
  }
}

module CountInputs = {
  @react.component
  let make = (~askCount, ~setAskCount, ~minCount, ~setMinCount, ~validatorCount) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    React.useEffect1(_ => {
      if minCount->Belt.Int.fromString > askCount->Belt.Int.fromString {
        setMinCount(_ => askCount)
      }
      None
    }, [askCount])

    <Row marginBottom=32>
      <Col col=Col.Two colSm=Col.Six>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.titleSpacing})}>
          <Text value="Ask Count" size=Text.Body1 weight=Text.Semibold transform=Text.Capitalize />
          <Text value="*" size=Text.Body1 weight=Text.Semibold color=theme.error_600 />
          <HSpacing size=Spacing.xs />
          <CTooltip
            tooltipPlacementSm=CTooltip.BottomLeft
            tooltipText="The number of validators that are requested to respond to this request">
            <Icon name="fal fa-info-circle" size=10 />
          </CTooltip>
        </div>
        <input
          className={Styles.input(theme)}
          type_="number"
          min="1"
          max={validatorCount}
          onChange={event => {
            let newVal = ReactEvent.Form.target(event)["value"]
            setAskCount(_ =>
              newVal->Belt.Int.fromString > validatorCount->Belt.Int.fromString
                ? validatorCount
                : newVal
            )
          }}
          value=askCount
        />
      </Col>
      <Col col=Col.Two colSm=Col.Six>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.titleSpacing})}>
          <Text value="Min Count" size=Text.Body1 weight=Text.Semibold transform=Text.Capitalize />
          <Text value="*" size=Text.Body1 weight=Text.Semibold color=theme.error_600 />
          <HSpacing size=Spacing.xs />
          <CTooltip
            tooltipPlacementSm=CTooltip.BottomLeft
            tooltipText="The minimum number of validators necessary for the request to proceed to the execution phase">
            <Icon name="fal fa-info-circle" size=10 />
          </CTooltip>
        </div>
        <input
          className={Styles.input(theme)}
          type_="number"
          min="1"
          max={askCount}
          onChange={event => {
            let newVal = ReactEvent.Form.target(event)["value"]
            setMinCount(_ =>
              newVal->Belt.Int.fromString > askCount->Belt.Int.fromString ? askCount : newVal
            )
          }}
          value=minCount
        />
      </Col>
    </Row>
  }
}

module ClientIDInput = {
  @react.component
  let make = (~clientID, ~setClientID) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className=Styles.listContainer>
      <div className={CssHelper.flexBox()}>
        <Text
          value="Client ID (Optional)"
          size=Text.Body1
          weight=Text.Semibold
          transform=Text.Capitalize
        />
        <HSpacing size=Spacing.xs />
        <CTooltip
          tooltipPlacementSm=CTooltip.BottomLeft
          tooltipText="A unique identifier for your application to help track the usage of the oracle script.">
          <Icon name="fal fa-info-circle" size=10 />
        </CTooltip>
      </div>
      <VSpacing size=Spacing.sm />
      <input
        className={Styles.input(theme)}
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
  let make = (~value, ~setValue, ~title, ~tooltip=?, ~inputType="text", ~required=false) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className=Styles.listContainer>
      <div className={CssHelper.flexBox()}>
        <Text value=title size=Text.Body1 weight=Text.Semibold transform=Text.Capitalize />
        {required
          ? <Text value="*" size=Text.Body1 weight=Text.Semibold color=theme.error_600 />
          : React.null}
        {switch tooltip {
        | Some(text) =>
          <>
            <HSpacing size=Spacing.xs />
            <CTooltip tooltipPlacementSm=CTooltip.BottomLeft tooltipText=text>
              <Icon name="fal fa-info-circle" size=10 />
            </CTooltip>
          </>
        | None => React.null
        }}
      </div>
      <VSpacing size=Spacing.sm />
      <input
        className={Styles.input(theme)}
        type_=inputType
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
  | Success(TxCreator.tx_response_t)
  | Error(string)

let loadingRender = (wDiv, wImg, h) => {
  <div className={Styles.withWH(wDiv, h)}>
    <LoadingCensorBar.CircleSpin size=wImg />
  </div>
}

let resultRender = (result, schema) => {
  switch result {
  | Nothing => React.null
  | Loading => <OracleScriptExecuteResponse.Loading />
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
    ~paramsInput: array<Obi2.field_key_type_t>,
  ) => {
    let isMobile = Media.isMobile()

    let client = React.useContext(ClientContext.context)
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    let (accountOpt, dispatch) = React.useContext(AccountContext.context)
    let trackingSub = TrackingSub.use()
    let (accountBoxState, setAccountBoxState, _, _) = React.useContext(WalletPopupContext.context)

    let connect = () =>
      accountBoxState == "noShow"
        ? setAccountBoxState(_ => "connect")
        : setAccountBoxState(_ => "noShow")
    let numParams = paramsInput->Belt.Array.length

    let validatorCount = ValidatorSub.countByActive(true)
    let (showAdvance, setShowAdvance) = React.useState(_ => false)

    // set parameter default value here
    let (callDataArr, setCallDataArr) = React.useState(_ => Belt.Array.make(numParams, ""))
    let (clientID, setClientID) = React.useState(_ => "from_scan")
    let (feeLimit, setFeeLimit) = React.useState(_ => "0.002")
    let (prepareGas, setPrepareGas) = React.useState(_ => 20000)
    let (executeGas, setExecuteGas) = React.useState(_ => 100000)
    let (gaslimit, setGaslimit) = React.useState(_ => 2000000)
    let (askCount, setAskCount) = React.useState(_ => "16")
    let (minCount, setMinCount) = React.useState(_ => "10")
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
              <ValueInput
                value=feeLimit
                setValue=setFeeLimit
                title="Fee Limit (BAND)"
                tooltip="The maximum number of BAND tokens that you are willing to pay for an oracle data request depends on each Oracle Script."
                required=true
              />
              {switch validatorCount {
              | Data(count) =>
                let limitCount = count > 16 ? 16 : count
                <CountInputs
                  askCount
                  setAskCount
                  minCount
                  setMinCount
                  validatorCount={limitCount->Belt.Int.toString}
                />
              | _ => React.null
              }}
              <div className={CssHelper.flexBox()}>
                <SwitchV2 checked=showAdvance onClick={_ => setShowAdvance(_ => !showAdvance)} />
                <Text value="Advanced settings" size=Text.Body1 color=theme.neutral_900 />
              </div>
              {showAdvance
                ? <div>
                    <VSpacing size=Spacing.lg />
                    <ClientIDInput clientID setClientID />
                    <Row style={Styles.gasContainer(theme, isDarkMode)} marginLeft=0 marginRight=0>
                      <Col col=Col.Twelve>
                        <ValueInput
                          value={gaslimit->Belt.Int.toString}
                          setValue=setGaslimit
                          title="Gas Limit (Optional)"
                          inputType="number"
                          tooltip="Maximum amount of computational steps that the oracle is allowed to use to fulfill the data request. The gas limit must be greater than or equal to the sum of the prepare gas and execute gas. If omitted, the gas used will be set to xxx."
                        />
                      </Col>
                      <Col col=Col.Six>
                        <ValueInput
                          value={executeGas->Belt.Int.toString}
                          setValue=setExecuteGas
                          title="Execute Gas (Optional)"
                          inputType="number"
                          tooltip="Used to execute the transaction. This includes things like calling the contract function and updating the state of the blockchain."
                        />
                      </Col>
                      <Col col=Col.Six>
                        <ValueInput
                          value={prepareGas->Belt.Int.toString}
                          setValue=setPrepareGas
                          title="Prepare Gas (Optional)"
                          inputType="number"
                          tooltip="Used to prepare the transaction for execution. This includes things like validating the transaction data and checking the signer's account balance."
                        />
                      </Col>
                    </Row>
                  </div>
                : React.null}
              <VSpacing size=Spacing.xl />
              {switch accountOpt {
              | Some(account) =>
                <>
                  <Button
                    fsize=14
                    px=25
                    py=13
                    style={Styles.button(theme, result == Loading)}
                    onClick={_ =>
                      if result !== Loading {
                        let inputDataEncode =
                          paramsInput
                          ->Belt.Array.map(({fieldName}) => fieldName)
                          ->Belt.Array.zip(callDataArr)
                          ->Belt.Array.map(((fieldName, fieldValue)) => {
                            open Obi2
                            {fieldName, fieldValue}
                          })

                        switch Obi2.encode(schema, Obi2.Input, inputDataEncode) {
                        | Some(encoded) =>
                          setResult(_ => Loading)
                          let _ = TxCreator.sendTransaction(
                            client,
                            account,
                            [
                              Msg.Input.RequestMsg({
                                oracleScriptID: id,
                                calldata: encoded,
                                askCount: askCount->Belt.Int.fromString->Belt.Option.getExn,
                                minCount: minCount->Belt.Int.fromString->Belt.Option.getExn,
                                sender: account.address,
                                clientID: {
                                  switch clientID->String.trim == "" {
                                  | false => clientID->String.trim
                                  | true => "from_scan"
                                  }
                                },
                                feeLimit: list{
                                  feeLimit
                                  ->Belt.Float.fromString
                                  ->Belt.Option.getExn
                                  ->(band => band *. 1000000.)
                                  ->Coin.newUBANDFromAmount,
                                },
                                prepareGas,
                                executeGas,
                                id: (),
                                oracleScriptName: (),
                                schema: (),
                              }),
                            ],
                            (gaslimit->Belt.Int.toFloat *. 0.0025)->Js.Math.ceil_int,
                            gaslimit,
                            "Request via scan",
                          )->Promise.then(res => {
                            switch res {
                            | Belt.Result.Ok(response) => setResult(_ => Success(response))
                            | Error(err) => setResult(_ => Error(err))
                            }
                            Promise.resolve()
                          })

                        | None =>
                          setResult(_ => Error("Encoding fail, please check each parameter's type"))
                        }
                        ()
                      }}>
                    {(result == Loading ? "Sending Request ... " : "Request")->React.string}
                  </Button>
                  <SeperatedLine mt=40 mb=40 />
                  {resultRender(result, schema)}
                </>
              | None =>
                switch trackingSub {
                | Data(_) => <ConnectPanel connect={_ => connect()} />
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
    let paramsInput = schema->Obi2.extractFields(Input)->Belt.Option.getExn
    Some(<ExecutionPart id schema paramsInput />)
  }->Belt.Option.getWithDefault(
    <MobileBlock>
      <Icon name="fal fa-exclamation-circle" size=32 />
      <Text value="Schema not found" />
    </MobileBlock>,
  )
