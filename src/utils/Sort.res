type sort_direction_t =
  | ASC
  | DESC

let toString = direction =>
  switch direction {
  | ASC => "ASC"
  | DESC => "DESC"
  }
