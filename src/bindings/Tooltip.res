@react.component @module("@material-ui/core")
external make: (
  ~children: React.element,
  ~title: React.element,
  ~placement: string,
  ~arrow: bool,
  ~leaveDelay: int,
  ~enterTouchDelay: int,
  ~leaveTouchDelay: int,
) => React.element = "Tooltip"
