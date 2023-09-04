module Styles = {
  open CssJs

  let timeContainer = style(. [display(#inlineFlex)])
}

@react.component
let make = (
  ~timeOpt,
  ~prefix="",
  ~suffix="",
  ~size=Text.Caption,
  ~weight=Text.Regular,
  ~spacing=Text.Unset,
  ~textAlign=Text.Left,
  ~color=?,
  ~defaultText="N/A",
  ~style="",
) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className={Css.merge(list{Styles.timeContainer, style})}>
    {prefix != ""
      ? <>
          <Text
            value=prefix
            size
            weight
            color={color->Belt.Option.getWithDefault(theme.neutral_600)}
            spacing
            code=true
          />
          <HSpacing size=Spacing.sm />
        </>
      : React.null}
    {switch timeOpt {
    | Some(time) =>
      <Text
        value={time->MomentRe.Moment.format("YYYY-MM-DD HH:mm:ss", _)}
        size
        weight
        spacing
        code=true
        block=true
        align=textAlign
        color={color->Belt.Option.getWithDefault(theme.neutral_600)}
      />
    | None =>
      <Text
        value={defaultText}
        size
        weight
        spacing
        code=true
        block=true
        align=textAlign
        color={color->Belt.Option.getWithDefault(theme.neutral_600)}
      />
    }}
    {suffix != ""
      ? <>
          <HSpacing size=Spacing.sm />
          <Text
            value=suffix
            size
            weight
            spacing
            code=true
            color={color->Belt.Option.getWithDefault(theme.neutral_600)}
          />
        </>
      : React.null}
  </div>
}

module Grid = {
  @react.component
  let make = (
    ~time,
    ~prefix="",
    ~suffix="",
    ~size=Text.Caption,
    ~weight=Text.Regular,
    ~spacing=Text.Unset,
    ~color=?,
    ~code=false,
    ~textAlign=Text.Left,
  ) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <div>
      {prefix != ""
        ? <>
            <Text
              value=prefix
              size
              weight
              spacing
              color={color->Belt.Option.getWithDefault(theme.neutral_600)}
              code
              nowrap=true
            />
            <HSpacing size=Spacing.sm />
          </>
        : React.null}
      <div>
        <Text
          value={time->MomentRe.Moment.format("YYYY-MM-DD", _)}
          size
          weight
          spacing
          color={color->Belt.Option.getWithDefault(theme.neutral_600)}
          code
          nowrap=true
          block=true
          align=textAlign
        />
      </div>
      <div>
        <Text
          value={time->MomentRe.Moment.format("HH:mm:ss", _)}
          size
          weight
          spacing
          color={color->Belt.Option.getWithDefault(theme.neutral_600)}
          code
          nowrap=true
          block=true
          align=textAlign
        />
      </div>
      {suffix != ""
        ? <>
            <HSpacing size=Spacing.sm />
            <Text
              value=suffix
              size
              weight
              spacing
              color={color->Belt.Option.getWithDefault(theme.neutral_600)}
              code
              nowrap=true
            />
          </>
        : React.null}
    </div>
  }
}
