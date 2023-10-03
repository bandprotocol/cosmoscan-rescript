module Styles = {
  open CssJs

  let notiWrapper = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.warning_100),
      padding2(~v=#px(10), ~h=#px(20)),
      width(#percent(100.)),
      borderRadius(#px(8)),
      left(#percent(0.)),
      zIndex(1000),
      alignItems(#center),
      marginBottom(#px(20)),
    ])
}

@react.component
let make = () => {
  let isMaintenance = BlockSub.isUnderMaintenance()
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  {
    isMaintenance
      ? <div className={Css.merge(list{CssHelper.container})}>
          <Row marginTop=40>
            <Col col=Col.Twelve>
              <div className={Styles.notiWrapper(theme)}>
                <div
                  className={Css.merge(list{
                    CssHelper.flexBox(~align=#center, ()),
                    CssHelper.mb(~size=8, ()),
                  })}>
                  <Icon name="fas fa-exclamation-triangle" size=18 color={theme.warning_700} />
                  <HSpacing size={Spacing.sm} />
                  <Heading
                    value="Our node is under maintenance" size={H3} color={theme.warning_700}
                  />
                </div>
                <Text
                  color={theme.warning_700}
                  value={"Sorry for inconvenience, but performing some maintenance to enhance performance and security at the moment. During this period, certain services may be temporarily unavailable."}
                />
              </div>
            </Col>
          </Row>
        </div>
      : React.null
  }
}
