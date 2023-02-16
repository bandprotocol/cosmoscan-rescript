let context = React.createContext(BandChainJS.Client.create(""))

module Provider = {
  @react.component
  let make = (~children) => {
    let client = BandChainJS.Client.create(Env.grpc)
    React.createElement(React.Context.provider(context), {value: client, children})
  }
}
