module Styles = {
  open CssJs

  let container = (w, theme: Theme.t) =>
    style(. [
      display(#flex),
      cursor(pointer),
      width(w),
      alignItems(#center),
      selector("> span:hover", [color(theme.primary_600)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])

  let avatarContainer = style(. [position(relative)])

  let validatorStatus = (~isActive, ~theme: Theme.t, ()) =>
    style(. [
      width(#px(10)),
      height(#px(10)),
      backgroundColor(isActive ? theme.success_600 : theme.error_600),
      position(absolute),
      right(#px(-3)),
      top(#px(-3)),
      borderRadius(#percent(50.)),
    ])
}

@react.component
let make = (
  ~validatorAddress: Address.t,
  ~moniker: string,
  ~identity=?,
  ~weight=Text.Semibold,
  ~size=Text.Body2,
  ~underline=false,
  ~width=#auto,
  ~avatarWidth=20,
  ~isActive=?,
) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

  <Link
    className={Styles.container(width, theme)}
    route={Route.ValidatorDetailsPage(validatorAddress, Reports)}>
    {switch identity {
    | Some(identity') =>
      <>
        <div className=Styles.avatarContainer>
          <Avatar moniker identity=identity' width=avatarWidth />
          {switch isActive {
          | None => React.null
          | Some(value) => <div className={Styles.validatorStatus(~isActive=value, ~theme, ())} />
          }}
        </div>
        <HSpacing size=Spacing.sm />
      </>
    | None => React.null
    }}
    <Text
      value=moniker
      color={theme.neutral_900}
      weight
      block=true
      size
      nowrap=true
      ellipsis=true
      underline
    />
  </Link>
}
