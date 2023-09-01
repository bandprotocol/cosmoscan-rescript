module Styles = {
  open CssJs

  let footerBg = (theme: Theme.t, isDarkMode) =>
    style(. [
      zIndex(4),
      position(#fixed),
      bottom(#px(0)),
      width(#calc(#sub, #percent(100.), #px(Sidebar.sidebarWidth))),
      left(#px(Sidebar.sidebarWidth)), // sidebarwidth
      borderTop(#px(1), #solid, isDarkMode ? theme.neutral_400 : theme.neutral_300),
      height(#px(70)),
      overflow(#hidden),
      padding2(~v=#px(0), ~h=#px(0)),
      Media.mobile([
        position(#static),
        width(#percent(100.)),
        left(#px(0)),
        overflow(#hidden),
        height(#auto),
      ]),
    ])
  let links = style(. [
    selector("a", [marginRight(#px(40))]),
    selector("a:last-child", [marginRight(#px(0))]),
    Media.mobile([selector("a", [marginRight(#px(16))])]),
  ])
}

let footerLinks = [
  ["https:/\/bandprotocol.com", "Band Protocol"],
  ["https:/\/docs.bandchain.org", "Documentation"],
  ["https:/\/data.bandprotocol.com", "Band Standard Dataset"],
]

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <Section
    bg=theme.footer
    pt=24
    pb=24
    ptSm=24
    pbSm=24
    style={Css.merge(list{
      Styles.footerBg(theme, isDarkMode),
      CssHelper.flexBox(
        ~direction=#row,
        ~align=#center,
        ~justify=isMobile ? #center : #spaceBetween,
        (),
      ),
    })}>
    <div className=CssHelper.container>
      <Row alignItems=Row.Center>
        <Col col=Col.Six mbSm=24>
          <div
            className={Css.merge(list{
              CssHelper.flexBox(~justify=isMobile ? #center : #flexStart, ()),
              Styles.links,
            })}>
            {footerLinks
            ->Belt.Array.mapWithIndex((i, e) =>
              <AbsoluteLink key={Belt.Int.toString(i)} href={e[0]} showArrow=true>
                <Text value={e[1]} color={theme.neutral_600} size={Body2} weight={Semibold} />
              </AbsoluteLink>
            )
            ->React.array}
          </div>
        </Col>
        <Col col=Col.Six>
          <div className={CssHelper.flexBox(~justify=isMobile ? #center : #flexEnd, ())}>
            <Text block=true value="Band Protocol" weight=Text.Semibold color=theme.neutral_600 />
            <HSpacing size=#px(5) />
            <Icon name="far fa-copyright" color=theme.neutral_600 />
            <HSpacing size=#px(5) />
            <Text
              block=true
              value={Js.Date.getFullYear(Js.Date.make())->Belt.Float.toString}
              weight=Text.Semibold
              color=theme.neutral_600
            />
          </div>
        </Col>
      </Row>
    </div>
  </Section>
}
