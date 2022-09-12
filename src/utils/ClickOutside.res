open Webapi.Dom

let handleClickOutside = (domElement: Dom.element, e: Dom.mouseEvent, fn) => {
  let targetElement = MouseEvent.target(e) |> EventTarget.unsafeAsElement

  !(domElement -> Element.contains(~child=targetElement)) ? fn(e) : ()
}

let useClickOutside = (onClickOutside: Dom.mouseEvent => unit) => {
  let elementRef = React.useRef(Js.Nullable.null)

  let handleMouseDown = (e: Dom.mouseEvent) => {
    elementRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.map(refValue => handleClickOutside(refValue, e, onClickOutside))
    ->ignore
  }

  React.useEffect0(() => {
    Document.addMouseDownEventListener(document, handleMouseDown)
    Some(() => Document.removeMouseDownEventListener(document, handleMouseDown))
  })

  elementRef
}
