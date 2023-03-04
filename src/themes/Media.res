open Webapi.Dom

type t =
  | Sm
  | Md
  | Lg

let getBreakpoint = size =>
  switch size {
  | Sm => 767
  | Md => 1024
  | Lg => 1365
  }

let query = (size, styles) => {
  let breakpoint = getBreakpoint(size)
  CssJs.media("(max-width:" ++ Belt.Int.toString(breakpoint) ++ "px)", styles)
}

let getWindowWidth = () => window->Window.innerWidth

let useQuery = (~size, ()) => {
  let breakpoint = getBreakpoint(size)

  let (width, setWidth) = React.useState(_ => getWindowWidth())
  let handleWindowResize = (_: Dom.event) => {
    setWidth(_ => getWindowWidth())
  }

  React.useEffect0(() => {
    window->Window.addEventListener("resize", handleWindowResize)
    Some(() => window->Window.removeEventListener("resize", handleWindowResize))
  })

  width <= breakpoint
}

let mobile = styles => query(Md, styles)
let smallMobile = styles => query(Sm, styles)

let isMobile = useQuery(~size=Md)
let isSmallMobile = useQuery(~size=Sm)
let isTablet = useQuery(~size=Lg)
