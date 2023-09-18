module Styles = {
  open CssJs

  let tabContentWrapper = style(. [marginTop(#px(20)), marginBottom(#px(40))])
}

module MyGroupProposalTabContent = {
  @react.component
  let make = () => {
    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="My Proposals" />
      <MyProposalTable />
    </div>
  }
}

module AllGroupProposalTabContent = {
  @react.component
  let make = () => {
    <div className={Styles.tabContentWrapper}>
      <Heading size=H3 value="All Proposals" />
      <AllGroupProposalTable />
    </div>
  }
}

@react.component
let make = () => {
  <>
    <MyGroupProposalTabContent />
    <AllGroupProposalTabContent />
  </>
}
