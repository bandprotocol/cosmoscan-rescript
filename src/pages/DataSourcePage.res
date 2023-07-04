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
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  //   let (page, setPage) = React.useState(_ => 1)
  let (searchTerm, setSearchTerm) = React.useState(_ => "")

  //   React.useEffect1(() => {
  //     // if searchTerm !== "" {
  //     //   setPage(_ => 1)
  //     // }
  //     None
  //   }, [searchTerm])

  <Section>
    <div className={CssHelper.container}>
      <div className={CssHelper.mb(~size=24, ())}>
        <Heading value="All Data Sources" size=Heading.H2 marginBottom=8 />
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <p className={Styles.bodyText(theme)}>
            {"A data source is an executable that describes a procedure to retrieve some type of data. Developers can create and customize data sources in "->React.string}
            <AbsoluteLink href="https://builder.bandprotocol.com" className={Styles.linkInline}>
              <Text value="BandBuilder" weight={Medium} color={theme.primary_600} />
            </AbsoluteLink>
          </p>
        </div>
      </div>
    </div>
    <div className={CssHelper.container}>
      <div id="section_datasource">
        <SearchInput
          placeholder="Search Data Source Name / ID" onChange=setSearchTerm maxWidth=460
        />
      </div>
      <div className={Styles.tableWrapper}>
        <DataSourceTable searchTerm />
      </div>
    </div>
  </Section>
}
