module Styles = {
  open CssJs

  let filterButtonsContainer = style(. [
    width(#percent(100.)),
    selector("> button", [borderRadius(#px(100))]),
    Media.mobile([margin2(~h=#zero, ~v=#px(24))]),
  ])
}

type t =
  | All
  | Active
  | Inactive

let toString = filter =>
  switch filter {
  | All => "All"
  | Active => "Active Validators"
  | Inactive => "Inactive Validators"
  }

@react.component
let make = (~setFilterType, ~filterType) => {
  <div
    className={Css.merge2(CssHelper.flexBox(~cGap=Spacing.sm, ()), Styles.filterButtonsContainer)}>
    {[All, Active, Inactive]
    ->Belt.Array.mapWithIndex((i, pt) =>
      <ChipButton
        key={i->Belt.Int.toString}
        variant={ChipButton.Outline}
        onClick={_ => setFilterType(_ => pt)}
        isActive={pt === filterType}>
        {pt->toString->React.string}
      </ChipButton>
    )
    ->React.array}
  </div>
}
