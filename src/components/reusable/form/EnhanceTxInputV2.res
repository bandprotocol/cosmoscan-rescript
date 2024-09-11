module Styles = {
  open CssJs

  let container = style(. [position(#relative), paddingBottom(#px(24))])
  let inputContainer = style(. [position(#relative)])
  let input = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      height(#px(37)),
      paddingLeft(#px(16)),
      paddingRight(#px(9)),
      borderRadius(#px(8)),
      fontSize(#px(14)),
      fontWeight(#light),
      border(#px(1), #solid, theme.neutral_200),
      backgroundColor(theme.neutral_000),
      outlineStyle(#none),
      color(theme.neutral_900),
      fontFamilies([#custom("Montserrat"), #custom("sans-serif")]),
    ])

  let code = style(. [fontFamilies([#custom("Roboto Mono"), #monospace]), paddingBottom(#em(0.1))])

  let errMsg = style(. [position(#absolute), bottom(#px(7))])
  let maxButton = (theme: Theme.t) =>
    style(. [
      display(#flex),
      position(#absolute),
      right(#px(0)),
      top(#px(0)),
      height(#percent(100.)),
      marginRight(#px(16)),
      selector("> button", [fontWeight(#bold), color(theme.primary_600)]),
    ])
}

type input_t<'a> = {
  text: string,
  value: option<'a>,
}

type status<'a> =
  | Untouched
  | Touched(Result.t<'a>)

let empty = {text: "", value: None}

@react.component
let make = (
  ~inputData,
  ~setInputData,
  ~msg,
  ~parse,
  ~maxValue=?,
  ~width,
  ~code=false,
  ~placeholder="",
  ~inputType="text",
  ~autoFocus=false,
  ~maxWarningMsg=false,
  ~id,
) => {
  let (status, setStatus) = React.useState(_ => Untouched)

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let onNewText = newText => {
    let newVal = parse(newText)
    setStatus(_ => Touched(newVal))
    switch newVal {
    | Ok(newVal') => setInputData(_ => {text: newText, value: Some(newVal')})
    | Err(_) => setInputData(_ => {text: newText, value: None})
    }
  }

  <div className=Styles.container>
    <Heading
      value=msg
      size=Heading.H5
      marginBottom=8
      align=Heading.Left
      color={theme.neutral_600}
      weight=Heading.Regular
    />
    {switch maxValue {
    | Some(maxValue') =>
      <>
        <div className={Styles.inputContainer}>
          <input
            id
            value={inputData.text}
            className={Css.merge(list{Styles.input(theme), code ? Styles.code : ""})}
            placeholder
            type_=inputType
            spellCheck=false
            autoFocus
            onChange={event => {
              let newText = ReactEvent.Form.target(event)["value"]
              onNewText(newText)
            }}
          />
          <div className={Styles.maxButton(theme)}>
            <Button
              variant=Button.Text({underline: false})
              fsize=14
              onClick={_ =>
                maxWarningMsg
                  ? {
                      let isConfirm = {
                        open Webapi.Dom
                        window->Window.confirm({
                          j`You will not have balance to do any action after using max balance.`
                        })
                      }
                      isConfirm ? onNewText(maxValue') : ()
                    }
                  : onNewText(maxValue')}
              disabled={inputData.text == maxValue'}>
              {"Max"->React.string}
            </Button>
          </div>
        </div>
        <VSpacing size={#px(4)} />
        <Text value={`Available: ${maxValue'} BAND`} />
      </>
    | None =>
      <div className={Styles.inputContainer}>
        <input
          id
          value={inputData.text}
          className={Css.merge(list{Styles.input(theme), code ? Styles.code : ""})}
          placeholder
          type_=inputType
          spellCheck=false
          autoFocus
          onChange={event => {
            let newText = ReactEvent.Form.target(event)["value"]
            onNewText(newText)
          }}
        />
      </div>
    }}
    {switch status {
    | Touched(Err(errMsg)) =>
      <div className=Styles.errMsg>
        <Text value=errMsg size=Text.Caption color={theme.error_600} />
      </div>
    | _ => React.null
    }}
  </div>
}

module Loading = {
  @react.component
  let make = (~msg, ~useMax=false, ~code=false, ~placeholder) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div className=Styles.container>
      <Heading
        value=msg
        size=Heading.H5
        marginBottom=8
        align=Heading.Left
        color={theme.neutral_600}
        weight=Heading.Regular
      />
      <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
        <input
          className={Css.merge(list{Styles.input(theme), code ? Styles.code : ""})}
          placeholder
          disabled=true
        />
        {useMax
          ? <>
              <HSpacing size=Spacing.md />
              <div className={Styles.maxButton(theme)}>
                <Button
                  variant=Button.Text({underline: false}) fsize=14 onClick={_ => ()} disabled=true>
                  {"Max"->React.string}
                </Button>
              </div>
            </>
          : React.null}
      </div>
    </div>
  }
}
