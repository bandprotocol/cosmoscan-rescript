@react.component
let make = () =>
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <Example /> <ExampleRoute />
  </ApolloClient.React.ApolloProvider>
