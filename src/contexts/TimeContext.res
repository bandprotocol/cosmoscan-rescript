type t = {currentTime: MomentRe.Moment.t}

let getCurrentDay = _ => MomentRe.momentNow()->MomentRe.Moment.defaultUtc

let context = React.createContext(getCurrentDay())

module Provider = {
  @react.component
  let make = (~children) => {
    let (currentTime, setCurrentTime) = React.useState(getCurrentDay)
    React.useEffect0(() => {
      let timeOutID = Js.Global.setInterval(() => setCurrentTime(getCurrentDay), 60_000)
      Some(() => Js.Global.clearInterval(timeOutID))
    })
    React.createElement(React.Context.provider(context), {value: currentTime, children})
  }
}
