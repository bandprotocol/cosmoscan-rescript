type react_select_option_t = {
  value: string,
  label: string,
}

@deriving(jsConverter)
type style_t<'a, 'b, 'c, 'd, 'e, 'f, 'g, 'h> = {
  control: 'a => 'a,
  option: 'b => 'b,
  container: 'c => 'c,
  valueContainer: 'd => 'd,
  singleValue: 'e => 'e,
  indicatorSeparator: 'f => 'f,
  input: 'g => 'g,
  menuList: 'h => 'h,
}

@react.component @module("react-select")
external make: (
  ~value: react_select_option_t,
  ~onChange: 'a => unit,
  ~options: array<'a>,
  ~styles: style_t<'b, 'c, 'd, 'e, 'f, 'g, 'h, 'i>,
) => React.element = "default"
