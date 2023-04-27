module Styles = {
  open CssJs

  let tableWrapper = style(. [
    marginTop(#px(24)),
    display(#flex),
    alignItems(#center),
    justifyContent(#spaceBetween),
    paddingLeft(#px(16)),
    paddingRight(#px(16)),
    marginBottom(#px(8)),
  ])
  let tableHeadItem = style(. [
    marginLeft(#px(8)),
    marginRight(#px(8)),
    minWidth(#px(120)),
    textAlign(#center),
    selector("p", [textAlign(#center)]),
  ])

  let largeColumn = style(. [minWidth(#px(245))])
  let smallColumn = style(. [minWidth(#px(120))])
  let leftAlign = style(. [textAlign(#left)])
}

@react.component
let make = () => {
  let isTablet = Media.isTablet()

  <div className=Styles.tableWrapper>
    <div className={Css.merge(list{Styles.tableHeadItem, Styles.leftAlign})}>
      <Text value="Tx Hash" weight={Text.Semibold} />
    </div>
    <div className=Styles.tableHeadItem>
      <Text value="Packet Type" weight={Text.Semibold} />
    </div>
    {switch isTablet {
    | true => React.null
    | false =>
      <div className=Styles.tableHeadItem>
        <Text value="Sequence" weight={Text.Semibold} />
      </div>
    }}
    <div className=Styles.tableHeadItem>
      <Text value="Request ID" weight={Text.Semibold} />
    </div>
    <div className={Css.merge(list{Styles.tableHeadItem, Styles.smallColumn})}>
      <Text value="Time" weight={Text.Semibold} />
    </div>
    <div className={Css.merge(list{Styles.tableHeadItem, Styles.smallColumn})}>
      <Text value="Status" weight={Text.Semibold} />
    </div>
  </div>
}
