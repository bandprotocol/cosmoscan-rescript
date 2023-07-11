type field_t =
  | Value(string)
  | Values(array<string>)
  | DataSource(ID.DataSource.t, string)
  | Block(ID.Block.t)
  | TxHash(Hash.t)
  | Validator(ValidatorSub.Mini.t)

module Styles = {
  open CssJs
  let tabletContainer = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(8), ~h=#px(24)),
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.neutral_100),
      borderRadius(px(8)),
      Media.mobile([padding2(~v=#px(8), ~h=#px(12))]),
      width(#percent(100.)),
    ])

  let tableSpacing = style(. [
    padding2(~v=#px(8), ~h=zero),
    Media.mobile([padding2(~v=#px(4), ~h=zero)]),
  ])

  let valueContainer = mw =>
    style(. [
      maxWidth(px(mw)),
      minHeight(px(20)),
      display(#flex),
      flexDirection(row),
      alignItems(center),
    ])
}

let renderField = (field, maxWidth, theme: Theme.t) => {
  switch field {
  | Value(v) =>
    <div className={Styles.valueContainer(maxWidth)}>
      <Text value=v nowrap=true ellipsis=true block=true size=Text.Body1 color=theme.neutral_900 />
    </div>
  | Values(vals) =>
    <div className={CssHelper.flexBox(~direction=#column, ())}>
      {vals
      ->Belt.Array.mapWithIndex((i, v) =>
        <div key={i->Belt.Int.toString ++ v} className={Styles.valueContainer(maxWidth)}>
          <Text value=v nowrap=true ellipsis=true block=true align=Text.Right />
        </div>
      )
      ->React.array}
    </div>
  | DataSource(id, name) =>
    <div className={Styles.valueContainer(maxWidth)}>
      <TypeID.DataSource id position=TypeID.Mini />
      <HSpacing size=Spacing.sm />
      <Text
        value=name
        weight=Text.Regular
        spacing={Text.Em(0.02)}
        size=Text.Caption
        height={Text.Px(16)}
      />
    </div>
  | Block(id) =>
    <div className={Styles.valueContainer(maxWidth)}>
      <TypeID.Block id position=TypeID.Mini />
    </div>
  | TxHash(txHash) =>
    <div className={Styles.valueContainer(maxWidth)}>
      <TxLink txHash width=maxWidth size=Text.Caption />
    </div>
  | Validator(validator) =>
    <div className={Styles.valueContainer(maxWidth)}>
      <ValidatorMonikerLink
        size=Text.Caption
        validatorAddress={validator.operatorAddress}
        width={#px(maxWidth)}
        moniker={validator.moniker}
        identity={validator.identity}
      />
    </div>
  }
}

@react.component
let make = (~headers=["Key", "Value"], ~rows) => {
  let columnSize = headers->Belt.Array.length > 2 ? Col.Four : Col.Six
  let valueWidth = Media.isMobile() ? 70 : 480

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className={Styles.tabletContainer(theme, isDarkMode)}>
    <div className=Styles.tableSpacing>
      <Row>
        {headers
        ->Belt.Array.mapWithIndex((i, header) => {
          <Col key={header ++ i->Belt.Int.toString} col=columnSize colSm=columnSize>
            <Text value=header weight=Text.Semibold height={Text.Px(18)} transform=Text.Uppercase />
          </Col>
        })
        ->React.array}
      </Row>
    </div>
    <SeperatedLine mt=10 mb=15 />
    {rows
    ->Belt.Array.mapWithIndex((i, row) => {
      <div
        key={"outerRow" ++ i->Belt.Int.toString} className={CssJs.merge(. [Styles.tableSpacing])}>
        <Row>
          {row
          ->Belt.Array.mapWithIndex((j, value) => {
            <Col key={"innerRow" ++ j->Belt.Int.toString} col=columnSize colSm=columnSize>
              {renderField(value, valueWidth, theme)}
            </Col>
          })
          ->React.array}
        </Row>
      </div>
    })
    ->React.array}
  </div>
}
