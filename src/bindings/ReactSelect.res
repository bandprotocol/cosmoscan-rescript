type react_select_option_t = {
  value: string,
  label: string,
}

@deriving(jsConverter)
type style_t<'a, 'b, 'c, 'd, 'e, 'f, 'g> = {
  control: 'a => 'a,
  option: 'b => 'b,
  container: 'c => 'c,
  singleValue: 'd => 'd,
  indicatorSeparator: 'e => 'e,
  input: 'f => 'f,
  menuList: 'g => 'g,
}

@react.component @module("react-select")
external make: (
  ~value: react_select_option_t,
  ~onChange: 'a => unit,
  ~options: array<'a>,
  ~styles: style_t<'b, 'c, 'd, 'e, 'f, 'g, 'h>,
) => React.element = "default"
