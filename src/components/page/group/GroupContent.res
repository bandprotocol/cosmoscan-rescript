module Styles = {
  open CssJs

  let tabContentWrapper = style(. [marginTop(#px(20)), marginBottom(#px(40))])
}

module MyGroupTabContent = {
  @react.component
  let make = () => {
    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="My Group" />
      <MyGroupTable />
    </div>
  }
}

module AllGroupTabContent = {
  @react.component
  let make = () => {
    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="All Groups" />
      <AllGroupTable />
    </div>
  }
}

@react.component
let make = () => {
  <>
    <MyGroupTabContent />
    <AllGroupTabContent />
  </>
}
