module Styles = {
  open CssJs

  let tableWrapper = style(. [
    marginTop(#px(24)),
    marginBottom(#px(8)),
    Media.mobile([marginTop(#px(8)), marginBottom(#px(8))]),
  ])
  let bodyText = (theme: Theme.t) => style(. [color(theme.neutral_600), fontSize(#px(14))])

  let linkInline = style(. [display(#inlineFlex)])
}

@react.component
let make = (~hashtag: Route.group_tab_t) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let (searchTerm, setSearchTerm) = React.useState(_ => "")

  <Section>
    <div className={CssHelper.container}>
      <div className={CssHelper.mb(~size=24, ())}>
        <Heading value="Group Module" size=Heading.H2 marginBottom=8 />
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <p className={Styles.bodyText(theme)}>
            {"A group is simply an aggregation of accounts with associated weights. This module allows the creation and management of on-chain multisig accounts and enables voting for message execution based on configurable decision policies."->React.string}
          </p>
        </div>
      </div>
    </div>
    <div className={CssHelper.container}>
      <GroupTab hashtag />
    </div>
  </Section>
}
