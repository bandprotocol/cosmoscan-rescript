type t = {client: BandChainJS.client_t};

let context = React.createContext(ContextHelper.default);

@react.component
let make = (~children) => {
  let client = BandChainJS.createClient(Env.grpc);

  React.createElement(React.Context.provider(context), {"value": client, "children": children});
};
