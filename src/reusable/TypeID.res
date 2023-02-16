type pos_t =
  | Landing
  | Title
  | Subtitle
  | Text
  | Mini
  | Body

let fontSize = pos =>
  switch pos {
  | Landing => Text.Xxxl
  | Title => Text.Xxl
  | Body
  | Subtitle =>
    Text.Lg
  | Text => Text.Md
  | Mini => Text.Sm
  }

let lineHeight = pos =>
  switch pos {
  | Landing => Text.Px(31)
  | Body
  | Title =>
    Text.Px(23)
  | Subtitle => Text.Px(18)
  | Text => Text.Px(16)
  | Mini => Text.Px(16)
  }

module Styles = {
  open CssJs

  let link = (theme: Theme.t) =>
    style(. [
      cursor(pointer),
      selector("&:hover > span", [color(theme.primary_600)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])

  let pointerEvents = pos =>
    switch pos {
    | Body
    | Title =>
      style(. [pointerEvents(#none)])
    | Landing
    | Subtitle
    | Text
    | Mini =>
      style(. [pointerEvents(#auto)])
    }
}

module ComponentCreator = (RawID: ID.IDSig) => {
  @react.component
  let make = (~id, ~position=Text, ~block=false) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <Link
      className={CssJs.merge(. [Styles.link(theme), Styles.pointerEvents(position)])}
      route={id->RawID.getRoute}>
      <Text
        value={id->RawID.toString}
        size={position->fontSize}
        weight=Text.Semibold
        height={position->lineHeight}
        nowrap=true
        code=true
        block=true
        color={theme.neutral_900}
      />
    </Link>
  }
}

module PlainLinkCreator = (RawID: ID.IDSig) => {
  @react.component
  let make = (~id, ~children, ~style="") => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Link className={CssJs.merge(. [Styles.link(theme), style])} route={id->RawID.getRoute}>
      children
    </Link>
  }
}

module DataSource = ComponentCreator(ID.DataSource)
module OracleScript = ComponentCreator(ID.OracleScript)
module Request = ComponentCreator(ID.Request)
module Block = ComponentCreator(ID.Block)
module Proposal = ComponentCreator(ID.Proposal)

module DataSourceLink = PlainLinkCreator(ID.DataSource)
module OracleScriptLink = PlainLinkCreator(ID.OracleScript)
module RequestLink = PlainLinkCreator(ID.Request)
module BlockLink = PlainLinkCreator(ID.Block)
module ProposalLink = PlainLinkCreator(ID.Proposal)
