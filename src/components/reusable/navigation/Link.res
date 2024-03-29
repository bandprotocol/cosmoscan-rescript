module Styles = {
  open CssJs

  let a = style(. [textDecoration(#none)])
}

@react.component
let make = (~route, ~className, ~onClick=() => (), ~isTab=false, ~children) =>
  <a
    href={route->Route.toString}
    className={CssJs.merge(. [Styles.a, className])}
    onClick={event =>
      if (
        !(event->ReactEvent.Mouse.defaultPrevented) &&
        (event->ReactEvent.Mouse.button == 0 &&
        (!(event->ReactEvent.Mouse.altKey) &&
        (!(event->ReactEvent.Mouse.ctrlKey) &&
        (!(event->ReactEvent.Mouse.metaKey) && !(event->ReactEvent.Mouse.shiftKey)))))
      ) {
        onClick()
        event->ReactEvent.Mouse.preventDefault
        route->Route.redirect
        !isTab
          ? {
              open Webapi.Dom
              window->Window.scrollTo(0., 0.)
            }
          : ()
      }}>
    children
  </a>
