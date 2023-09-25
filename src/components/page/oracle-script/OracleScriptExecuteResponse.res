module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let resultContainer = (theme: Theme.t) => style(. [margin2(~v=#px(20), ~h=#zero)])
  let resultBox = style(. [padding(#px(12))])
  let labelWrapper = style(. [flexShrink(0.), flexGrow(0.), flexBasis(#px(220))])
  let resultWrapper = style(. [
    flexShrink(0.),
    flexGrow(0.),
    flexBasis(#calc((#sub, #percent(100.), #px(220)))),
  ])
}

module Loading = {
  @react.component
  let make = () => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.resultContainer(theme)}>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
        <div className=Styles.labelWrapper>
          <Text value="Exit Status" color={theme.neutral_600} weight=Text.Regular />
        </div>
        <LoadingCensorBar width=198 height=20 />
      </div>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
        <div className=Styles.labelWrapper>
          <Text value="Request ID" color={theme.neutral_600} weight=Text.Regular />
        </div>
        <LoadingCensorBar width=326 height=20 />
      </div>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
        <div className=Styles.labelWrapper>
          <Text value="Tx Hash" color={theme.neutral_600} weight=Text.Regular />
        </div>
        <LoadingCensorBar width=326 height=20 />
      </div>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
        <div className=Styles.labelWrapper>
          <Text value="Output" color={theme.neutral_600} weight=Text.Regular />
        </div>
        <LoadingCensorBar width=326 height=20 />
      </div>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
        <div className=Styles.labelWrapper>
          <Text value="Proof of Validaty" color={theme.neutral_600} weight=Text.Regular />
        </div>
        <LoadingCensorBar width=103 height=20 />
      </div>
    </div>
  }
}

@react.component
let make = (~txResponse: TxCreator.tx_response_t, ~schema: string) =>
  {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let requestsByTxHashSub = RequestSub.Mini.getListByTxHash(txResponse.txHash)
    let requestOpt = switch requestsByTxHashSub {
    | Data(requests) => requests->Belt.Array.get(0)
    | _ => None
    }

    <>
      <div className={Styles.resultContainer(theme)}>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
          <div className=Styles.labelWrapper>
            <Text value="Exit Status" color={theme.neutral_600} weight=Text.Regular />
          </div>
          <Text value={txResponse.code->Belt.Int.toString} />
        </div>
        {txResponse.code != 0
          ? <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
              <div className=Styles.labelWrapper>
                <Text value="Error Message" color={theme.neutral_600} weight=Text.Regular />
              </div>
              <Text value={`[${txResponse.rawLog}]`} color={theme.error_600} />
            </div>
          : React.null}
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
          <div className=Styles.labelWrapper>
            <Text value="Request ID" color={theme.neutral_600} weight=Text.Regular />
          </div>
          {switch requestOpt {
          | Some({id}) => <TypeID.Request id />
          | _ => <Text value="n/a" color={theme.neutral_400} />
          }}
        </div>
        <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
          <div className=Styles.labelWrapper>
            <Text value="Tx Hash" color={theme.neutral_600} weight=Text.Regular />
          </div>
          <TxLink txHash={txResponse.txHash} width=500 weight=Text.Regular />
        </div>
        {switch requestOpt {
        | Some({resolveStatus: Success, result: Some(result), id}) =>
          let outputKVsOpt = Obi.decode(schema, "output", result)
          switch outputKVsOpt {
          | Some(outputKVs) =>
            <>
              <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
                <div className=Styles.labelWrapper>
                  <Text
                    value="Output"
                    color={theme.neutral_600}
                    weight=Text.Regular
                    height={Text.Px(20)}
                  />
                </div>
                <div className=Styles.resultWrapper>
                  <KVTable
                    rows={outputKVs->Belt.Array.map(({fieldName, fieldValue}) => [
                      KVTable.Value(fieldName),
                      KVTable.Value(fieldValue),
                    ])}
                  />
                </div>
              </div>
              <OracleScriptExecuteProof id />
            </>
          | None =>
            <>
              <RequestFailedResult id />
              <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
                <div className=Styles.labelWrapper>
                  <Text
                    value="Output"
                    color={theme.neutral_600}
                    weight=Text.Regular
                    height={Text.Px(20)}
                  />
                </div>
                <div className=Styles.resultWrapper>
                  <Text
                    value="Schema not found"
                    color={theme.neutral_600}
                    weight=Text.Regular
                    height={Text.Px(20)}
                  />
                </div>
              </div>
            </>
          }
        | Some({resolveStatus: Success, result: None}) =>
          <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
            <div className=Styles.labelWrapper>
              <Text
                value="There is no result for this request."
                color={theme.neutral_600}
                weight=Text.Regular
              />
            </div>
          </div>
        | Some({resolveStatus: Pending, reportsCount, minCount, askCount}) =>
          <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
            <div className=Styles.labelWrapper>
              <Text
                value="Waiting for output and #proof#" color={theme.neutral_600} weight=Text.Regular
              />
            </div>
            <div className=Styles.resultWrapper>
              <ProgressBar
                reportedValidators=reportsCount
                minimumValidators=minCount
                requestValidators=askCount
              />
            </div>
          </div>
        | Some({id}) => <RequestFailedResult id />
        | None =>
          <>
            <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
              <div className=Styles.labelWrapper>
                <Text value="Output" color={theme.neutral_600} weight=Text.Regular />
              </div>
              {txResponse.code != 0
                ? <Text value="n/a" color={theme.neutral_400} />
                : <LoadingCensorBar width=326 height=20 />}
            </div>
            <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
              <div className=Styles.labelWrapper>
                <Text value="Proof of Validaty" color={theme.neutral_600} weight=Text.Regular />
              </div>
              {txResponse.code != 0
                ? <Text value="n/a" color={theme.neutral_400} />
                : <LoadingCensorBar width=103 height=20 />}
            </div>
          </>
        }}
      </div>
    </>->Sub.resolve
  }->Sub.default(React.null)
