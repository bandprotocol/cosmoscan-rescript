module Styles = {
  open CssJs

  let proofContainer = style(. [
    selector(
      "> button + button",
      [
        marginLeft(#px(24)),
        Media.mobile([marginLeft(#px(16))]),
        Media.smallMobile([marginLeft(#px(10))]),
      ],
    ),
  ])

  let scriptContainer = style(. [
    position(#relative),
    fontSize(#px(12)),
    lineHeight(#px(20)),
    fontFamilies([
      #custom("IBM Plex Mono"),
      #custom("cousine"),
      #custom("sfmono-regular"),
      #custom("Consolas"),
      #custom("Menlo"),
      #custom("liberation mono"),
      #custom("ubuntu mono"),
      #custom("Courier"),
      #monospace,
    ]),
  ])

  let copyButtonContainer = style(. [position(#absolute), right(#em(1.)), top(#em(1.))])
  let copyButton = style(. [
    cursor(#pointer),
    borderRadius(#px(4)),
    backgroundColor(#transparent),
    color(white),
    border(#px(1), #solid, hex("6C7889")),
    selector("i", [color(hex("6C7889"))]),
    hover([
      borderColor(white),
      backgroundColor(#transparent),
      color(white),
      selector("i", [color(white)]),
    ]),
  ])

  let padding = style(. [padding(#px(20))])
}

@react.component
let make = (~signingDatumID: int) => {
  let (showProof, setShowProof) = React.useState(_ => false)
  let (copied, setCopy) = React.useState(_ => false)
  let (proofOpt, setProofOpt) = React.useState(_ => None)
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  React.useEffect1(() => {
    let intervalID = Js.Global.setInterval(() => {

      switch proofOpt {
      | Some(_) => ()
      | None =>
        let res = TSSProofHook.get(signingDatumID)->Promise.then(
          result => {
            setProofOpt(_ => result)
            Promise.resolve()
          },
        )
      }
    }, 2000)
    Some(() => Js.Global.clearInterval(intervalID))
  }, [proofOpt])

  switch proofOpt {
  | Some(proof) =>
    <>
      <div className={Css.merge(list{CssHelper.flexBox(), Styles.proofContainer})}>
        <ShowProofButton showProof setShowProof />
      </div>
      <VSpacing size=Spacing.lg />
      {showProof
        ? <div className=Styles.scriptContainer>
            <ReactHighlight className=Styles.padding>
              {proof.data->Js.Json.stringifyWithSpace(2)->React.string}
            </ReactHighlight>
            <div className=Styles.copyButtonContainer>
              <button
                className=Styles.copyButton
                onClick={_ => {
                  Copy.copy(proof.data->Js.Json.stringifyWithSpace(2))
                  setCopy(_ => true)
                  let _ = Js.Global.setTimeout(() => setCopy(_ => false), 1400)
                }}>
                {copied
                  ? <Icon name="fal fa-check" size=12 />
                  : <Icon name="far fa-clone" size=12 />}
              </button>
            </div>
          </div>
        : React.null}
    </>
  | None =>
    <EmptyContainer height={#px(130)} backgroundColor={theme.neutral_100}>
      <LoadingCensorBar.CircleSpin size=30 height=80 />
      <Heading
        size=Heading.H4 value="Waiting for proof" align=Heading.Center weight=Heading.Regular
      />
    </EmptyContainer>
  }
}
