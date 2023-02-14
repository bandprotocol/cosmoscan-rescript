module Styles = {
  open CssJs
  let cardContainer = (theme: Theme.t) =>
    style(. [
      position(relative),
      padding2(~v=px(22), ~h=zero),
      selector("+ div", [marginTop(px(10)), borderTop(px(1), solid, theme.neutral_300)]),
    ])
  let cardItem = (alignItems_, isOneColumn) =>
    style(. [
      display(isOneColumn ? #block : #flex),
      alignItems(alignItems_),
      padding2(~v=px(9), ~h=zero),
    ])
  let cardItemHeading = style(. [
    display(#flex),
    flexDirection(column),
    flexGrow(0.),
    flexShrink(0.),
    flexBasis(#percent(25.)),
  ])
  let logo = style(. [width(px(20)), position(absolute), top(px(25)), right(zero)])
  let cardItemHeadingLg = style(. [padding2(~v=px(10), ~h=zero)])
  let infoContainer = isOneColumn =>
    style(. [width(#percent(100.)), marginTop(isOneColumn ? px(10) : zero), overflow(hidden)])
  let toggle = (theme: Theme.t) =>
    style(. [
      borderTop(px(1), solid, theme.neutral_300),
      paddingTop(px(10)),
      marginTop(px(10)),
      cursor(pointer),
    ])

  let infoCardContainer = style(. [padding(px(10)), selector("+ div", [marginTop(px(10))])])

  let infoCardContainerWrapper = (show, theme: Theme.t) => {
    style(. [
      marginTop(show ? px(16) : zero),
      transition(~duration=200, "all"),
      height(show ? auto : zero),
      opacity(show ? 1. : 0.),
      pointerEvents(none),
      selector("> div + div", [paddingTop(px(16))]),
      overflow(hidden),
      backgroundColor(theme.neutral_100),
    ])
  }
}

module InnerPanel = {
  @react.component
  let make = (~values, ~idx) => {
    values
    ->Belt.Array.mapWithIndex((index, (heading, value)) => {
      let alignItem = switch value {
      | InfoMobileCard.Messages(_)
      | PubKey(_) =>
        #baseline
      | _ => #center
      }
      let isOneColumn = switch value {
      | InfoMobileCard.KVTableReport(_)
      | KVTableRequest(_) => true
      | _ => false
      }
      <div
        className={Styles.cardItem(alignItem, isOneColumn)} key={idx ++ index->Belt.Int.toString}>
        <div className=Styles.cardItemHeading>
          {heading
          ->Js.String2.split("\n")
          ->Belt.Array.map(each => {
            switch value {
            | InfoMobileCard.Nothing =>
              <div className=Styles.cardItemHeadingLg>
                <Text key=each value=each size=Text.Caption />
              </div>
            | _ =>
              <Text key=each value=each size=Text.Caption weight=Text.Semibold />
            }
          })
          ->React.array}
        </div>
        <div className={Styles.infoContainer(isOneColumn)}>
          <InfoMobileCard info=value />
        </div>
      </div>
    })
    ->React.array
  }
}

@react.component
let make = (~values, ~idx, ~status=?, ~requestStatus=?, ~styles="", ~panels=[]) => {
  let (show, setShow) = React.useState(_ => false)
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className={CssJs.merge(. [Styles.cardContainer(theme), styles])}>
    <InnerPanel values idx />
    {panels->Belt.Array.length > 0
      ? <>
          <div className={Styles.infoCardContainerWrapper(show, theme)}>
            {panels
            ->Belt.Array.mapWithIndex((i, e) =>
              <div key={i->Belt.Int.toString ++ idx} className=Styles.infoCardContainer>
                <InnerPanel values=e idx />
              </div>
            )
            ->React.array}
          </div>
          <div
            onClick={_ => setShow(prev => !prev)}
            className={CssJs.merge(. [
              CssHelper.flexBox(~justify=#center, ()),
              Styles.toggle(theme),
            ])}>
            <Text
              block=true
              value={show ? "Hide Report" : "Show Report"}
              weight=Text.Semibold
              color={theme.neutral_900}
            />
            <HSpacing size=Spacing.xs />
            <Icon
              name={show ? "fas fa-caret-up" : "fas fa-caret-down"} color={theme.neutral_600}
            />
          </div>
        </>
      : React.null}
  </div>
}
