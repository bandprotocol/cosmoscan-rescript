module Styles = {
  open CssJs

  let cookieWrapper = (isShowCookie, theme: Theme.t) =>
    style(. [
      backgroundColor(theme.neutral_000),
      padding2(~v=#px(10), ~h=#px(20)),
      position(#fixed),
      bottom(#px(20)),
      borderRadius(#px(8)),
      left(#percent(50.)),
      transform(#translateX(#percent(-50.))),
      zIndex(1000),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(0, 0, 0, #num(0.1)))),
      display(isShowCookie ? #flex : #none),
      alignItems(#center),
    ])

  let cookieMessage = style(. [display(#flex)])

  let closeButton = (theme: Theme.t) =>
    style(. [
      width(#px(10)),
      cursor(#pointer),
      zIndex(3),
      marginLeft(#px(20)),
      selector("&:hover .fa-times", [color(theme.primary_600)]),
    ])
}
@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (isShowCookie, setIsShowCookie) = React.useState(_ => false)

  React.useEffect0(_ => {
    let cookie = JsCookie.get("cookie-accepted")
    if cookie {
      setIsShowCookie(_ => false)
    } else {
      setIsShowCookie(_ => true)
    }
    None
  })

  let handleOnClose = () => {
    JsCookie.set("cookie-accepted", "true", Some(JsCookie.cookie_attributes(~expires=Some(365))))
    setIsShowCookie(_ => false)
  }

  <div className={Styles.cookieWrapper(isShowCookie, theme)}>
    <div className={Styles.cookieMessage}>
      <Text size=Text.Body2 value="By using this website, you agree to our " />
      <HSpacing size=Spacing.xs />
      <AbsoluteLink href="https://www.cookiesandyou.com">
        <Text value="Cookie Policy" size=Text.Body2 color={theme.primary_600} />
      </AbsoluteLink>
    </div>
    <div id="closeCookie" className={Styles.closeButton(theme)} onClick={_ => handleOnClose()}>
      <Icon name="fal fa-times" size=16 />
    </div>
  </div>
}
