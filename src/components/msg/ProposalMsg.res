module Styles = {
  open CssJs

  let msgContainer = style(. [selector("> * + *", [marginLeft(#px(5))])])
}

module BadgeWrapper = {
  @react.component
  let make = (~children) =>
    <div
      className={CssJs.merge(. [
        CssHelper.flexBox(~align=#center, ()),
        CssHelper.overflowHidden,
        Styles.msgContainer,
      ])}>
      {children}
    </div>
}

module SubmitProposal = {
  module Success = {
    @react.component
    let make = (~proposalID, ~title) =>
      <BadgeWrapper>
        <TypeID.LegacyProposal id=proposalID />
        <Text value=title size=Text.Body2 nowrap=true block=true />
      </BadgeWrapper>
  }

  module Fail = {
    @react.component
    let make = (~title) =>
      <BadgeWrapper>
        <Text value=title size=Text.Body2 nowrap=true block=true />
      </BadgeWrapper>
  }
}

module SubmitCouncilProposal = {
  module Success = {
    @react.component
    let make = (~proposalID, ~council) =>
      <BadgeWrapper>
        <TypeID.Proposal id=proposalID />
        <Text
          value={council->Council.CouncilNameParser.parse->Council.getCouncilNameString}
          size=Text.Body2
          marginLeft=8
          nowrap=true
          block=true
        />
      </BadgeWrapper>
  }

  module Fail = {
    @react.component
    let make = (~council) =>
      <BadgeWrapper>
        <Text
          value={council->Council.CouncilNameParser.parse->Council.getCouncilNameString}
          size=Text.Body2
          nowrap=true
          block=true
        />
      </BadgeWrapper>
  }
}

module Deposit = {
  module Success = {
    @react.component
    let make = (~proposalID, ~title, ~amount) =>
      <BadgeWrapper>
        <AmountRender coins=amount size={Body2} />
        <Text value={j` to `} size=Text.Body2 nowrap=true block=true />
        <TypeID.LegacyProposal id=proposalID />
        <Text value=title size=Text.Body2 nowrap=true block=true />
      </BadgeWrapper>
  }

  module Fail = {
    @react.component
    let make = (~proposalID) =>
      <BadgeWrapper>
        <TypeID.LegacyProposal id=proposalID />
      </BadgeWrapper>
  }
}

module LegacyVote = {
  module Success = {
    @react.component
    let make = (~proposalID, ~title) =>
      <BadgeWrapper>
        <TypeID.LegacyProposal id=proposalID />
        <Text value=title size=Text.Body2 nowrap=true block=true marginLeft=8 />
      </BadgeWrapper>
  }

  module Fail = {
    @react.component
    let make = (~proposalID) =>
      <BadgeWrapper>
        <TypeID.LegacyProposal id=proposalID />
      </BadgeWrapper>
  }
}

module Vote = {
  module Success = {
    @react.component
    let make = (~proposalID, ~title) =>
      <BadgeWrapper>
        <TypeID.Proposal id=proposalID />
        <Text value=title size=Text.Body2 nowrap=true block=true marginLeft=8 />
      </BadgeWrapper>
  }

  module Fail = {
    @react.component
    let make = (~proposalID) =>
      <BadgeWrapper>
        <TypeID.Proposal id=proposalID />
      </BadgeWrapper>
  }
}
