type t = {financial: PriceHook.t}

let context = React.createContext(Sub.NoData)

module Provider = {
  @react.component
  let make = (~children) => {
    let client = BandChainJS.Client.create(Env.rpc)
    let (financialOpt, setFinancialOpt) = React.useState(_ => None)

    React.useEffect0(() => {
      let fetchData = () =>
        PriceHook.getBandInfo(client)
        ->Promise.then(bandInfoOpt => {
          setFinancialOpt(_ => bandInfoOpt)
          Promise.resolve()
        })
        ->ignore

      fetchData()
      let intervalID = Js.Global.setInterval(fetchData, 60000)
      Some(() => Js.Global.clearInterval(intervalID))
    })

    let data = switch financialOpt {
    | Some(financial) => Some({financial: financial})
    | _ => None
    }

    React.createElement(
      React.Context.provider(context),
      {
        value: switch data {
        | Some(x) => Sub.resolve(x)
        | None => Sub.Loading
        },
        children,
      },
    )
  }
}
