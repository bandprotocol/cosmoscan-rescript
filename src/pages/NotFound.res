module Styles = {
  open CssJs

  let vFlex = style(. [display(#flex), flexDirection(#row)])

  let pageContainer = (theme: Theme.t) =>
    style(. [
      width(#percent(100.)),
      paddingTop(#px(50)),
      minHeight(#px(450)),
      display(#flex),
      flexDirection(#column),
      alignItems(#center),
      justifyContent(#center),
      backgroundColor(theme.neutral_100),
      borderRadius(#px(8)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(0, 0, 0, #num(0.1)))),
    ])

  let linkToHome = style(. [display(#flex), alignItems(#center), cursor(#pointer)])

  let rightArrow = style(. [width(#px(20)), filter([#saturate(50.0), #brightness(70.0)])])

  let logo = style(. [width(#px(100)), marginRight(#px(10))])
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  <Section>
    <div className=CssHelper.container>
      <VSpacing size=Spacing.xxxl />
      <div className={Styles.pageContainer(theme)}>
        <div className={CssHelper.flexBox()}>
          <img
            src={isDarkMode ? Images.noOracleDark : Images.noOracleLight}
            alt="Not Found"
            className=Styles.logo
          />
        </div>
        <VSpacing size=Spacing.xxxl />
        <Text value="Oops! We cannot find the page you're looking for." size=Text.Body1 />
        <VSpacing size=Spacing.lg />
        <Link className=Styles.linkToHome route=Route.HomePage>
          <Text value="Back to Homepage" weight=Text.Bold size=Text.Body1 color=theme.neutral_900 />
          <HSpacing size=Spacing.md />
          <Icon name="far fa-arrow-right" color=theme.neutral_900 />
        </Link>
        <VSpacing size=Spacing.xxxl />
      </div>
    </div>
  </Section>
}
