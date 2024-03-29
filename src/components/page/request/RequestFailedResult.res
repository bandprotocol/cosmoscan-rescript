module Styles = {
  open CssJs
  let reasonSection = (theme: Theme.t) =>
    style(. [
      padding2(~v=#px(24), ~h=#px(40)),
      important(border(#px(1), solid, theme.error_600)),
      borderRadius(#px(12)),
      marginTop(#px(40)),
      display(#flex),
      alignItems(#center),
    ])
  let resultBox = style(. [padding(#px(20))])
  let labelWrapper = style(. [flexShrink(0.), flexGrow(0.), flexBasis(#px(220))])
  let resultWrapper = style(. [
    flexShrink(0.),
    flexGrow(0.),
    flexBasis(#calc((#sub, #percent(100.), #px(220)))),
  ])
}

@react.component
let make = (~id) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  let requestSub = RequestSub.get(id)
  <>
    <div className={Css.merge(list{CssHelper.flexBox(), Styles.resultBox})}>
      {switch requestSub {
      | Data({resolveStatus, resolveHeight}) =>
        <>
          <div className=Styles.labelWrapper>
            <Text value="Resolve Status" color={theme.neutral_600} weight=Text.Regular />
          </div>
          <div className={CssHelper.flexBox()}>
            <RequestStatus resolveStatus display=RequestStatus.Full size=Text.Body2 />
            {switch resolveHeight {
            | Some(height) =>
              <>
                <HSpacing size=Spacing.md />
                <Text value=" (" block=true color={theme.neutral_900} />
                <TypeID.Block id=height />
                <Text value=")" block=true color={theme.neutral_900} />
              </>
            | None => React.null
            }}
          </div>
        </>
      | _ => <LoadingCensorBar.CircleSpin height=90 />
      }}
    </div>
    {switch requestSub {
    | Data({reason}) =>
      switch reason {
      | Some(reason') if reason' !== "" =>
        <div className={Styles.reasonSection(theme)}>
          <img alt="Request Failed" src=Images.fail />
          <HSpacing size=Spacing.md />
          <Text value=reason' color={theme.neutral_900} />
        </div>
      | _ => React.null
      }
    | _ => React.null
    }}
  </>
}
