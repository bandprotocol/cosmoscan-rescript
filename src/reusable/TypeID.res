type pos_t =
  | Landing
  | Title
  | MobileCard
  | Subtitle
  | Text
  | Mini

let fontSize = pos =>
  switch pos {
  | Landing => Text.Xxxxl
  | Title => Text.Xxl
  | MobileCard => Text.Body1
  | Subtitle => Text.Body1
  | Text => Text.Body2
  | Mini => Text.Caption
  }

let lineHeight = pos =>
  switch pos {
  | Landing => Text.Px(31)
  | Title => Text.Px(23)
  | MobileCard => Text.Px(20)
  | Subtitle => Text.Px(18)
  | Text => Text.Px(16)
  | Mini => Text.Px(16)
  }

module Styles = {
  open CssJs

  let link = (theme: Theme.t, hasDetails) =>
    style(. [
      hasDetails ? width(#percent(100.)) : width(#auto),
      cursor(pointer),
      selector("&:hover span", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])

  let pointerEvents = pos =>
    switch pos {
    | Title => style(. [pointerEvents(#none)])
    | Landing
    | MobileCard
    | Subtitle
    | Text
    | Mini =>
      style(. [pointerEvents(#auto)])
    }
  let mono = style(. [fontFamilies([#custom("Roboto Mono"), #monospace])])
}

module ComponentCreator = (RawID: ID.IDSig) => {
  @react.component
  let make = (
    ~id,
    ~position=Text,
    ~size=?,
    ~primary=false,
    ~weight=Text.Regular,
    ~details="",
    ~block=false,
    ~isNotLink=false,
    ~mono=false,
    ~color=?,
  ) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    switch isNotLink {
    | true =>
      <div
        className={Css.merge(list{
          Styles.link(theme, details != ""),
          Styles.pointerEvents(position),
          mono ? Styles.mono : "",
        })}>
        <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
          <Text
            value={id->RawID.toString}
            size={switch size {
            | Some(s) => s
            | None => position->fontSize
            }}
            weight
            height={position->lineHeight}
            nowrap=true
            code=true
            block
            color={color->Belt.Option.getWithDefault(theme.primary_600)}
          />
          {details != ""
            ? <>
                <HSpacing size=Spacing.sm />
                <Text
                  value=details
                  size={switch size {
                  | Some(s) => s
                  | None => position->fontSize
                  }}
                  weight=Text.Regular
                  color={color->Belt.Option.getWithDefault(theme.neutral_900)}
                  ellipsis=true
                />
              </>
            : React.null}
        </div>
      </div>
    | false =>
      <Link
        className={Css.merge(list{
          Styles.link(theme, details != ""),
          Styles.pointerEvents(position),
          mono ? Styles.mono : "",
        })}
        route={id->RawID.getRoute}>
        <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
          <Text
            value={id->RawID.toString}
            size={switch size {
            | Some(s) => s
            | None => position->fontSize
            }}
            weight
            height={position->lineHeight}
            nowrap=true
            code=true
            block
            color={color->Belt.Option.getWithDefault(theme.primary_600)}
          />
          {details != ""
            ? <>
                <HSpacing size=Spacing.sm />
                <Text
                  value=details
                  size={switch size {
                  | Some(s) => s
                  | None => position->fontSize
                  }}
                  weight=Text.Regular
                  color={color->Belt.Option.getWithDefault(theme.neutral_900)}
                  ellipsis=true
                />
              </>
            : React.null}
        </div>
      </Link>
    }
  }
}

module PlainLinkCreator = (RawID: ID.IDSig) => {
  @react.component
  let make = (~id, ~children, ~style="") => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Link className={CssJs.merge(. [Styles.link(theme, false), style])} route={id->RawID.getRoute}>
      children
    </Link>
  }
}

module DataSource = ComponentCreator(ID.DataSource)
module OracleScript = ComponentCreator(ID.OracleScript)
module Request = ComponentCreator(ID.Request)
module Block = ComponentCreator(ID.Block)
module Proposal = ComponentCreator(ID.Proposal)
module LegacyProposal = ComponentCreator(ID.LegacyProposal)

module DataSourceLink = PlainLinkCreator(ID.DataSource)
module OracleScriptLink = PlainLinkCreator(ID.OracleScript)
module RequestLink = PlainLinkCreator(ID.Request)
module BlockLink = PlainLinkCreator(ID.Block)
module ProposalLink = PlainLinkCreator(ID.Proposal)
module LegacyProposalLink = PlainLinkCreator(ID.LegacyProposal)
