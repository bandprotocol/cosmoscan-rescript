module Styles = {
  open CssJs

  let tableWrapper = style(. [
    marginTop(#px(24)),
    display(#flex),
    alignItems(#center),
    justifyContent(#spaceBetween),
    paddingLeft(#px(16)),
    paddingRight(#px(16)),
  ])
  let tableHeadItem = style(. [
    marginLeft(#px(8)),
    marginRight(#px(8)),
    // minWidth(#calc((#sub, #percent(16.), #px(8)))),
    minWidth(#px(135)),
    textAlign(#center),
  ])

  let largeColumn = style(. [minWidth(#px(245))])
  let smallColumn = style(. [minWidth(#px(80))])
  let leftAlign = style(. [textAlign(#left)])
}

@react.component
let make = () => {
  <div className=Styles.tableWrapper>
    <div className={Css.merge(list{Styles.tableHeadItem, Styles.leftAlign})}>
      <Text value="Tx Hash" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Counterparty chain ID" weight={Text.Semibold} />
    </div>
    <div className={Css.merge(list{Styles.tableHeadItem, Styles.largeColumn})}>
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
    <div className={Css.merge(list{Styles.tableHeadItem, Styles.smallColumn})}>
      <Text value="Status" weight={Text.Semibold} />
    </div>
  </div>
}
