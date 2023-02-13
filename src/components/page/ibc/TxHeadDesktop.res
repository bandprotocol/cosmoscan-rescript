module Styles = {
  open CssJs

  let tableWrapper = style(. [
    marginTop(#px(24)),
    display(#flex),
    alignItems(#center),
    justifyContent(#spaceBetween),
  ])
  let tableHeadItem = style(. [paddingLeft(#px(16)), paddingRight(#px(16))])
}

@react.component
let make = () => {
  <div className=Styles.tableWrapper>
    <div className=Styles.tableHeadItem>
      <Text value="Tx Hash" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Tx Hash" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Counterparty chain ID" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Port & Channel" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Sequence" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Packet Type" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Request ID" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Status" weight={Text.Semibold} />
    </div>
  </div>
}
