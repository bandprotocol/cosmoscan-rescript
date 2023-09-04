type variant_t = Mobile | Desktop

@react.component
let make = (~children, ~variant) => {
  let isMobile = Media.isMobile()

  switch (isMobile, variant) {
  | (true, Mobile) => React.null
  | (false, Mobile) => children
  | (true, Desktop) => children
  | (false, Desktop) => React.null
  }
}
