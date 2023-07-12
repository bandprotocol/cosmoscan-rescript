module Styles = {
  open CssJs

  let tableWrapper = style(. [marginTop(#px(8)), marginBottom(#px(8))])
}

@react.component
let make = () => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (page, setPage) = React.useState(_ => 1)
  let (searchTerm, setSearchTerm) = React.useState(_ => "")

  React.useEffect1(() => {
    if searchTerm !== "" {
      setPage(_ => 1)
    }
    None
  }, [searchTerm])

  <Section>
    <div className={CssHelper.container}>
      <div className={CssHelper.mb(~size=24, ())}>
        <Heading value="All Oracle Scripts" size=Heading.H2 marginBottom=8 />
        <div className={CssHelper.flexBox(~align=#center, ())}>
          <Text
            value="Oracle scripts bring real-world data onto the blockchain for smart contracts to use. Developers can create and customize these scripts in "
          />
          <HSpacing size=Spacing.xs />
          <AbsoluteLink href="https://builder.bandprotocol.com">
            <Text value="BandBuilder" weight={Medium} color={theme.primary_600} />
          </AbsoluteLink>
        </div>
      </div>
    </div>
    <div className={CssHelper.container}>
      <div className={CssHelper.mb(~size=24, ())} id="oraclescriptsSection">
        <SearchInput
          placeholder="Search Oracle Script or Data Source Name / ID"
          onChange=setSearchTerm
          maxWidth=460
        />
      </div>
      <div className={Styles.tableWrapper}>
        <OracleScriptsTable searchTerm />
      </div>
    </div>
  </Section>
}
