module Styles = {
  open CssJs

  let container = (theme: Theme.t, isDarkMode) =>
    style(. [
      display(#flex),
      justifyContent(#center),
      position(#relative),
      width(#px(800)),
      height(#px(560)),
      background(isDarkMode ? theme.neutral_100 : theme.neutral_000),
    ])

  let innerContainer = style(. [display(#flex), flexDirection(#column), width(#percent(100.))])

  let loginSelectionContainer = style(. [padding2(~v=#zero, ~h=#px(24)), height(#percent(100.))])

  let modalTitle = (theme: Theme.t) =>
    style(. [
      display(#flex),
      justifyContent(#center),
      flexDirection(#column),
      alignItems(#center),
      paddingTop(#px(30)),
      borderBottom(#px(1), #solid, theme.neutral_200),
    ])

  let row = style(. [height(#percent(100.))])
  let rowContainer = style(. [margin2(~v=#zero, ~h=#px(12)), height(#percent(100.))])

  let header = (theme: Theme.t, active) =>
    style(. [
      display(#flex),
      flexDirection(#row),
      alignSelf(#center),
      alignItems(#center),
      padding2(~v=#zero, ~h=#px(20)),
      fontSize(#px(14)),
      fontWeight(active ? #bold : #normal),
      color(active ? theme.neutral_900 : theme.neutral_600),
    ])

  let loginList = (theme: Theme.t, active) =>
    style(. [
      display(#flex),
      width(#percent(100.)),
      height(#px(50)),
      borderRadius(#px(8)),
      border(#px(2), #solid, active ? theme.primary_600 : #transparent),
      cursor(#pointer),
      overflow(#hidden),
    ])

  let loginSelectionBackground = (theme: Theme.t, isDarkMode) =>
    style(. [background(isDarkMode ? theme.neutral_000 : theme.neutral_100)])

  let ledgerIcon = style(. [height(#px(28)), width(#px(28)), transform(translateY(#px(3)))])
  let ledgerImageContainer = active => style(. [opacity(active ? 1.0 : 0.5), marginRight(#px(15))])
}

type login_method_t =
  | Mnemonic
  | LedgerWithCosmos

let toLoginMethodString = method => {
  switch method {
  | Mnemonic => "Mnemonic Phrase"
  | LedgerWithCosmos => "Ledger - Cosmos"
  }
}

module LoginMethod = {
  @react.component
  let make = (~name, ~active, ~onClick) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.loginList(theme, active)} onClick>
      <div className={Styles.header(theme, active)}>
        {switch name {
        | LedgerWithCosmos =>
          <div className={Styles.ledgerImageContainer(active)}>
            <img
              alt="Cosmos Ledger Icon"
              src={isDarkMode ? Images.ledgerCosmosDarkIcon : Images.ledgerCosmosLightIcon}
              className=Styles.ledgerIcon
            />
          </div>
        | _ => <div />
        }}
        {name->toLoginMethodString->React.string}
      </div>
    </div>
  }
}

@react.component
let make = (~chainID) => {
  let (loginMethod, setLoginMethod) = React.useState(_ =>
    chainID == "laozi-mainnet" ? LedgerWithCosmos : Mnemonic
  )
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let loginMethodArray = switch chainID {
  | "laozi-mainnet" => [LedgerWithCosmos]
  | _ => [Mnemonic, LedgerWithCosmos]
  }

  <div className={Styles.container(theme, isDarkMode)}>
    <div className=Styles.innerContainer>
      <div className={Styles.modalTitle(theme)}>
        <Heading value="Connect with your wallet" size=Heading.H4 />
        {chainID == "laozi-mainnet"
          ? <>
              <VSpacing size=Spacing.md />
              <div className={CssHelper.flexBox()}>
                <Text value="Please check that you are visiting" size=Text.Body1 />
                <HSpacing size=Spacing.sm />
                <Text
                  value="https://www.cosmoscan.io"
                  size=Text.Body1
                  weight=Text.Medium
                  color={theme.neutral_900}
                />
              </div>
            </>
          : <VSpacing size=Spacing.sm />}
        <VSpacing size=Spacing.xxl />
      </div>
      <div className=Styles.rowContainer>
        <Row style=Styles.row>
          <Col col=Col.Five style={Styles.loginSelectionBackground(theme, isDarkMode)}>
            <div className=Styles.loginSelectionContainer>
              <VSpacing size=Spacing.xxl />
              <Heading size=Heading.H5 value="Select your connection method" />
              <VSpacing size=Spacing.md />
              {loginMethodArray
              ->Belt.Array.map(method =>
                <React.Fragment key={method |> toLoginMethodString}>
                  <VSpacing size=Spacing.lg />
                  <LoginMethod
                    name=method
                    active={loginMethod == method}
                    onClick={_ => setLoginMethod(_ => method)}
                  />
                </React.Fragment>
              )
              ->React.array}
            </div>
          </Col>
          <Col col=Col.Seven>
            {switch loginMethod {
            | Mnemonic => <ConnectWithMnemonic chainID />
            | LedgerWithCosmos => <ConnectWithLedger chainID ledgerApp=Ledger.Cosmos />
            }}
          </Col>
        </Row>
      </div>
    </div>
  </div>
}
